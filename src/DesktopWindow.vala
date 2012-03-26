/***********************************************************************************************************************
 * DesktopWindow.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental rewrite of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: A grid to manage the desktop layout.
 * 
 * 
 **********************************************************************************************************************/


namespace Desktop {
    
    public class Window : Gtk.Window {
        
        bool _debug_mode = false;
        
        // The desktop grid
        private Desktop.Grid _grid;
        
        // Rubber banding / Drag And Drop
        private bool    _rubber_started = false;
        private double  _rubber_bending_x = 0;
        private double  _rubber_bending_y = 0;
        private bool    _button_pressed = false;
        private double  _drag_start_x = 0;
        private double  _drag_start_y = 0;
        private bool    _dnd_started = false;
        
        
        /***************************************************************************************************************
         * Single click...
         * 
         * 
        uint single_click_timeout_handler;
        private GdkCursor* hand_cursor = null;
        hand_cursor = gdk_cursor_new (GDK_HAND2);
       
        ***************************************************************************************************************/

        // show the window manager menu
        private bool _show_wm_menu = false;
        private Gtk.Menu _desktop_popup;
        
        public Window () {
            
            this.destroy.connect (Gtk.main_quit);
            
            this.realize.connect (_on_realize);
            this.size_allocate.connect (_on_size_allocate);
            this.size_request.connect (_on_size_request);
            
            this.expose_event.connect (_on_expose);
            
            this.button_press_event.connect (_on_button_press);
            this.button_release_event.connect (_on_button_release);
            this.motion_notify_event.connect (_on_motion_notify);
            
            
            /***********************************************************************************************************
             * Handlers to connect when ready...
             *
             * 
            this.leave_notify_event.connect (on_leave_notify);
            this.key_press_event.connect (on_key_press);
            this.style_set.connect (on_style_set);
            this.direction_changed.connect (on_direction_changed);
            this.focus_in_event.connect (on_focus_in);
            this.focus_out_event.connect (on_focus_out);
            
            this.delete_event.connect ((DeleteEvtHandler) Gtk.true);

            this.drag_motion.connect (on_drag_motion);
            this.drag_drop.connect (on_drag_drop);
            this.drag_data_received.connect (on_drag_data_received);
            this.drag_leave.connect (on_drag_leave);
            
            ***********************************************************************************************************/
            
        }
        
        ~Window () {
            
            /***********************************************************************************************************
             * Is it needed to disconnect handlers ?
             * 
            Gdk.Screen screen = this.get_screen ();

            screen.get_root_window ().remove_filter (on_root_event);

            g_signal_handlers_disconnect_by_func(global_model, on_row_inserted, self);
            g_signal_handlers_disconnect_by_func(global_model, on_row_deleted, self);
            g_signal_handlers_disconnect_by_func(global_model, on_row_changed, self);
            g_signal_handlers_disconnect_by_func(global_model, on_rows_reordered, self);

            if (this.single_click_timeout_handler)
                Source.remove (this.single_click_timeout_handler);

            ***********************************************************************************************************/
        }


