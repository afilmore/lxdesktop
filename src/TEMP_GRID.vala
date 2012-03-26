/* *************************************************************************************************************
 * Drag And Drop Handling
 * 
 **************************************************************************************************************/
/*
FmDndSrc* dnd_src;
FmDndDest* dnd_dest;
enum {
    FM_DND_DEST_DESKTOP_ITEM = N_FM_DND_DEST_DEFAULT_TARGETS + 1
};

GtkTargetEntry dnd_targets[] =
{
    {"application/x-desktop-item", GTK_TARGET_SAME_WIDGET, FM_DND_DEST_DESKTOP_ITEM}
};


private inline bool is_atom_in_targets(List targets, const char* name)
{
    List l;
    for(l = targets; l; l=l->next)
    {
        GdkAtom atom = (GdkAtom)l->data;
        if (gdk_atom_intern(name, false))
            return true;
    }
    return false;
}

private void _init_drad_and_drop () {
            Gtk.TargetList targets;
    
    // init dnd support
    gtk_drag_source_set (0,
            fm_default_dnd_dest_targets, N_FM_DND_DEST_DEFAULT_TARGETS,
            GDK_ACTION_COPY|GDK_ACTION_MOVE|GDK_ACTION_LINK|GDK_ACTION_ASK);
    targets = gtk_drag_source_get_target_list ();
    // add our own targets
    gtk_target_list_add_table(targets, dnd_targets, G_N_ELEMENTS(dnd_targets));
    // a dirty way to override FmDndSrc.
    g_signal_connect"drag-data-get", G_CALLBACK(on_drag_data_get), null);
    this.dnd_src = fm_dnd_src_new((GtkWidget*)self);
    g_signal_connect(this.dnd_src, "data-get", G_CALLBACK(on_dnd_src_data_get), self);

    gtk_drag_dest_set0, null, 0,
            GDK_ACTION_COPY|GDK_ACTION_MOVE|GDK_ACTION_LINK|GDK_ACTION_ASK);
    gtk_drag_dest_set_target_list(GTK_WIDGET(self), targets);

    this.dnd_dest = fm_dnd_dest_new((GtkWidget*)self);
}

private bool on_drag_motion  (GtkWidget *dest_widget,
                    GdkDragContext *drag_context,
                    gint x,
                    gint y,
                    uint time)
{
    GdkAtom target;
    bool ret = false;
    GdkDragAction action = 0;
    FmDesktop* desktop = FM_DESKTOP(dest_widget);
    Desktop.Item item;

    // check if we're dragging over an item
    item = hit_test(desktop, x, y);
    // we can only allow dropping on desktop entry file, folder, or executable files
    if (item)
    {
        if (!fm_file_info_is_dir(item->fi) &&
           // FIXME: libfm cannot detect if the file is executable!
           // !fm_file_info_is_executable_type(item->fi) &&
           !fm_file_info_is_desktop_entry(item->fi))
           item = null;
    }

    // handle moving desktop items
    if (!item)
    {
        target = gdk_atom_intern_static_string(dnd_targets[0].target);
        if (fm_drag_context_has_target(drag_context, target)
           && (drag_context->actions & GDK_ACTION_MOVE))
        {
            // desktop item is being dragged
            fm_dnd_dest_set_dest_file(desktop->dnd_dest, null);
            action = GDK_ACTION_MOVE; // move desktop items
            ret = true;
        }
    }

    if (!ret)
    {
        target = fm_dnd_dest_find_target(desktop->dnd_dest, drag_context);
        // try FmDndDest
        if (target != GDK_NONE)
        {
            FmFileInfo* dest_file;
            if (item && item->fi)
            {
                // if (fm_file_info_is_dir(item->fi))
                dest_file = item->fi;
            }
            else // FIXME: prevent direct access to data member
                dest_file = _folder_model->dir->dir_fi;

            fm_dnd_dest_set_dest_file(desktop->dnd_dest, dest_file);
            action = fm_dnd_dest_get_default_action(desktop->dnd_dest, drag_context, target);
            ret = action != 0;
        }
        else
        {
            ret = false;
            action = 0;
        }
    }
    gdk_drag_status(drag_context, action, time);

    if (desktop->drop_hilight != item)
    {
        Desktop.Item old_drop = desktop->drop_hilight;
        desktop->drop_hilight = item;
        if (old_drop)
            old_drop.redraw ();
        if (item)
            item.redraw();
    }

    return ret;
}

private bool on_drag_leave  (GtkWidget *dest_widget,
                    GdkDragContext *drag_context,
                    uint time)
{
    FmDesktop* desktop = FM_DESKTOP(dest_widget);

    fm_dnd_dest_drag_leave(desktop->dnd_dest, drag_context, time);

    if (desktop->drop_hilight)
    {
        Desktop.Item old_drop = desktop->drop_hilight;
        desktop->drop_hilight = null;
        old_drop.redraw ();
    }

    return true;
}

private bool on_drag_drop  (GtkWidget *dest_widget,
                    GdkDragContext *drag_context,
                    gint x,
                    gint y,
                    uint time)
{
    FmDesktop* desktop = FM_DESKTOP(dest_widget);
    GtkTreeViewDropPosition pos;
    bool ret = false;
    GdkAtom target;
    Desktop.Item item;

    // check if we're dragging over an item
    item = hit_test(desktop, x, y);
    // we can only allow dropping on desktop entry file, folder, or executable files
    if (item)
    {
        if (!fm_file_info_is_dir(item->fi) &&
           // FIXME: libfm cannot detect if the file is executable!
           // !fm_file_info_is_executable_type(item->fi) &&
           !fm_file_info_is_desktop_entry(item->fi))
           item = null;
    }

    // handle moving desktop items
    if (!item)
    {
        target = gdk_atom_intern_static_string(dnd_targets[0].target);
        if (fm_drag_context_has_target(drag_context, target)
           && (drag_context->actions & GDK_ACTION_MOVE))
        {
            // desktop items are being dragged
            List items = get_selected_items(desktop, null);
            List l;
            int offset_x = x - desktop->drag_start_x;
            int offset_y = y - desktop->drag_start_y;
            for(l = items; l; l=l->next)
            {
                Desktop.Item item = (Desktop.Item)l->data;
                move_item(desktop, item, item->x + offset_x, item->y + offset_y, false);
            }
            ret = true;
            gtk_drag_finish(drag_context, true, false, time);

            // FIXME: save position of desktop icons everytime is
             * extremely inefficient, but currently inevitable.
            save_item_pos(desktop);

            queue_layout_items(desktop);
        }
    }

    if (!ret)
    {
        target = fm_dnd_dest_find_target(desktop->dnd_dest, drag_context);
        // try FmDndDest
        ret = fm_dnd_dest_drag_drop(desktop->dnd_dest, drag_context, target, x, y, time);
        if (!ret)
            gtk_drag_finish(drag_context, false, false, time);
    }
    return ret;
}

private void on_drag_data_received  (GtkWidget *dest_widget,
                GdkDragContext *drag_context,
                gint x,
                gint y,
                GtkSelectionData *sel_data,
                uint info,
                uint time)
{
    FmDesktop* desktop = FM_DESKTOP(dest_widget);
    GtkTreePath* dest_tp = null;
    GtkTreeViewDropPosition pos;
    bool ret = false;

    switch(info)
    {
    case FM_DND_DEST_DESKTOP_ITEM:
        // This shouldn't happen since we handled everything in drag-drop handler already.
        break;
    default:
        // check if files are received.
        fm_dnd_dest_drag_data_received(desktop->dnd_dest, drag_context, x, y, sel_data, info, time);
        break;
    }
}

private void on_drag_data_get(GtkWidget *src_widget, GdkDragContext *drag_context,
                             GtkSelectionData *sel_data, uint info,
                             uint time, gpointer user_data)
{
    FmDesktop* desktop = FM_DESKTOP(src_widget);
    // desktop items are being dragged
    if (info == FM_DND_DEST_DESKTOP_ITEM)
        g_signal_stop_emission_by_name (src_widget, "drag-data-get");
}

void on_dnd_src_data_get(FmDndSrc* ds, FmDesktop* desktop)
{
    FmFileInfoList* files = fm_desktop_get_selected_files(desktop);
    if (files)
    {
        fm_dnd_src_set_files(ds, files);
        fm_list_unref(files);
    }
}

*/

