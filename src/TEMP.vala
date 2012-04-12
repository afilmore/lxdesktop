/* *********************************************************************************************************************
 * *** DOESN'T BUILD ***
 * 
 * 
 * *********************************************************************************************************************
    // round() is only available in C99. (this funtion is used in "snap to grid"...)
    inline double _round (double x) {
        return (x > 0.0) ? floor (x + 0.5) : ceil (x - 0.5);
    }

    string atom_names[] = {"_NET_WORKAREA", "_NET_NUMBER_OF_DESKTOPS", "_NET_CURRENT_DESKTOP", "_XROOTMAP_ID"};

    Atom atoms[G_N_ELEMENTS(atom_names)] = {0};
     
    if (XInternAtoms (GDK_DISPLAY(), atom_names, G_N_ELEMENTS(atom_names), False, atoms)) {
        XA_NET_WORKAREA = atoms[0];
        XA_NET_NUMBER_OF_DESKTOPS = atoms[1];
        XA_NET_CURRENT_DESKTOP = atoms[2];
        XA_XROOTMAP_ID= atoms[3];
    }

    Atom XA_NET_WORKAREA = 0;
    Atom XA_NET_NUMBER_OF_DESKTOPS = 0;
    Atom XA_NET_CURRENT_DESKTOP = 0;
    Atom XA_XROOTMAP_ID= 0;

 * 
 * 
 **********************************************************************************************************************/


/***********************************************************************************************************************
 * Currently Unused Functions....
 * 
 * 
 **********************************************************************************************************************/
private void _on_icon_theme_changed (Gtk.IconTheme theme) {
    
    /*******************************************
     * The user changed the system icon theme.
     * 
     */
    
    //this._reload_icons();
    
}

private void _reload_icons() {
    
    /*******************************************************************
     * Reload icons when the icon size or the icon theme has changed
     * 
     * 
    
    int i;
    for (i=0; i < _n_screens; ++i) {
        FmDesktop* desktop = desktops[i];
        
        List l;
        for (l=desktop.items; l; l=l.next) {
            
            Desktop.Item item = l.data as Desktop.Item;
            
            if (item.icon) {
                item.icon = null;
                global_model.get (item.it, COL_FILE_ICON, out item.icon, -1);
            }
        }
        
        this.queue_resize ();
    }
    */
}


/***********************************************************************************************************************
 * Grid: Unused functions....
 * 
 * 
 **********************************************************************************************************************/
// See where to store these focus items, in the grid ? probably...
public List get_selected_items (out int n_items) {
    
    
    List<Desktop.Item>? items = null;
    
    /*List l;
    int n = 0;
    
    Desktop.Item? _selected_item = null;
    
    for (l=desktop.items; l; l=l.next) {
        
        Desktop.Item item = l.data as Desktop.Item;
        
        if (item.is_selected) {
            
            if (item != _selected_item) {
                items = items.prepend (item);
                ++n;
            } else {
                _selected_item = item;
            }
        }
    }
    
    items = items.reverse ();
    if (_selected_item != null) {
        items = items.prepend (_selected_item);
        ++n;
    }
    
    if (n_items)
        *n_items = n;
    */
    return items;
}

private void on_sort_type (Gtk.Action act, Gtk.RadioAction cur, void *user_data) {
    /*desktop_sort_type = cur.get_current_value();
    _folder_model.set_sort_column_id (desktop_sort_by, desktop_sort_type);*/
}

private void on_sort_by (Gtk.Action act, Gtk.RadioAction cur, void *user_data) {
    /*desktop_sort_by = cur.get_current_value();
    _folder_model.set_sort_column_id (desktop_sort_by, desktop_sort_type);*/
}

private void _select_all () {
    
    /**foreach (Desktop.Item item in _grid_items) {
        item.is_selected = true;
        item.redraw (_window);
    }*/
}

private void open_selected_items () {
    
    /**
    List? items;
    
    int n_sels = this.get_selected_items (out items);
    
    List l;

    if (items == null)
        return;

    for (l=items; l; l=l.next) {
        Desktop.Item item = l.data as Desktop.Item;
        l.data = item.fi;
    }
    
    
    // this.launch_files_simple (null, items, pcmanfm_open_folder, null);*/
}

private void _set_focused_item (Desktop.Item item) {
    
    /*if (item == _selected_item)
        return;
    
    // invalidate old focused item if any
    if (_selected_item != null)
        _selected_item.redraw (_window);
    
    // invalidate new focused item
    _selected_item = item;
    if (_selected_item != null)
        _selected_item.redraw (_window);*/
}

