/***********************************************************************************************************************
 * fm-dir-tree-item.c
 * 
 * Copyright 2010 Hong Jen Yee (PCMan) <pcman.tw@gmail.com>
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * Purpose: 
 * 
 * 
 * 
 **********************************************************************************************************************/
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <glib/gi18n-lib.h>
#include <string.h>

#include "fm-dir-tree-item.h"

static void on_folder_files_added (FmFolder* folder, GSList* files, GList* item_list);
static void on_folder_files_removed (FmFolder* folder, GSList* files, GList* item_list);
static void on_folder_files_changed (FmFolder* folder, GSList* files, GList* item_list);

inline FmDirTreeItem* fm_dir_tree_item_new (FmDirTreeModel* model, GList* parent_l)
{
    FmDirTreeItem* item = g_slice_new0 (FmDirTreeItem);
    item->model = model;
    item->parent = parent_l;
    return item;
}

inline void item_free_folder (GList* item_l);

/* Most of time fm_dir_tree_item_free_l () should be called instead. */
inline void fm_dir_tree_item_free (FmDirTreeItem* item)
{
    if (item->fi)
        fm_file_info_unref (item->fi);
    if (item->icon)
        g_object_unref (item->icon);

    if (item->folder) /* most of cases this should have been freed in item_free_folder () */
        g_object_unref (item->folder);

    if (item->children)
    {
        _g_list_foreach_l (item->children, (GFunc)fm_dir_tree_item_free_l, NULL);
        g_list_free (item->children);
    }
    if (item->hidden_children)
    {
        g_list_foreach (item->hidden_children, (GFunc)fm_dir_tree_item_free, NULL);
        g_list_free (item->hidden_children);
    }
    g_slice_free (FmDirTreeItem, item);
}

/* Free the GList* element along with its associated FmDirTreeItem */
void fm_dir_tree_item_free_l (GList* item_l)
{
    FmDirTreeItem* item = (FmDirTreeItem*)item_l->data;
    item_free_folder (item_l);
    fm_dir_tree_item_free (item);
}

void on_folder_loaded (FmFolder* folder, GList* item_list)
{
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    FmDirTreeModel* model = dir_tree_item->model;
    GList* place_holder_l;

    place_holder_l = dir_tree_item->children;
    
    // If we have loaded sub dirs, remove the place holder...
    if (dir_tree_item->children->next)
    {
        remove_item (model, place_holder_l);
    }
    
    // If we have no sub dirs, leave the place holder and let it show "Empty" 
    else
    {
        GtkTreeIter it;
        GtkTreePath* tp = item_to_tree_path (model, place_holder_l);
        item_to_tree_iter (model, place_holder_l, &it);
        gtk_tree_model_row_changed ((GtkTreeModel*) model, tp, &it);
        gtk_tree_path_free (tp);
    }
}

static void on_folder_files_added (FmFolder* folder, GSList* files, GList* item_list)
{
    GSList* l;
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    FmDirTreeModel* model = dir_tree_item->model;
    GtkTreePath* tp = item_to_tree_path (model, item_list);
    for (l = files; l; l = l->next)
    {
        FmFileInfo* fi = FM_FILE_INFO (l->data);
        
        /*** should FmFolder generate "files-added" signal on
         * its first-time loading? Isn't "loaded" signal enough ? ***/
        
        if (fm_file_info_is_dir (fi))
        {
            // Ensure that the file is not yet in our model
            GList* new_item_list = children_by_name (model, dir_tree_item->children, fi->path->name, NULL);
            if (!new_item_list)
                new_item_list = insert_file_info (model, item_list, tp, fi);
        }
    }
    gtk_tree_path_free (tp);
}

static void on_folder_files_removed (FmFolder* folder, GSList* files, GList* item_list)
{
    GSList* l;
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    FmDirTreeModel* model = dir_tree_item->model;
    // GtkTreePath* tp = item_to_tree_path (model, item_list);
    for (l = files; l; l = l->next)
    {
        FmFileInfo* fi = FM_FILE_INFO (l->data);
        GList* rm_item_list = children_by_name (model, dir_tree_item->children, fi->path->name, NULL);
        if (rm_item_list)
            remove_item (model, rm_item_list);
    }
    // gtk_tree_path_free (tp); 
}

static void on_folder_files_changed (FmFolder* folder, GSList* files, GList* item_list)
{
    GSList* l;
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    FmDirTreeModel* model = dir_tree_item->model;
    GtkTreePath* tp = item_to_tree_path (model, item_list);

    printf ("files changed!!\n");

    for (l = files; l; l = l->next)
    {
        FmFileInfo* fi = FM_FILE_INFO (l->data);
        int idx;
        GList* changed_item_list = children_by_name (model, dir_tree_item->children, fi->path->name, &idx);
        
        // g_debug ("changed file: %s", fi->path->name); 
        if (changed_item_list)
        {
            
            FmDirTreeItem* changed_item = (FmDirTreeItem*)changed_item_list->data;
            if (changed_item->fi)
                fm_file_info_unref (changed_item->fi);
            
            changed_item->fi = fm_file_info_ref (fi);
            
            // FIXME: inform gtk tree view about the change 

            // Check Subdirectories: check if we have sub folder 
            item_queue_subdir_check (model, changed_item_list);
        }
    }
    gtk_tree_path_free (tp);
}

void fm_dir_tree_item_set_folder (GList* item_list)
{
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    FmFolder* folder = fm_folder_get (dir_tree_item->fi->path);
    dir_tree_item->folder = folder;

    // Associate the data with loaded handler...
    g_signal_connect (folder, "loaded", G_CALLBACK (on_folder_loaded), item_list);
    g_signal_connect (folder, "files-added", G_CALLBACK (on_folder_files_added), item_list);
    g_signal_connect (folder, "files-removed", G_CALLBACK (on_folder_files_removed), item_list);
    g_signal_connect (folder, "files-changed", G_CALLBACK (on_folder_files_changed), item_list);
}

/* a varient of g_list_foreach which does the same thing, but pass GList* element
 * itself as the first parameter to func (), not the element data. */
inline void _g_list_foreach_l (GList* list, GFunc func, gpointer user_data)
{
    while (list)
    {
        GList *next = list->next;
        (*func) (list, user_data);
        list = next;
    }
}

inline void item_free_folder (GList* item_list)
{
    FmDirTreeItem* dir_tree_item = (FmDirTreeItem*)item_list->data;
    if (dir_tree_item->folder)
    {
        FmFolder* folder = dir_tree_item->folder;
        g_signal_handlers_disconnect_by_func (folder, on_folder_loaded, item_list);
        g_signal_handlers_disconnect_by_func (folder, on_folder_files_added, item_list);
        g_signal_handlers_disconnect_by_func (folder, on_folder_files_removed, item_list);
        g_signal_handlers_disconnect_by_func (folder, on_folder_files_changed, item_list);
        g_object_unref (folder);
        dir_tree_item->folder = NULL;
    }
}





