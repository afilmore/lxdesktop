/***********************************************************************************************************************
 * TEMP.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: These are currently not translated to Vala, commented or simply unused functions. Most of these are empty
 * and useless but this file is included in the program and built with it. Some of these will never be used, but some
 * may be translated, adapted and moved into the application's classes.
 * 
 * 
 **********************************************************************************************************************/

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
        /*******************************************************************************************
         * Gtk2 Functions... Will Be Removed...
         * 
         * 
         * 
         ******************************************************************************************/
        #if ENABLE_GTK2
        private void _on_gtk2_size_allocate (Gdk.Rectangle rect) {
            
            /*** stdout.printf ("_on_size_allocate: %i, %i, %i, %i\n", rect.x, rect.y, rect.width, rect.height); ***/
            
            // Setup the size of items.
            _grid.init_layout (rect);
            
            // Scale the wallpaper
            if (base.is_realized () == true
                && global_config.wallpaper_mode != Fm.WallpaperMode.COLOR
                && global_config.wallpaper_mode != Fm.WallpaperMode.TILE) {
                
                this.set_background ();
            }

            base.size_allocate (rect);
        }

        private void _on_gtk2_size_request (Gtk.Requisition req) {
            
            Gdk.Screen screen = this.get_screen ();
            if (_debug_mode == true ) {
                req.width = (screen.get_width () /4) *3;
                req.height = (screen.get_height () /4) *3;
            } else {
                req.width = screen.get_width ();
                req.height = screen.get_height ();
            }
            
            /*** stdout.printf ("_on_size_request: %i, %i\n", req.width, req.height); ***/
        }

        private bool _on_gtk2_expose (Gdk.EventExpose evt) {
            
            /*** stdout.printf ("_on_expose: visible=%u, mapped=%u\n",
                                (uint) this.get_visible (),
                                (uint) this.get_mapped ()); ***/
            
            if (this.get_visible () == false || this.get_mapped () == false)
                return true;

            Cairo.Context cr = Gdk.cairo_create (this.get_window ());
            
            // Rubber banding
            if (_rubber_started == true)
                this._paint_rubber_banding_rect (cr, evt.area);

            // Draw desktop icons
            this._grid.draw_items_in_rect (cr, evt.area);
            
            return true;
        }

        private void _gtk2_set_background (bool set_root = false) {
            
            Gdk.Window window = this.get_window ();
            
            Fm.WallpaperMode wallpaper_mode = global_config.wallpaper_mode;
            Gdk.Pixbuf? pix = null;
            try {
                pix = new Gdk.Pixbuf.from_file (global_config.wallpaper);
            } catch (Error e) {
            }
            
            if (wallpaper_mode == Fm.WallpaperMode.COLOR
               || global_config.wallpaper == ""
               || (pix == null)) {
                
                // The solid color for the desktop background
                Gdk.Color bg = global_config.color_background;
                
                Gdk.rgb_find_color (this.get_colormap (), ref bg);
                
                window.set_back_pixmap (null, false);
                window.set_background (bg);
                
                if (set_root) {
                    Gdk.Window root = this.get_screen ().get_root_window ();
                    root.set_back_pixmap (null, false);
                    root.set_background (bg);
                    root.clear ();
                }
                window.clear ();
                window.invalidate_rect (null, true);
                return;
            }
            
            this._set_wallpaper ();
            
            return;
        }
        #endif
        #if ENABLE_GTK2
        private void _gtk2_draw_item (Desktop.Item item, Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            /*** stdout.printf ("item.draw: %i, %i, %i, %i\n",
                                expose_area.x,
                                expose_area.y,
                                expose_area.width,
                                expose_area.height); ***/
            
            Gtk.CellRendererState state = 0;
            
            // Selected item
            if (item.is_selected == true || item == _desktop.drop_hilight)
                state = Gtk.CellRendererState.SELECTED;
            
            
            /*******************************************************************
             * Draw the icon...
             * 
             * 
             ******************************************************************/
            this._icon_renderer.set ("pixbuf", item.icon, "info", item.get_fileinfo (), null);
            this._icon_renderer.render (_window,
                                        _desktop,
                                        item.icon_rect,
                                        item.icon_rect,
                                        expose_area,
                                        state);
            
            _pango_layout.set_text ("", 0);
            _pango_layout.set_width ((int) this._pango_text_w);
            _pango_layout.set_height ((int) this._pango_text_h);

            string disp_name = item.get_disp_name ();
            _pango_layout.set_text (disp_name, -1);

            /*** Do we need to cache this ? ***/
            int text_x = (int) item.pixel_pos.x + (_cell_width - (int) _text_w) / 2 + 2;
            int text_y = (int) item.icon_rect.y + item.icon_rect.height + 2;

            // Draw background for text label
            Gtk.Style style = _desktop.get_style ();
            Gdk.Color fg;
            
            // Selected item
            if (state == Gtk.CellRendererState.SELECTED) {
                
                cr.save ();
                Gdk.cairo_rectangle (cr, item.text_rect);
                Gdk.cairo_set_source_color (cr, style.bg[Gtk.StateType.SELECTED]);
                cr.clip ();
                cr.paint ();
                cr.restore ();
                
                fg = style.fg[Gtk.StateType.SELECTED];
                
            // Normal item / text shadow
            } else {
                
                _gc.set_rgb_fg_color (global_config.color_shadow);
                Gdk.draw_layout (_window,
                                 this._gc,
                                 text_x + 1,
                                 text_y + 1,
                                 this._pango_layout);
                fg = global_config.color_text;
            }
            
            // Real text
            _gc.set_rgb_fg_color (fg);
            
            Gdk.draw_layout (_window,
                             this._gc,
                             text_x,
                             text_y,
                             this._pango_layout);
            _pango_layout.set_text ("", 0);

            // Draw a selection rectangle for the selected item
            if (item == _selected_item && _desktop.has_focus != 0) {
                
                Gtk.paint_focus (style,
                                 _window,
                                 _desktop.get_state (),
                                 expose_area,
                                 _desktop,
                                 "icon_view",
                                 item.text_rect.x,
                                 item.text_rect.y,
                                 item.text_rect.width,
                                 item.text_rect.height);
            }
        }
        #endif            


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