private bool is_pos_occupied () {
    
    /* what's the purpose of this ?
    foreach (Desktop.Item fixed in _fixed_items) {
        
        Gdk.Rectangle rect;
        
        fixed.get_item_rect (out rect);
        
        if (rect.intersect (fixed.icon_rect, null)
            || rect.intersect (fixed.text_rect, null))
            return true;
    }*/
    
    return false;
}

private string get_selected_paths () {
/*private Fm.PathList? get_selected_paths() {*/
    
    string files = "";
    
    /*Fm.PathList? files = new Fm.PathList ();
    
    foreach (Desktop.Item item in _grid_items) {
        if (item.is_selected == true)
            files.push_tail (check if null.....item.get_fileinfo ().path);
    }
    
    if (files.is_empty())
        return null;*/
        
    return files;
}


/***********************************************************************************************************************
 * Actions...
 * 
 * 
 **********************************************************************************************************************/
private void on_snap_to_grid (Gtk.Action act) {
    
    /*FmDesktop* desktop = FM_DESKTOP(user_data);
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
    
    queue_layout_items (desktop);*/
}

private void on_fix_pos (Gtk.ToggleAction act) {

    /*FmDesktop* desktop = FM_DESKTOP (user_data);
    
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
    
    save_item_pos (desktop);*/
}


/***********************************************************************************************************************
 * These are original function, I plan to implement these a different way...
 * Grid.append_item () replaces layout_items ()
 * 
 * 
 **********************************************************************************************************************/
private void _layout_items () {
    
    /*List l;
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
    */
    
    return;
}

private Desktop.Item? get_nearest_item (Desktop.Item item, Gtk.DirectionType direction) {
    
    Desktop.Item ret = null;
    
    /*uint min_x_dist;
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
    */
    return ret;
}
/**********************************************************************************************************************/


/***********************************************************************************************************************
 * Load save item positions...
 * 
 * 
 **********************************************************************************************************************/
void on_model_loaded () {
    /**
    int i;
    // the desktop folder is just loaded, apply desktop item positions
    GKeyFile* kf = g_key_file_new();
    for( i = 0; i < n_screens; i++ )
    {
        FmDesktop* desktop = FM_DESKTOP(desktops[i]);
        load_item_pos(desktop, kf);
    }
    g_key_file_free(kf);*/
}

inline void load_item_pos (KeyFile kf) {
    /**char* path = get_config_file(desktop, FALSE);
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
    g_free(path);*/
    
    return;
}

static string get_config_file (bool create_dir) {
    
    string ret = "";
    /**char* dir = pcmanfm_get_profile_dir(create_dir);
    GdkScreen* scr = gtk_widget_get_screen(GTK_WIDGET(desktop));
    int n = gdk_screen_get_number(scr);
    char* path = g_strdup_printf("%s/desktop-items-%d.conf", dir, n);
    g_free(dir);
    return path;*/
    return ret;
}

static void save_item_pos () {
    
    /**GList* l;
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
    g_string_free(buf, TRUE);*/
}
/**********************************************************************************************************************/


/* *********************************************************************************************************************
 * Unused : XLib Atoms...
 * 
 * 
 **********************************************************************************************************************/
Gdk.FilterReturn on_root_event (Gdk.XEvent xevent, Gdk.Event event, void *data) {
    
    Gdk.FilterReturn ret = 0;
    
    /*XPropertyEvent * evt =  (XPropertyEvent*) xevent;
    
    FmDesktop* self = (FmDesktop*)data;
    
    if  (evt.type == PropertyNotify)
    {
        if (evt.atom == XA_NET_WORKAREA)
            update_working_area (self);
    }
    return GDK_FILTER_CONTINUE;*/
    return ret;
}

private inline bool is_atom_in_targets (List? targets, string name) {
/* unused function even in PCManFm...
    
    // doesn't build...
    unowned GLib.List? atoms = (GLib.List?) targets;
    
    foreach (Gdk.Atom atom in atoms) {
    }
    List? l;
    
    for (l = targets; l; l=l.next) {
        
        Gdk.Atom atom = (Gdk.Atom) l.data;
        
        if (Gdk.Atom.intern (name, false) != 0)
            return true;
    }
    */
    return false;
}
/* ********************************************************************************************************************/