/* *********************************************************************************************************************
 * 
 * 
 * 
 * 
private Desktop.Item? get_nearest_item (Desktop.Item item, Gtk.DirectionType direction) {
    
    Desktop.Item ret = null;
    
    uint min_x_dist;
    uint min_y_dist;

    if (_items == null || _items.next == null)
        return null;

    min_x_dist = min_y_dist = (guint)-1;
    
    switch (direction) {
        
        case GTK_DIR_LEFT:
            
            foreach (Desktop.Item item2 in _items) {

                if (item2.x >= this.x)
                    continue;
                
                int dist = this.x - item2.x;
                
                if (dist < min_x_dist) {
                    ret = item2;
                    min_x_dist = dist;
                    min_y_dist = abs (this.y - item2.y);
                
                // if there is another item of the same x distance
                } else if (dist == min_x_dist && item2 != ret) {
                    
                    // get the one with smaller y distance
                    dist = abs (item2.y - this.y);
                    if (dist < min_y_dist) {
                        ret = item2;
                        min_y_dist = dist;
                    }
                }
            }
        break;
        
        case GTK_DIR_RIGHT:
            
            foreach (Desktop.Item item2 in _items) {
                
                if (item2.x <= this.x)
                    continue;
                
                int dist = item2.x - this.x;
                
                if (dist < min_x_dist) {
                    ret = item2;
                    min_x_dist = dist;
                    min_y_dist = abs (this.y - item2.y);
                
                // if there is another item of the same x distance
                } else if (dist == min_x_dist && item2 != ret) {
                    
                    // get the one with smaller y distance
                    dist = abs (item2.y - this.y);
                    if (dist < min_y_dist) {
                        ret = item2;
                        min_y_dist = dist;
                    }
                }
            }
        break;
        
        case GTK_DIR_UP:
            
            foreach (Desktop.Item item2 in _items) {
                
                if (item2.y >= this.y)
                    continue;
                
                int dist = this.y - item2.y;
                if (dist < min_y_dist) {
                    ret = item2;
                    min_y_dist = dist;
                    min_x_dist = abs (this.x - item2.x);
                // if there is another item of the same y distance
                } else if (dist == min_y_dist && item2 != ret) {
                    
                    // get the one with smaller x distance
                    dist = abs (item2.x - this.x);
                    if (dist < min_x_dist) {
                        ret = item2;
                        min_x_dist = dist;
                    }
                }
            }
        break;
        
        case GTK_DIR_DOWN:
            
            foreach (Desktop.Item item2 in _items) {
                
                if (item2.y <= this.y)
                    continue;
                
                int dist = item2.y - this.y;
                
                if (dist < min_y_dist) {
                    ret = item2;
                    min_y_dist = dist;
                    min_x_dist = abs (this.x - item2.x);
                
                // if there is another item of the same y distance
                } else if (dist == min_y_dist && item2 != ret) {
                
                    // get the one with smaller x distance
                    dist = abs (item2.x - this.x);
                    if (dist < min_x_dist) {
                        ret = item2;
                        min_x_dist = dist;
                    }
                }
            }
        break;
    }
    
    return ret;
}
*/