        /***************************************************************************************************************
         * Widget Creation and Sizing...
         * 
         **************************************************************************************************************/
        public bool create (bool debug = false) {
            
            _debug_mode = debug;
            
            Gdk.Screen screen = this.get_screen ();

            _grid = new Desktop.Grid (this, debug);
            
            if (_debug_mode) {
                
                /*******************************************************************************************************
                 * Debug mode, show the desktop in a regular window, very handy :)
                 *
                *******************************************************************************************************/
                this.set_default_size ((screen.get_width() / 4) * 3, (screen.get_height() / 4) * 3);
                this.set_position (Gtk.WindowPosition.CENTER);
                this.set_app_paintable (true);

            } else {
                
                /*******************************************************************************************************
                 * This is the normal running mode, full screen
                 *
                *******************************************************************************************************/
                this.set_default_size (screen.get_width(), screen.get_height());
                this.move (0, 0);
                this.set_app_paintable (true);
                this.set_type_hint (Gdk.WindowTypeHint.DESKTOP);
                
            }
            
            this.add_events (  Gdk.EventMask.POINTER_MOTION_MASK
                             | Gdk.EventMask.BUTTON_PRESS_MASK
                             | Gdk.EventMask.BUTTON_RELEASE_MASK
                             | Gdk.EventMask.KEY_PRESS_MASK
                             | Gdk.EventMask.PROPERTY_CHANGE_MASK);

            // connect model's custom signals.
            global_model.row_inserted.connect (this.get_grid ().on_row_inserted);
            global_model.row_deleted.connect (this.get_grid ().on_row_deleted);
            global_model.row_changed.connect (this.get_grid ().on_row_changed);
            global_model.rows_reordered.connect (this.get_grid ().on_rows_reordered);
            
            
            /***********************************************************************************************************
             * Setup root window events.
             * 
            Gdk.Window root = screen.get_root_window ();
            root.set_events (root.get_events () | GDK_PROPERTY_CHANGE_MASK);
            root.add_filter (on_root_event);
            screen.size_changed.connect (on_screen_size_changed);
            */
            
            this._init_drag_and_drop ();
            
            this.realize ();
            this.show_all ();
            
            if (_debug_mode == false)
                this.get_window ().lower();

            return true;
        }
        
        public Desktop.Grid? get_grid () {
            return _grid;
        }
        

        /***************************************************************************************************************
         * Working area, Desktop background...
         * 
         **************************************************************************************************************/
        public void update_background () {
            
            Gdk.Window window = this.get_window ();
            Gdk.Window root = this.get_screen ().get_root_window ();

            Gdk.Pixbuf? pix;
            if (global_config.wallpaper_mode == WallpaperMode.FM_WP_COLOR
               || global_config.wallpaper == ""
               || (pix = new Gdk.Pixbuf.from_file (global_config.wallpaper)) == null) {
                
                Gdk.Color bg = global_config.desktop_bg;
                
                // GTK3 MIGRATION
                Gdk.rgb_find_color (this.get_colormap (), ref bg);
                
                window.set_back_pixmap (null, false);
                window.set_background (bg);
                
                root.set_back_pixmap (null, false);
                root.set_background (bg);
                root.clear ();
                window.clear ();
                window.invalidate_rect (null, true);
                return;
            }
            
            // Set the wallpaper (not implemented yet...)
            XLib.set_wallpaper ();
            
            return;
        }
        
        
        /***************************************************************************************************************
         * Private members...
         * 
         * 
         * 
         **************************************************************************************************************/
        private void _init_drag_and_drop () {
            // Init Drag And Drop...
            return;
        }
        
        private void _on_realize () {
            
            //stdout.printf ("_on_realize\n");
            
            base.realize ();
            
            // GTK3_MIGRATION
            _grid.init_gc (this.get_window());
            
            this.set_resizable (false);
            
            if (_debug_mode == false) {
                this.set_skip_pager_hint (true);
                this.set_skip_taskbar_hint (true);
            }
            
            this.update_background ();
        }

        private void _on_size_allocate (Gdk.Rectangle rect) {
            
            //stdout.printf ("_on_size_allocate: %i, %i, %i, %i\n", rect.x, rect.y, rect.width, rect.height);
            
            // setup the size of items.
            _grid.init_layout (rect);
            
            //  scale the wallpaper
            if (base.is_realized () == true
                && global_config.wallpaper_mode != WallpaperMode.FM_WP_COLOR
                && global_config.wallpaper_mode != WallpaperMode.FM_WP_TILE) {
                
                this.update_background ();
            }

            base.size_allocate (rect);
        }

