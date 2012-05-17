/*** from pcmanfm ***

public string profile;
public bool daemon_mode = false;
public bool no_desktop = false;
public bool show_desktop = false;
public bool desktop_off = false;
public int show_pref = 0;
public string set_wallpaper;
public string wallpaper_mode;
public string[] files_to_open;
public bool desktop_pref = false;

public const OptionEntry[] opt_entries = {
    
    // options only acceptable by first instance. These options are not passed through IPC
    {"profile",         'p',    0, OptionArg.STRING,            ref profile,
        N_("Name of configuration profile"),
        "<profile name>"},
    
    {"daemon-mode",     'd',    0, OptionArg.NONE,              ref daemon_mode,
        N_("Run as a daemon"),
        null},
    
    {"no-desktop",      '\0',   0, OptionArg.NONE,              ref no_desktop,
        N_("No function. Just to be compatible with nautilus"),
        null},

    // options that are acceptable for every instance and will be passed through IPC.
    {"desktop",         '\0',   0, OptionArg.NONE,              ref show_desktop,
        N_("Launch desktop manager"),
        null},
    
    {"desktop-off",     '\0',   0, OptionArg.NONE,              ref desktop_off,
        N_("Turn off desktop manager if it's running"),
        null},
    
    {"desktop-pref",    '\0',   0, OptionArg.NONE,              ref desktop_pref,
        N_("Open desktop preference dialog"),
        null},
    
    {"set-wallpaper",   'w',    0, OptionArg.FILENAME,          ref set_wallpaper,
        N_("Set desktop wallpaper"),
        N_("<image file>")},
    
    {"wallpaper-mode",  '\0',   0, OptionArg.STRING,            ref wallpaper_mode,
        N_("Set mode of desktop wallpaper. <mode>=(color|stretch|fit|center|tile)"),
        N_("<mode>")},
    
    {"show-pref",       '\0',   0, OptionArg.INT,               ref show_pref,
        N_("Open preference dialog. 'n' is number of the page you want to show (1, 2, 3...)."),
        "n"},
    
    {"",                0,      0, OptionArg.FILENAME_ARRAY,    ref files_to_open,
        null,
        N_("[FILE1, FILE2,...]")},
    
    {null}
};
// {"new-win", '\0', 'n', OptionArg.NONE, ref new_win, N_("Open new window"), null},
// { "find-files", 'f', 0, OptionArg.NONE, ref find_files, N_("Open Find Files utility"), null},

private const string[] valid_wallpaper_modes = {"color", "stretch", "fit", "center", "tile"}; ***/






// grid selecttions...

    /***
private void _on_action_select_all (Gtk.Action action) {
    
    int i;
    for(i=0; i < n_screens; ++i)
    {
        FmDesktop* desktop = desktops[i];
        select_all(desktop);
    }
}
    ***/

    /***
private void _on_action_invert_select (Gtk.Action action) {
    
    int i;
    for(i=0; i < n_screens; ++i)
    {
        FmDesktop* desktop = desktops[i];
        GList* l;
        for(l=desktop->items;l;l=l->next)
        {
            FmDesktopItem* item = (FmDesktopItem*)l->data;
            item->is_selected = !item->is_selected;
            invalidate_rect(desktop, item);
        }
}
    }***/



// old code...
/*******************************************************************************************
 * Desktop background...
 * 
 * 
 ***************************************************************************************
public void set_background (bool set_root = false) {
    
    Gdk.Window window = this.get_window ();
    
    Fm.WallpaperMode wallpaper_mode = global_config.wallpaper_mode;
    
    Gdk.Pixbuf? pix = null;
    
    // Set A Wallpaper (Not Implemented Yet...)
    if (wallpaper_mode != Fm.WallpaperMode.COLOR) {
        
        try {
            
            pix = new Gdk.Pixbuf.from_file (global_config.wallpaper);
        
        } catch (Error e) {
        }

        this._set_wallpaper (pix);

    // Set A Solid Color...
    } else {

        // The solid color for the desktop background
        Gdk.Color bg = global_config.color_background;
        
        // GTK3_TODO
        
        //Gdk.rgb_find_color (this.get_colormap (), ref bg);
        
        //window.set_back_pixmap (null, false);
        
        // DEPRECATED Use gdk_window_set_background_rgba() instead
        window.set_background (bg);
        
        if (set_root) {
            Gdk.Window root = this.get_screen ().get_root_window ();
            
            //root.set_back_pixmap (null, false);
            
            // DEPRECATED Use gdk_window_set_background_rgba() instead
            root.set_background (bg);
            //root.clear ();
        }
        
        //window.clear ();
        window.invalidate_rect (null, true);
        return;
    }
    
    return;
}***/