private void _set_wallpaper_temp () {
    
    /* Set the wallpaper (not implemented yet...)

    int dest_w;
    int dest_h;
    
    int src_w = pix.get_width ();
    int src_h = pix.get_height ();
    
    Gdk.Window window = this.get_window ();
    Gdk.Pixmap pixmap;

    if (wallpaper_mode == FM_WP_TILE) {
        dest_w = src_w;
        dest_h = src_h;
        pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
    } else {
        GdkScreen* screen = gtk_widget_get_screen (widget);
        dest_w = gdk_screen_get_width (screen);
        dest_h = gdk_screen_get_height (screen);
        pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
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
            g_object_unref(scaled);
        
        break;
        
        case FM_WP_FIT:
            if (dest_w != src_w || dest_h != src_h) {
                
                gdouble w_ratio = (float)dest_w / src_w;
                gdouble h_ratio = (float)dest_h / src_h;
                gdouble ratio = MIN(w_ratio, h_ratio);
                
                if (ratio != 1.0) {
                    src_w *= ratio;
                    src_h *= ratio;
                    scaled = gdk_pixbuf_scale_simple(pix, src_w, src_h, GDK_INTERP_BILINEAR);
                    g_object_unref(pix);
                    pix = scaled;
                }
            }
        
        // continue to execute code in case FM_WP_CENTER
        case FM_WP_CENTER: {
            int x, y;
            x = (dest_w - src_w)/2;
            y = (dest_h - src_h)/2;
            gdk_draw_pixbuf (pixmap, desktop->gc, pix, 0, 0, x, y, -1, -1, GDK_RGB_DITHER_NORMAL, 0, 0);
        }
        break;
    }
    
    gdk_window_set_back_pixmap(root, pixmap, false);
    gdk_window_set_back_pixmap(window, null, true);
    if (pix)
        g_object_unref (pix);
    
    XLib.set_pixmap (GtkWidget* widget, GdkPixmap* pixmap);*/
    
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


/***********************************************************************************************************************
 * Grid Model Functions....
 * 
 * 
 **********************************************************************************************************************/
public void on_row_changed (Gtk.TreePath tp, Gtk.TreeIter it) {
    
    stdout.printf ("on_row_changed\n");
    
    return; // needs testing...

    /********************************************
     * We don't have the item's TreeIter... :(
     * 
     * 
    foreach (Desktop.Item item in _grid_items) {
        
        if (item.it.user_data == it.user_data) {
            
            if (item.icon != null)
                item.icon = null; // g_object_unref (item.icon);
            
            Fm.FileInfo fi; // must set the new fileinfo ????
            
            global_model.get (it, Fm.FileColumn.ICON, out item.icon, Fm.FileColumn.INFO, out fi, -1);
                    
            item.invalidate_rect (_window);
            
            // FIXME_pcm: check if sorting of files is changed.
            // queue_layout_items(desktop); // needed ???
            
            return;
        }
        
        
    }*/
    
    return;
}

public void on_rows_reordered (Gtk.TreePath parent_tp, Gtk.TreeIter? parent_it, void* new_order) {
    
    stdout.printf ("on_rows_reordered\n");
    
    /***********************************************************************************************************
     * Not emplemented yet......
     * 
     * 
    Gtk.TreeIter it;
    
    List new_items = null;
    
    if (mod.get_iter_first (out it) == null)
        return;
    
    do {
        List l;
        for (l = desktop.items; l; l=l.next) {
            Desktop.Item item = l.data as Desktop.Item;
            if (item.it.user_data == it.user_data) {
                desktop.items = g_list_remove_link (desktop.items, l);
                new_items = g_list_concat (l, new_items);
                break;
            }
        }
    } while (mod.iter_next (out it));
    
    desktop.items = g_list_reverse (new_items);
    queue_layout_items (desktop);
    
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
        item.invalidate_rect (_window);
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
        _selected_item.invalidate_rect (_window);
    
    // invalidate new focused item
    _selected_item = item;
    if (_selected_item != null)
        _selected_item.invalidate_rect (_window);*/
}


// List fixed_items; // how to manage fixed position items ???


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

    /*List items = this.get_selected_items (null);
    List l;
    
    if (act.get_active()) {
        
        for (l = items; l; l=l.next) {
            
            Desktop.Item item = l.data as Desktop.Item;
            
            if (item.fixed_pos == false) {
                
                item.fixed_pos = true;
                desktop_window.fixed_items = desktop_window.fixed_items.prepend (item);
            }
        }
        
    } else {
        
        for (l = items; l; l=l.next) {
            
            Desktop.Item item = l.data as Desktop.Item;
            item.fixed_pos = false;
            desktop_window.fixed_items = desktop_window.fixed_items.remove (item);
        }
        desktop_window.layout_items ();
    }
    
    desktop_window.save_item_pos ();*/
    
    return;
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