        private void _on_size_request (Gtk.Requisition req) {
            
            
            Gdk.Screen screen = this.get_screen ();
            if (_debug_mode == true ) {
                req.width = (screen.get_width () /4) *3;
                req.height = (screen.get_height () /4) *3;
            } else {
                req.width = screen.get_width ();
                req.height = screen.get_height ();
            }
            
            //stdout.printf ("_on_size_request: %i, %i\n", req.width, req.height);
        }


        /***************************************************************************************************************
         * Draw the Desktop Window...
         * 
         **************************************************************************************************************/
        private bool _on_expose (Gdk.EventExpose evt) {
            
            //stdout.printf ("_on_expose: visible=%u, mapped=%u\n", (uint) this.get_visible (), (uint) this.get_mapped ());
            
            if (this.get_visible () == false || this.get_mapped () == false)
                return true;

            Cairo.Context cr = Gdk.cairo_create (this.get_window ());
            
            // rubber bending
            if (_rubber_started == true)
                this._paint_rubber_banding_rect (cr, evt.area);

            // draw desktop icons
            this._grid.draw_items (cr, evt.area);
            
            // ???? not needed ???? Gdk.cairo_destroy (cr); cr.destroy (); ?????
            

            return true;
        }


        /***************************************************************************************************************
         *  Contextual menu, double click on icons, rubber banding...
         * 
         **************************************************************************************************************/
        private bool _on_button_press (Gdk.EventButton evt) {
            
            Desktop.Item? clicked_item = _grid.hit_test (evt.x, evt.y);
            
            
            /***********************************************************************************************************
             * Single click...
             * 
             **********************************************************************************************************/
            if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                
                // left button, save state for drag and drop
                if (evt.button == 1) {
                    
                    this._button_pressed = true;
                    this._drag_start_x = evt.x;
                    this._drag_start_y = evt.y;
                }

                // if ctrl / shift is not pressed, deselect all, don't cancel selection if clicking on selected items
                if ((evt.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) == 0
                     && (evt.button == 1 || evt.button == 3)
                     && clicked_item != null
                     && clicked_item.is_selected == true) {
                    
                    _grid.deselect_all ();
                }

                if (clicked_item != null) {
                    
                    if ((evt.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) != 0)
                        clicked_item.is_selected = ! clicked_item.is_selected;
                    else
                        clicked_item.is_selected = true;

                    _grid.set_selected_item (clicked_item);
                    
                    
                    clicked_item.redraw (this.get_window ());

                    if (evt.button == 3)
                        this._create_popup_menu (evt);
                        
                    if (this.has_focus == 0)
                        this.grab_focus ();
                    
                    return true;
                
                // start rubber banding
                } else if (evt.button == 1) {
                        
                    // an error in vapi files ??????
                    Gtk.grab_add (this);
                    
                    this._rubber_started = true;
                    this._rubber_bending_x = evt.x;
                    this._rubber_bending_y = evt.y;
                    
                    if (this.has_focus == 0)
                        this.grab_focus ();
                    
                    return true;
                
                // contextual popup menu
                } else if (evt.button == 3 && this._show_wm_menu == false) {
                            
                    if (_desktop_popup == null)
                        return true;
                    
                    if (_desktop_popup.get_attach_widget () != null)
                        _desktop_popup.detach ();
                    
                    _desktop_popup.attach_to_widget (this, null);
                    _desktop_popup.popup (null, null, null, 3, evt.time);
                }
            
            
            /***********************************************************************************************************
             * Left double click on a selected item, launch the selected file...
             * 
             * 
             **********************************************************************************************************/
            } else if (evt.type == Gdk.EventType.2BUTTON_PRESS
                       && evt.button == 1
                       && clicked_item != null) {
                
                // Fm.launch_file_simple (GTK_WINDOW(w), null, clicked_item->fi, pcmanfm_open_folder, null);
                
                if (this.has_focus == 0)
                    this.grab_focus ();
                
                return true;
            }
            
            // forward the event to root window
            //XLib.forward_event_to_rootwin (this.get_screen(), (Gdk.Event) evt);
            forward_event_to_rootwin (this.get_screen(), evt);