/***
 private void _set_wallpaper (Gdk.Pixbuf? pix) {

     Set the wallpaper (not implemented yet...)

    int dest_w;
    int dest_h;
    
    int src_w = pix.get_width ();
    int src_h = pix.get_height ();
    
    Gdk.Window window = this.get_window ();
//            Gdk.Pixmap pixmap;

    if (wallpaper_mode == FM_WP_TILE) {
        dest_w = src_w;
        dest_h = src_h;
    
//                pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
    
    } else {
        
        Gdk.Screen screen = widget.get_screen ();
        dest_w = gdk_screen_get_width (screen);
        dest_h = gdk_screen_get_height (screen);
        
//                pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
    }

    if (gdk_pixbuf_get_has_alpha(pix)
        || wallpaper_mode == FM_WP_CENTER
        || wallpaper_mode == FM_WP_FIT) {
        
        gdk_gc_set_rgb_fg_color (desktop->gc, &desktop_bg);
        
        gdk_draw_rectangle (pixmap, desktop->gc, true, 0, 0, dest_w, dest_h);
    
    }

    GdkPixbuf *scaled;
    
    switch (wallpaper_mode) {
        
        case FM_WP_TILE:
        
            gdk_draw_pixbuf (pixmap, desktop->gc, pix, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
        
        break;
        
        case FM_WP_STRETCH:
            
            if (dest_w == src_w && dest_h == src_h)
                scaled = (GdkPixbuf*)g_object_ref (pix);
            else
                scaled = gdk_pixbuf_scale_simple (pix, dest_w, dest_h, GDK_INTERP_BILINEAR);
            
            gdk_draw_pixbuf (pixmap, desktop->gc, scaled, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
        
            g_object_unref (scaled);
        
        break;
        
        case FM_WP_FIT:
        
            if (dest_w != src_w || dest_h != src_h) {
                
                double w_ratio = (float) dest_w / src_w;
                double h_ratio = (float) dest_h / src_h;
                double ratio = MIN (w_ratio, h_ratio);
                
                if (ratio != 1.0) {
                    src_w *= ratio;
                    src_h *= ratio;
                    
                    scaled = gdk_pixbuf_scale_simple (pix, src_w, src_h, GDK_INTERP_BILINEAR);
                    
                    g_object_unref (pix);
                    
                    pix = scaled;
                }
            }
        
        // continue to execute code in case FM_WP_CENTER
        case FM_WP_CENTER: {
            
            int x;
            int y;
            
            x = (dest_w - src_w) / 2;
            y = (dest_h - src_h) / 2;
            
            gdk_draw_pixbuf (pixmap, desktop->gc, pix, 0, 0, x, y, -1, -1, GDK_RGB_DITHER_NORMAL, 0, 0);
        }
        break;
    }
    
    gdk_window_set_back_pixmap (root, pixmap, false);
    gdk_window_set_back_pixmap (window, null, true);
    
    if (pix)
        g_object_unref (pix);
    
    XLib.set_pixmap (GtkWidget* widget, GdkPixmap* pixmap);
    
}***/


// old code...
private void _create_popup_menu (Gdk.EventButton evt) {
    
    /*** merge some specific menu items for folders
    if (_file_menu.is_single_file_type () && fi.is_dir ()) {
        act_grp.add_actions (folder_menu_actions, _file_menu);
        ui.add_ui_from_string (folder_menu_xml, -1);
    }
    act_grp.add_actions (desktop_icon_actions, this);
    Gtk.UIManager ui = _file_menu.get_ui ();
    Fm.FileInfo? fi = files.peek_head ();
    ***/
/**            
    Fm.FileInfoList<Fm.FileInfo>? files = _grid.get_selected_files ();
    if (files == null)
        return;
    
    // Create The Popup Menu.
    _file_menu = new Fm.FileMenu.for_files (this, files, Fm.Path.get_desktop (), false);
    _file_menu.set_folder_func ((Fm.LaunchFolderFunc) this.action_open_folder_func);
    Gtk.ActionGroup act_grp = _file_menu.get_action_group ();
    act_grp.set_translation_domain ("");
    
    _popup_menu = _file_menu.get_menu ();
**/

    if (_file_popup == null)
        _file_popup = new Desktop.FilePopup ();
    
    Fm.FileInfoList<Fm.FileInfo>? files = _grid.get_selected_files ();
    if (files == null)
        return;
    
    Gtk.Menu menu = _file_popup.get_menu ((Gtk.Widget) this, Fm.Path.get_desktop(), files, this.action_open_folder_func);
    
    if (menu != null)
        menu.popup (null, null, null, 3, evt.time);
    
    return;
}