private void on_snap_to_grid (Gtk.Action act) {
    
    FmDesktop* desktop = FM_DESKTOP(user_data);
    Desktop.Item item;
    List items = get_selected_items(desktop, null);
    List l;
    int x, y, bottom;
    GtkTextDirection direction = this.get_direction(GTK_WIDGET(desktop));

    y = desktop.working_area.y + desktop.ymargin;
    bottom = desktop.working_area.y + desktop.working_area.height - desktop.ymargin - desktop.cell_h;

    if (direction != GTK_TEXT_DIR_RTL) // LTR or NONE
        x = desktop.working_area.x + desktop.xmargin;
    else // RTL
        x = desktop.working_area.x + desktop.working_area.width - desktop.xmargin - desktop.cell_w;

    for (l = items; l; l = l.next) {
        
        int new_x, new_y;
        item = l.data as Desktop.Item;
        
        if (!item.fixed_pos)
            continue;
        new_x = x + _round((double)(item.x - x) / desktop.cell_w) * desktop.cell_w;
        new_y = y + _round((double)(item.y - y) / desktop.cell_h) * desktop.cell_h;
        move_item (desktop, item, new_x, new_y, false);
    }
    
    queue_layout_items (desktop);
}

private void on_fix_pos (Gtk.ToggleAction act) {

    FmDesktop* desktop = FM_DESKTOP (user_data);
    
    List items = this.get_selected_items (null);
    List l;
    
    if (act.get_active()) {
        for (l = items; l; l=l.next) {
            Desktop.Item item = l.data as Desktop.Item;
            if (item.fixed_pos == false) {
                item.fixed_pos = true;
                desktop.fixed_items = desktop.fixed_items.prepend (item);
            }
        }
    } else {
        for (l = items; l; l=l.next) {
            Desktop.Item item = l.data as Desktop.Item;
            item.fixed_pos = false;
            desktop.fixed_items = desktop.fixed_items.remove (item);
        }
        layout_items (desktop);
    }
    
    save_item_pos (desktop);
}

*/