            if (this.has_focus == 0)
                this.grab_focus ();
            
            return true;
        }

        private bool _on_button_release (Gdk.EventButton evt) {
            
            Desktop.Item? clicked_item = _grid.hit_test (evt.x, evt.y);

            this._button_pressed = false;

            if (this._rubber_started == true) {
                
                this._update_rubberbanding ((int) evt.x, (int) evt.y);

                Gtk.grab_remove (this);

                this._rubber_started = false;
            
            } else if (this._dnd_started == true) {
                
                this._dnd_started = false;
            
            } else if (global_config.single_click == true && evt.button == 1) {
                
                if (clicked_item != null) {
                    
                    // left single click
                    // fm_launch_file_simple (GTK_WINDOW(w), null, clicked_item->fi, pcmanfm_open_folder, null);
                    
                    return true;
                }
            }

            // forward the event to root window
            if (clicked_item == null) {
                //XLib.forward_event_to_rootwin (this.get_screen(), evt);
                forward_event_to_rootwin (this.get_screen(), evt);
            }
            
            return true;
        }

        public inline void forward_event_to_rootwin (Gdk.Screen screen, Gdk.EventButton event) {
            // call the C function for this...
        }
        
        private bool _on_motion_notify (Gdk.EventMotion evt) {

            if (this._button_pressed == false) {
                
                // single click...
                if (global_config.single_click == true) {
                    /***************************************************************************************************
                     * Single click not implemented yet...
                     * 
                    Desktop.Item item = hit_test (evt.x, evt.y);
                    Gdk.Window window = this.get_window(w);

                    if (item != this.hover_item) {
                        if (this.single_click_timeout_handler != 0) {
                            Source.remove (this.single_click_timeout_handler);
                            this.single_click_timeout_handler = 0;
                        }
                    }
                    
                    if (item) {
                        window.set_cursor (hand_cursor);
                        // FIXME: timeout should be customizable
                        if (this.single_click_timeout_handler == 0)
                            this.single_click_timeout_handler = g_timeout_add (400, on_single_click_timeout, this); //400 ms
                            // Making a loop to aviod the selection of the item
                            // on_single_click_timeout (self);
                    } else {
                        gdk_window_set_cursor (window, null);
                    }
                    
                    this.hover_item = item;
                    ***************************************************************************************************/
                }
                return true;
            }

            if (this._dnd_started == true)
                return true;
            
            // move rubber bending
            if (this._rubber_started == true) {
                this._update_rubberbanding ((int) evt.x, (int) evt.y);
            
            // Start Drag And Drop
            /***********************************************************************************************************
             *  Drag And Drop not implemented yet...
             * 
            } else if (gtk_drag_check_threshold (w, this.drag_start_x, this.drag_start_y, evt.x, evt.y)) {
                
                Fm.FileInfoList files = this.get_selected_files ();
                Gtk.TargetList target_list;
                if (files) {
                    this._dnd_started = true;
                    target_list = gtk_drag_source_get_target_list(w);
                    gtk_drag_begin (w, target_list, GDK_ACTION_COPY | GDK_ACTION_MOVE | GDK_ACTION_LINK, 1, evt);
                }
             **********************************************************************************************************/
            }

            return true;
        }
        
        
        /***************************************************************************************************************
         * Rubber Banding Rect
         * 
         **************************************************************************************************************/
        private void _paint_rubber_banding_rect (Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            Gdk.Rectangle rect;
            
            this._calc_rubber_banding_rect (this._rubber_bending_x, this._rubber_bending_y, out rect);

            if (rect.width <= 0 || rect.height <= 0)
                return;

            if (expose_area.intersect (rect, out rect) == false)
                return;

            Gtk.Style style = this.get_style ();
            Gdk.Color clr = style.base[Gtk.StateType.SELECTED];
            
            // FIXME: should be themable in the future
            uchar alpha = 64;

            cr.save ();
            cr.set_source_rgba ((double) clr.red / 65535, (double) clr.green / 65536, (double) clr.blue / 65535, (double) alpha / 100);
            Gdk.cairo_rectangle (cr, rect);
            cr.clip ();
            cr.paint ();
            Gdk.cairo_set_source_color (cr, clr);
            cr.rectangle (rect.x + 0.5, rect.y + 0.5, rect.width - 1, rect.height - 1);
            cr.stroke ();
            cr.restore ();
            
            return;
        }