/***
char*                 desktop_font;
private PangoFontDescription* font_desc = null;
    if (desktop_font)
        font_desc = pango_font_description_from_string (desktop_font);
    
wallpaper_changed = g_signal_connect (global_config,
                                      "changed::wallpaper",
                                      G_CALLBACK(on_wallpaper_changed),
                                      NULL);
desktop_text_changed = g_signal_connect (global_config,
                                         "changed::desktop_text",
                                         G_CALLBACK(on_desktop_text_changed),
                                         NULL);
desktop_font_changed = g_signal_connect (global_config,
                                         "changed::desktop_font",
                                         G_CALLBACK(on_desktop_font_changed),
                                         NULL);
big_icon_size_changed = g_signal_connect (global_config,
                                          "changed::big_icon_size",
                                          G_CALLBACK(on_big_icon_size_changed),
                                          NULL);
                                          
global_config.wallpaper_changed.disconnect ();
global_config.big_icon_size_changed.disconnect ();
global_config.desktop_text_changed.disconnect ();
global_config.desktop_font_changed.disconnect ();
private uint big_icon_size_changed = 0;
private uint desktop_text_changed = 0;
private uint desktop_font_changed = 0;
***/
        
        
        
        
        
        
        
        
        
/*******************************************************************************************
private void _on_action_new_folder (Gtk.Action action) {
    
    Utils.filemanager_new_document (Fm.Path.get_desktop(), Utils.NewFileNameType.FOLDER);
}

private void _on_action_new_file (Gtk.Action action) {
    
    Utils.filemanager_new_document (Fm.Path.get_desktop(), Utils.NewFileNameType.FILE);
}

private void _on_action_paste (Gtk.Action action) {
    
    Fm.Path path = Fm.Path.get_desktop ();
    Fm.Clipboard.paste_files (this, path);
}

private void _on_action_desktop_settings (Gtk.Action action) {
    return;
}***/







/***************************************************************************************************************
 * Desktop Configuration handlers.
 *
 **************************************************************************************************************/
private void _on_wallpaper_changed () {
    
    /***********************************************************************************************************
     * The user changed the wallpaper in the desktop configuration dialog.
     * 
     * 
    
    for (int i=0; i < _n_screens; ++i)
        desktops[i].update_background ();
    
    */
}





private void _on_big_icon_size_changed () {
    
    /***********************************************************************************************************
     * The user changed the icon size in the desktop configuration dialog.
     * 
     * 
    
    global_model.set_icon_size (global_config.big_icon_size);
    
    this._reload_icons();
    */
    
    
}

private void _on_desktop_text_changed () {

    /***********************************************************************************************************
     * Handle text changes...
     * FIXME_pcm: we only need to redraw text lables
    
    for (int i=0; i < _n_screens; ++i)
        desktops[i].queue_draw ();
    
    */
}

private void _on_desktop_font_changed () {
    
    /***********************************************************************************************************
     * Handle font change...
     * 
     * 
    font_desc = null;
    // FIXME_pcm: this is a little bit dirty
    if (font_desc)
        pango_font_description_free (font_desc);

    if (desktop_font) {
        
        font_desc = new Pango.FontDescription.from_string (desktop_font);
        
        if (font_desc) {
            int i;
            for (i=0; i < _n_screens; ++i) {
                FmDesktop* desktop = desktops[i];
                
                Pango.Context pc = this.get_pango_context ();
                pc.set_font_description (font_desc);
                this.grid._pango_layout.context_changed ();
                
                this.queue_resize ();
                // layout_items(desktop);
                // this.queue_draw(desktops[i]);
            }
        }
        
    } else {
        font_desc = null;
    }
    */
    
    return;
}





/***
private void _append_item (Desktop.Item item) {
    
    uint num_items = _grid_items.length ();
    
    if (num_items > (_num_cell.x * _num_cell.y)) {
        return; // The grid si full...
    
    // The list is empty, set the item on the first grid cell (0, 0)
    } else if (num_items == 0) {
    
        item.cell_pos.x = 0;
        item.cell_pos.y = 0;
        
        this._calc_item_size (item);
        _grid_items.append (item);
        
        return;
    }
    
    unowned List<Desktop.Item>? last = _grid_items.last ();
    
    Desktop.Item? previous = last.data as Desktop.Item;
    
    item.cell_pos.y = previous.cell_pos.y + 1;
    item.cell_pos.x = previous.cell_pos.x;
    
    // If current vertical row is full, append on the next row
    if (item.cell_pos.y >= _num_cell.y) {
        
        item.cell_pos.y = 0;
        item.cell_pos.x = previous.cell_pos.x + 1;
    }
    
    this._calc_item_size (item);
    _grid_items.append (item);
                
    return;
} ***/