/***********************************************************************************************************************
 * These are original function, I plan to implement these a different way...
 * Grid.append_item () replaces layout_items ()
 * 
 * 
 
static void on_model_loaded(FmFolderModel* global_model, gpointer user_data)
{
    int i;
    // the desktop folder is just loaded, apply desktop item positions
    GKeyFile* kf = g_key_file_new();
    for( i = 0; i < n_screens; i++ )
    {
        FmDesktop* desktop = FM_DESKTOP(desktops[i]);
        load_item_pos(desktop, kf);
    }
    g_key_file_free(kf);
}

static inline void load_item_pos(FmDesktop* desktop, GKeyFile* kf)
{
    char* path = get_config_file(desktop, FALSE);
    if(g_key_file_load_from_file(kf, path, 0, NULL))
    {
        GList* l;
        for(l = desktop->items; l; l=l->next)
        {
            FmDesktopItem* item = (FmDesktopItem*)l->data;
            const char* name = fm_path_get_basename(item->fi->path);
            if(g_key_file_has_group(kf, name))
            {
                desktop->fixed_items = g_list_prepend(desktop->fixed_items, item);
                item->fixed_pos = TRUE;
                item->x = g_key_file_get_integer(kf, name, "x", NULL);
                item->y = g_key_file_get_integer(kf, name, "y", NULL);
                calc_item_size(desktop, item);
            }
        }
    }
    g_free(path);
}

static char* get_config_file(FmDesktop* desktop, gboolean create_dir)
{
    char* dir = pcmanfm_get_profile_dir(create_dir);
    GdkScreen* scr = gtk_widget_get_screen(GTK_WIDGET(desktop));
    int n = gdk_screen_get_number(scr);
    char* path = g_strdup_printf("%s/desktop-items-%d.conf", dir, n);
    g_free(dir);
    return path;
}

static void save_item_pos(FmDesktop* desktop)
{
    GList* l;
    GString* buf;
    char* path;
    buf = g_string_sized_new(1024);
    for(l = desktop->fixed_items; l; l=l->next)
    {
        FmDesktopItem* item = (FmDesktopItem*)l->data;
        const char* p;
        // write the file basename as group name
        g_string_append_c(buf, '[');
        for(p = item->fi->path->name; *p; ++p)
        {
            switch(*p)
            {
            case '\r':
                g_string_append(buf, "\\r");
                break;
            case '\n':
                g_string_append(buf, "\\n");
                break;
            case '\\':
                g_string_append(buf, "\\\\");
                break;
            default:
                g_string_append_c(buf, *p);
            }
        }
        g_string_append(buf, "]\n");
        g_string_append_printf(buf, "x=%d\n"
                                    "y=%d\n\n",
                                    item->x, item->y);
    }
    path = get_config_file(desktop, TRUE);
    g_file_set_contents(path, buf->str, buf->len, NULL);
    g_free(path);
    g_string_free(buf, TRUE);
}

private void _layout_items () {
    
    List l;
    Desktop.Item item;
    int x;
    int y;
    int bottom;
    
    Gtk.TextDirection direction = this.get_direction ();

    y = this.working_area.y + this.ymargin;
    bottom = this.working_area.y + this.working_area.height - this.ymargin - this.cell_h;

    // LTR or NONE
    if (direction != GTK_TEXT_DIR_RTL) {
        x = this.working_area.x + this.xmargin;
        
        for (l = this.items; l; l = l.next) {
            item = l.data as Desktop.Item;
            
            if (item.fixed_pos) {
                calc_item_size (item);
            
            } else {
                
                _next_position:
                
                item.x = x;
                item.y = y;
                calc_item_size (item);
                y += this.cell_h;
                
                if (y > bottom) {
                    x += this.cell_w;
                    y = this.working_area.y + this.ymargin;
                }
                
                // check if this position is occupied by a fixed item
                if (is_pos_occupied (item))
                    goto _next_position;
            }
        }
    
    // RTL
    } else {
        
        x = this.working_area.x + this.working_area.width - this.xmargin - this.cell_w;
        
        for (l = this.items; l; l = l.next) {
            
            item = l.data as Desktop.Item;
            
            if (item.fixed_pos) {
                calc_item_size (item);
            
            } else {
                
                _next_position_rtl:
                
                item.x = x;
                item.y = y;
                
                calc_item_size (item);
                y += this.cell_h;
                
                if (y > bottom) {
                    x -= this.cell_w;
                    y = this.working_area.y + this.ymargin;
                }
                
                // check if this position is occupied by a fixed item
                if (is_pos_occupied (item))
                    goto _next_position_rtl;
            }
        }
    }
    
    this.queue_draw ();
    
}

***********************************************************************************************************************/


