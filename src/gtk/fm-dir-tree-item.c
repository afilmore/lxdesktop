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