        private void _calc_rubber_banding_rect (double x, double y, out Gdk.Rectangle rect) {
            
            double x1 = 0;
            double x2 = 0;
            double y1 = 0;
            double y2 = 0;
            
            if (this._drag_start_x < x) {
                x1 = this._drag_start_x;
                x2 = x;
            } else {
                x1 = x;
                x2 = this._drag_start_x;
            }

            if (this._drag_start_y < y) {
                y1 = this._drag_start_y;
                y2 = y;
            } else {
                y1 = y;
                y2 = this._drag_start_y;
            }

            rect.x = (int) x1;
            rect.y = (int) y1;
            rect.width = (int) (x2 - x1);
            rect.height = (int) (y2 - y1);
            
            return;
        }

        private void _update_rubberbanding (int newx, int newy) {
            
            Gdk.Rectangle old_rect;
            Gdk.Rectangle new_rect;
            
            Gdk.Window window = this.get_window ();

            this._calc_rubber_banding_rect (this._rubber_bending_x, this._rubber_bending_y, out old_rect);
            this._calc_rubber_banding_rect (newx, newy, out new_rect);

            window.invalidate_rect (old_rect, false);
            window.invalidate_rect (new_rect, false);
            this._rubber_bending_x = newx;
            this._rubber_bending_y = newy;

            // update selection
            this._grid.update_selection (new_rect);
            
            return;
        }

        
        /***************************************************************************************************************
         * Contextual Menu...
         * 
         **************************************************************************************************************/
        private void _create_popup_menu (Gdk.EventButton evt) {
            
            /***********************************************************************************************************
            Fm.FileMenu menu;
            Gtk.Menu popup;
            Fm.FileInfo fi;
            List sel_items;
            List l;
            
            Fm.FileInfoList files;
            Gtk.UIManager ui;
            Gtk.ActionGroup act_grp;
            Gtk.Action act;
            bool all_fixed = true;
            bool has_fixed = false;
            
            files = new Fm.FileInfoList ();
            sel_items = this.get_selected_items (null);
            
            for (l = sel_items; l; l=l.next) {
                
                Desktop.Item item = l.data as Desktop.Item;
                files.push_tail (item.fi);
                
                if (item.fixed_pos == true)
                    has_fixed = true;
                else
                    all_fixed = false;
            }
            
            fi = files.peek_head ();
            
            // create a menu and set the open folder function.
            menu = new Fm.FileMenu.for_files (files, Fm.Path.get_desktop (), true);
            menu.set_folder_func (pcmanfm_open_folder, desktop);
            
            ui = menu.get_ui ();
            act_grp = menu.get_action_group ();
            act_grp.set_translation_domain (null);
            
            // merge some specific menu items for folders
            if (menu.is_single_file_type () && fi.is_dir ()) {
                act_grp.add_actions (folder_menu_actions, G_N_ELEMENTS (folder_menu_actions), menu);
                ui.add_ui_from_string (folder_menu_xml, -1, null);
            }
            
            // merge desktop icon specific items
            act_grp.add_actions (desktop_icon_actions, G_N_ELEMENTS (desktop_icon_actions), desktop);
            
            desktop_icon_toggle_actions[0].is_active = all_fixed;
            
            act_grp.add_toggle_actions (desktop_icon_toggle_actions, G_N_ELEMENTS (desktop_icon_toggle_actions), desktop);
            
            // snap to grid
            if (has_fixed == false) {
                act = act_grp.get_action ("Snap");
                act.set_sensitive (false);
            }
            ui.add_ui_from_string (desktop_icon_menu_xml, -1, null);
            
            popup = menu.get_menu ();
            popup.popup (null, null, null, fi, 3, evt.time);
            
            ***********************************************************************************************************/
            
            return;
        }
        
        
        /* *************************************************************************************************************
         * Currently unused functions....
         * 
         * 
         */
        /***************************************************************************************************************
         * Keyboard handling and file system actions...
         * 
         * 
         * 
         **************************************************************************************************************/
        private bool _on_key_press (Gdk.EventKey evt) {

            /***********************************************************************************************************
             * 
            Desktop.Item item;
            int modifier =  (evt.state &  (GDK_SHIFT_MASK | GDK_CONTROL_MASK | GDK_MOD1_MASK));
            
            Fm.PathList sels;
            
            switch  (evt.keyval) {
                
                case GDK_Menu: {
                    
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
                
                case GDK_Left:
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
                
                case GDK_Right:
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
                
                case GDK_Up:
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
                
                case GDK_Down:
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
                
                case GDK_space:
                    if ((modifier & GDK_CONTROL_MASK) && desktop->focus) {
                        desktop->focus->is_selected = !desktop->focus->is_selected;
                        desktop->focus.redraw ();
                    }
                    else
                        activate_selected_items(desktop);
                    return true;
                break;
                
                case GDK_Return:
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
                
                case GDK_x:
                    if (modifier & GDK_CONTROL_MASK) {
                        sels = fm_desktop_get_selected_paths (desktop);
                        fm_clipboard_cut_files (desktop, sels);
                    }
                break;
                
                case GDK_c:
                    if (modifier & GDK_CONTROL_MASK) {
                        sels = fm_desktop_get_selected_paths (desktop);
                        fm_clipboard_copy_files (desktop, sels);
                    }
                break;
                
                case GDK_v:
                    if (modifier & GDK_CONTROL_MASK)
                        fm_clipboard_paste_files (GTK_WIDGET(desktop), fm_path_get_desktop());
                break;
                
                case GDK_F2:
                    sels = fm_desktop_get_selected_paths(desktop);
                    if (sels) {
                        fm_rename_file (GTK_WINDOW(desktop), fm_list_peek_head(sels));
                    }
                break;
                
                case GDK_Delete:
                    sels = fm_desktop_get_selected_paths(desktop);
                    if (sels) {
                        if (modifier & GDK_SHIFT_MASK)
                            fm_delete_files (GTK_WINDOW(desktop), sels);
                        else
                            fm_trash_or_delete_files (GTK_WINDOW(desktop), sels);
                    }
                break;
            }
            ***********************************************************************************************************/
            
            return base.key_press_event (evt);
        }
        
        private void _on_screen_size_changed (Gdk.Screen screen) {
            this.resize (screen.get_width (), screen.get_height ());
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
                focus.redraw ();
            */
            return false;
        }

        private bool _on_focus_out (Gdk.EventFocus evt) {
            
            /*
            if (this._focused) {
                this.UNSET_FLAGS (GTK_HAS_FOCUS);
                focus.redraw ();
            }
            */
            return false;
        }
        
        
        /***************************************************************************************************************
         * Single click...
         * 
         **************************************************************************************************************/
        private bool _on_leave_notify (Gdk.EventCrossing evt) {
            
            /*
            if (this.single_click_timeout_handler) {
                Source.remove (this.single_click_timeout_handler);
                this.single_click_timeout_handler = 0;
            }
            */
            
            return true;
        }

        private bool _on_single_click_timeout () {
            
            /***********************************************************************************************************
             * 
            Gdk.EventButton evt;
            Gdk.Window window;
            int x;
            int y;

            window = this.get_window ();
            // generate a fake button press
            // FIXME: will this cause any problem?
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
    }
}