private bool _on_key_press (Gdk.EventKey evt) {

    /***********************************************************************************************************
     * 
    Desktop.Item item;
    int modifier =  (evt.state &  (GDK_SHIFT_MASK | GDK_CONTROL_MASK | GDK_MOD1_MASK));
    
    Fm.PathList sels;
    
    switch  (evt.keyval) {
        
        case GDK_KEY_Menu: {
            
            Fm.FileInfoList files = fm_desktop_get_selected_files (desktop);
            if (files) {
                popup_menu(desktop, evt);
                fm_list_unref(files);
            } else {
                if (! show_wm_menu)
                    gtk_menu_popup (GTK_MENU(desktop_popup), null, null, null, null, 3, evt.time);
            }
            return true;
        }
        
        case GDK_KEY_Left:
            item = get_nearest_item (this._focused, GTK_DIR_LEFT);
            if (item) {
                if (modifier == 0) {
                    desktop.deselect_all ();
                    item.is_selected = true;
                }
                desktop.set_focused_item (item);
            }
            return true;
        break;
        
        case GDK_KEY_Right:
            item = get_nearest_item (desktop, desktop->focus, GTK_DIR_RIGHT);
            if (item) {
                if (modifier == 0) {
                    deselect_all(desktop);
                    item->is_selected = true;
                }
                set_focused_item(desktop, item);
            }
            return true;
        break;
        
        case GDK_KEY_Up:
            item = get_nearest_item (desktop, desktop->focus, GTK_DIR_UP);
            if (item) {
                if (modifier == 0) {
                    deselect_all(desktop);
                    item->is_selected = true;
                }
                set_focused_item(desktop, item);
            }
            return true;
        break;
        
        case GDK_KEY_Down:
            item = get_nearest_item (desktop, desktop->focus, GTK_DIR_DOWN);
            if (item) {
                if (modifier == 0) {
                    deselect_all(desktop);
                    item->is_selected = true;
                }
                set_focused_item(desktop, item);
            }
            return true;
        break;
        
        case GDK_KEY_space:
            if ((modifier & GDK_CONTROL_MASK) && desktop->focus) {
                desktop->focus->is_selected = !desktop->focus->is_selected;
                desktop->focus.invalidate_rect ();
            }
            else
                activate_selected_items(desktop);
            return true;
        break;
        
        case GDK_KEY_Return:
            if (modifier & GDK_MOD1_MASK) {
                Fm.FileInfoList infos = desktop.get_selected_files ();
                if (infos) {
                    desktop.show_file_properties (infos);
                    return true;
                }
            } else {
                activate_selected_items (desktop);
                return true;
            }
        break;
        
        case GDK_KEY_x:
            if (modifier & GDK_CONTROL_MASK) {
                sels = fm_desktop_get_selected_paths (desktop);
                fm_clipboard_cut_files (desktop, sels);
            }
        break;
        
        case GDK_KEY_c:
            if (modifier & GDK_CONTROL_MASK) {
                sels = fm_desktop_get_selected_paths (desktop);
                fm_clipboard_copy_files (desktop, sels);
            }
        break;
        
        case GDK_KEY_v:
            if (modifier & GDK_CONTROL_MASK)
                fm_clipboard_paste_files (GTK_WIDGET(desktop), fm_path_get_desktop());
        break;
        
        case GDK_KEY_F2:
            sels = fm_desktop_get_selected_paths(desktop);
            if (sels) {
                fm_rename_file (GTK_WINDOW(desktop), fm_list_peek_head(sels));
            }
        break;
        
        case GDK_KEY_Delete:
            sels = fm_desktop_get_selected_paths(desktop);
            if (sels) {
                if (modifier & GDK_SHIFT_MASK)
                    fm_delete_files (GTK_WINDOW(desktop), sels);
                else
                    fm_trash_or_delete_files (GTK_WINDOW(desktop), sels);
            }
        break;
    }
    return base.key_press_event (evt);
    ***********************************************************************************************************/
    return false;
}

private void _on_screen_size_changed (Gdk.Screen screen) {
    //this.resize (screen.get_width (), screen.get_height ());
}

private void _on_style_set (Gtk.Style prev) {
    
    /*
    Pango.Context pc = this.get_pango_context ();
    if (font_desc)
        pc.set_font_description (font_desc);
    this.grid._pango_layout.context_changed ();
    */
}

