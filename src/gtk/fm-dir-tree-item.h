/***********************************************************************************************************************
 * fm-dir-tree-item.h
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
#ifndef __FM_DIR_TREE_ITEM_H__
#define __FM_DIR_TREE_ITEM_H__

#include <gtk/gtk.h>
#include <glib-object.h>

#include "fm-dir-tree-model.h"
#include "fm-folder.h"
#include "fm-file-info.h"

G_BEGIN_DECLS

typedef struct _FmDirTreeItem FmDirTreeItem;
struct _FmDirTreeItem
{
    FmDirTreeModel  *model;
    FmFileInfo      *fi;
    FmFolder        *folder;
    GdkPixbuf       *icon;
    guint           n_expand;
    
    GList           *parent;            /* parent node */
    GList           *children;          /* child items */
    GList           *hidden_children;
};


inline FmDirTreeItem* fm_dir_tree_item_new (FmDirTreeModel* model, GList* parent_l);
inline void fm_dir_tree_item_free (FmDirTreeItem* item);

inline void _g_list_foreach_l (GList* list, GFunc func, gpointer user_data);
void fm_dir_tree_item_free_l (GList* item_l);

G_END_DECLS
#endif