private void _on_direction_changed (Gtk.TextDirection prev) {
    
    /*
    Pango.Context pc = this.get_pango_context ();
    this.grid._pango_layout.context_changed ();
    this.queue_layout_items ();
    */
}

private bool _on_focus_in (Gdk.EventFocus evt) {
    
    /*
    this.SET_FLAGS (GTK_HAS_FOCUS);
    if (this._focused == false && this.items != null)
        this._focused = this.items.data as Desktop.Item;
    if (this._focused)
        focus.invalidate_rect ();
    */
    return false;
}

private bool _on_focus_out (Gdk.EventFocus evt) {
    
    /*
    if (this._focused) {
        this.UNSET_FLAGS (GTK_HAS_FOCUS);
        focus.invalidate_rect ();
    }
    */
    return false;
}


private bool _on_single_click_timeout () {
    return false;
}
private bool _on_single_click_timeout_temp () {
    
    /***********************************************************************************************************
     * 
    Gdk.EventButton evt;
    Gdk.Window window;
    int x;
    int y;

    window = this.get_window ();
    // generate a fake button press
    // FIXME_pcm: will this cause any problem?
    evt.type = GDK_BUTTON_PRESS;
    evt.window = window;
    window.get_pointer (ref x, ref y, ref evt.state);
    
    evt.x = x;
    evt.y = y;
    evt.state |= GDK_BUTTON_PRESS_MASK;
    evt.state &= ~GDK_BUTTON_MOTION_MASK;
    this.on_button_press (evt);
    
    evt.type = GDK_BUTTON_RELEASE;
    evt.state &= ~GDK_BUTTON_PRESS_MASK;
    evt.state |= ~GDK_BUTTON_RELEASE_MASK;
    this.on_button_release (evt);

    this.single_click_timeout_handler = 0;
    
    ***********************************************************************************************************/
    
    return false;
}


/*
#define INIT_BOOL(b, st, name, changed_notify)  init_bool(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_COMBO(b, st, name, changed_notify) init_combo(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_ICON_SIZES(b, name) init_icon_sizes(b, #name, G_STRUCT_OFFSET(FmConfig, name))
#define INIT_COLOR(b, st, name, changed_notify)  init_color(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_SPIN(b, st, name, changed_notify)  init_spin(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_ENTRY(b, st, name, changed_notify)  init_entry(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
*/

private void _on_action_desktop_settings_temp (Gtk.Action action) {
    
    /*
    if(!desktop_pref_dlg)
    {
        GtkBuilder* builder = gtk_builder_new();
        GtkWidget* item, *img_preview;
        gtk_builder_add_from_file(builder, PACKAGE_UI_DIR "/desktop-pref.ui", null);
        desktop_pref_dlg = gtk_builder_get_object(builder, "dlg");

        item = gtk_builder_get_object(builder, "wallpaper");
        g_signal_connect(item, "file-set", G_CALLBACK(on_wallpaper_set), null);
        img_preview = gtk_image_new();
        gtk_misc_set_alignment(GTK_MISC(img_preview), 0.5, 0.0);
        gtk_widget_set_size_request( img_preview, 128, 128 );
        gtk_file_chooser_set_preview_widget( (GtkFileChooser*)item, img_preview );
        g_signal_connect( item, "update-preview", G_CALLBACK(on_update_img_preview), img_preview );
        if(app_config->wallpaper)
            gtk_file_chooser_set_filename(GTK_FILE_CHOOSER(item), app_config->wallpaper);

        INIT_COMBO(builder, FmAppConfig, wallpaper_mode, "wallpaper");
        INIT_COLOR(builder, FmAppConfig, desktop_bg, "wallpaper");

        INIT_COLOR(builder, FmAppConfig, desktop_fg, "desktop_text");
        INIT_COLOR(builder, FmAppConfig, desktop_shadow, "desktop_text");

        INIT_BOOL(builder, FmAppConfig, show_wm_menu, null);

        item = gtk_builder_get_object(builder, "desktop_font");
        if(app_config->desktop_font)
            gtk_font_button_set_font_name(GTK_FONT_BUTTON(item), app_config->desktop_font);
        g_signal_connect(item, "font-set", G_CALLBACK(on_desktop_font_set), null);

        g_signal_connect(desktop_pref_dlg, "response", G_CALLBACK(on_response), &desktop_pref_dlg);
        g_object_unref(builder);

        pcmanfm_ref();
        g_signal_connect(desktop_pref_dlg, "destroy", G_CALLBACK(pcmanfm_unref), null);
    }
    
    gtk_window_present(GTK_WINDOW(desktop_pref_dlg));
    */
    
}


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

