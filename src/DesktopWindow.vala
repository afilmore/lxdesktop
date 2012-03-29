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
 * Purpose: The Desktop Widget. It's simply a derived Gtk.Window, it can be created in a debug mode,
 *          in that mode, it's not full screen but 3/4 of the screen in a regular window.
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    

    public enum DesktopDndDest {
        DESKTOP_ITEM = Fm.DndDestTarget.DEFAULT + 1
    }

    private const Gtk.TargetEntry dnd_targets[] = {
        {"application/x-desktop-item", Gtk.TargetFlags.SAME_WIDGET, DesktopDndDest.DESKTOP_ITEM}
    };

    private const Gtk.TargetEntry desktop_default_dnd_dest_targets[] =
    {
        {"application/x-fmlist-ptr", Gtk.TargetFlags.SAME_APP, Fm.DndDestTarget.FM_LIST},
        {"text/uri-list", 0, Fm.DndDestTarget.URI_LIST}, // text/uri-list
        { "XdndDirectSave0", 0, Fm.DndDestTarget.XDS} // X direct save
    };


    public class Window : Gtk.Window {
        
        bool _debug_mode = false;
        
        // The desktop grid
        private Desktop.Grid _grid;
        
        // Rubber banding / Drag And Drop
        private bool    _rubber_started = false;
        private int     _rubber_bending_x = 0;
        private int     _rubber_bending_y = 0;
        private bool    _button_pressed = false;
        private int     _drag_start_x = 0;
        private int     _drag_start_y = 0;
        private bool    _dnd_started = false;
        
        private Fm.DndSrc   _dnd_src;
        private Fm.DndDest  _dnd_dest;
        

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
            
            this.drag_motion.connect (_on_drag_motion);
            this.drag_drop.connect (_on_drag_drop);
            this.drag_data_received.connect (_on_drag_data_received);
            this.drag_leave.connect (_on_drag_leave);
            
            this.leave_notify_event.connect (_on_leave_notify); // for single click...
            
            /***********************************************************************************************************
             * Handlers to connect when ready...
             *
             * 
            
            
            this.key_press_event.connect (_on_key_press);
            this.style_set.connect (_on_style_set);
            
            this.direction_changed.connect (_on_direction_changed);
            this.focus_in_event.connect (_on_focus_in);
            this.focus_out_event.connect (_on_focus_out);
            
            this.delete_event.connect ((DeleteEvtHandler) Gtk.true);

            
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
         * 
         **************************************************************************************************************/
        public void set_background () {
            
            Gdk.Window window = this.get_window ();
            Gdk.Window root = this.get_screen ().get_root_window ();

            Gdk.Pixbuf? pix = null;
            if (global_config.wallpaper_mode == Fm.WallpaperMode.COLOR
               || global_config.wallpaper == ""
               || (pix = new Gdk.Pixbuf.from_file (global_config.wallpaper)) == null) {
                
                // the solid color for the desktop background
                Gdk.Color bg = global_config.color_background;
                
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
            XLib.set_wallpaper (pix, global_config.wallpaper_mode);
            
            return;
        }
        
        
        /***************************************************************************************************************
         * Private members...
         * 
         * 
         * 
         **************************************************************************************************************/
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
            
            this.set_background ();
        }

        private void _on_size_allocate (Gdk.Rectangle rect) {
            
            //stdout.printf ("_on_size_allocate: %i, %i, %i, %i\n", rect.x, rect.y, rect.width, rect.height);
            
            // setup the size of items.
            _grid.init_layout (rect);
            
            //  scale the wallpaper
            if (base.is_realized () == true
                && global_config.wallpaper_mode != Fm.WallpaperMode.COLOR
                && global_config.wallpaper_mode != Fm.WallpaperMode.TILE) {
                
                this.set_background ();
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
            
            // stdout.printf ("_on_expose: visible=%u, mapped=%u\n", (uint) this.get_visible (), (uint) this.get_mapped ());
            
            if (this.get_visible () == false || this.get_mapped () == false)
                return true;

            Cairo.Context cr = Gdk.cairo_create (this.get_window ());
            
            // rubber bending
            if (_rubber_started == true)
                this._paint_rubber_banding_rect (cr, evt.area);

            // draw desktop icons
            this._grid.draw_items (cr, evt.area);
            
            // ???? not needed ???? cr.destroy (); ?????
            
            return true;
        }


        /***************************************************************************************************************
         *  Contextual menu, double click on icons, rubber banding...
         * 
         * 
         **************************************************************************************************************/
        private bool _on_button_press (Gdk.EventButton evt) {
            
            Desktop.Item? clicked_item = _grid.hit_test (evt.x, evt.y);
            
            /***********************************************************************************************************
             * Single click...
             * 
             * 
             **********************************************************************************************************/
            if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                
                // left button, save state for drag and drop
                if (evt.button == 1) {
                    
                    this._button_pressed = true;
                    this._drag_start_x = (int) evt.x;
                    this._drag_start_y = (int) evt.y;
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
                    this._rubber_bending_x = (int) evt.x;
                    this._rubber_bending_y = (int) evt.y;
                    
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
                
                // action open........
                if (clicked_item.is_special)
                    return true;
                
                Fm.FileInfo? fi = clicked_item.get_fileinfo ();
                
                if (fi.is_dir ()
                || fi.is_mountable ()
                ) {
                    
                    this.action_open_folder (fi);
                
                } else if (fi.is_unknown_type ()) {
                
                } else {
                    
                    this.action_open_file (fi);
                }
                // ......................
                
                if (this.has_focus == 0)
                    this.grab_focus ();
                
                return true;
            }
            
            // forward the event to root window
            Gdk.Event* real_e = (Gdk.Event*)(&evt);
            XLib.forward_event_to_rootwin (this.get_screen(), real_e);

            if (this.has_focus == 0)
                this.grab_focus ();
            
            return true;
        }

        public bool action_open_file (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            Fm.launch_file_simple (this,
                                   null,
                                   fi,
                                   null, // need to modify libfm so that it doesn't segfault....
                                   null);
            
            //~ fi.is_desktop_entry ()
            //~ fi.is_shortcut ()
            //~ fi.is_executable_type ();
            //~ fi.is_hidden ();
            //~ fi.is_image ();
            //~ fi.is_text ();
            //|| fi.is_symlink ()
            
            return true;
        }
        
        public bool action_open_folder (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            string cmdline = global_config.app_filemanager + " " + fi.get_path ().to_str ();
            
            try {
                Process.spawn_command_line_async (cmdline);
            } catch (Error e) {
            }
            
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
                
                Gdk.Event* real_e = (Gdk.Event*)(&evt);
                XLib.forward_event_to_rootwin (this.get_screen(), real_e);
            }
            
            return true;
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
                            this.single_click_timeout_handler = g_timeout_add (400,
                                                                               on_single_click_timeout,
                                                                               this); //400 ms
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
            } else if (Gtk.drag_check_threshold (this, _drag_start_x, _drag_start_y, (int) evt.x, (int) evt.y)) {
                
                
                Fm.FileInfoList? files = _grid.get_selected_files ();
                Gtk.TargetList target_list;
               
                if (files != null) {
                    
                    this._dnd_started = true;
                    target_list = Gtk.drag_source_get_target_list (this);
                    
                    // This is a workaround to convert GdkEventButton* to GdkEvent* in Vala.
                    // Thanks to Eric Gregory: https://mail.gnome.org/archives/vala-list/2012-March/msg00123.html
                    // forward_event_to_rootwin () needs the same trick to pass events.
                    Gdk.Event* real_e = (Gdk.Event*)(&evt);
                    Gtk.drag_begin (this,
                                    target_list,
                                    Gdk.DragAction.COPY
                                    | Gdk.DragAction.MOVE
                                    | Gdk.DragAction.LINK,
                                    1,
                                    real_e);
                }
                
            }

            return true;
        }
        
        
        /***************************************************************************************************************
         * Rubber Banding Rect
         * 
         * 
         **************************************************************************************************************/
        private void _paint_rubber_banding_rect (Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            Gdk.Rectangle rect;
            
            this._calc_rubber_banding_rect ((int) this._rubber_bending_x, (int) this._rubber_bending_y, out rect);

            if (rect.width <= 0 || rect.height <= 0)
                return;

            if (expose_area.intersect (rect, out rect) == false)
                return;

            // the style and color should be cached and configurable
            Gtk.Style style = this.get_style ();
            Gdk.Color clr = style.base[Gtk.StateType.SELECTED];
            uchar alpha = 64;

            cr.save ();
            cr.set_source_rgba ((double) clr.red / 65535,
                                (double) clr.green / 65536,
                                (double) clr.blue / 65535,
                                (double) alpha / 100);
                                
            Gdk.cairo_rectangle (cr, rect);
            cr.clip ();
            cr.paint ();
            Gdk.cairo_set_source_color (cr, clr);
            cr.rectangle (rect.x + 0.5, rect.y + 0.5, rect.width - 1, rect.height - 1);
            cr.stroke ();
            cr.restore ();
            
            return;
        }

        private void _calc_rubber_banding_rect (int x, int y, out Gdk.Rectangle rect) {
            
            int x1 = 0;
            int x2 = 0;
            int y1 = 0;
            int y2 = 0;
            
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

            rect.x = x1;
            rect.y = y1;
            rect.width = (x2 - x1);
            rect.height = (y2 - y1);
            
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
         * Drag And Drop Handling
         * 
         * 
         * 
         **************************************************************************************************************/
        private void _init_drag_and_drop () {

            //return; // needs testing...
            
            // doesn't build with Fm.default_dnd_dest_targets...
            Gtk.drag_source_set (this,
                                 0,
                                 desktop_default_dnd_dest_targets,
                                 Gdk.DragAction.COPY
                                 | Gdk.DragAction.MOVE
                                 | Gdk.DragAction.LINK
                                 | Gdk.DragAction.ASK);

            Gtk.TargetList targets = Gtk.drag_source_get_target_list (this);
            
            // add our own targets
            // Gtk Vapi files are wrong, patch submitted for this...
            // https://bugzilla.gnome.org/show_bug.cgi?id=673117
            targets.add_table (dnd_targets); 
            
            // a dirty way to override FmDndSrc.
            
            this.drag_data_get.connect (_on_drag_data_get);
            
            this._dnd_src = new Fm.DndSrc (this);
            
            this._dnd_src.data_get.connect (_on_dnd_src_data_get);

            Gtk.drag_dest_set (this,
                               0,
                               null,
                               Gdk.DragAction.COPY
                               | Gdk.DragAction.MOVE
                               | Gdk.DragAction.LINK
                               | Gdk.DragAction.ASK);
            
            Gtk.drag_dest_set_target_list (this, targets);

            this._dnd_dest = new Fm.DndDest (this);
        }

        private bool _on_drag_motion (Gtk.Widget dest_widget,
                                      Gdk.DragContext drag_context,
                                      int x,
                                      int y,
                                      uint time) {
            
            Gdk.Atom target;
            
            bool ret = false;
            
            Gdk.DragAction action = 0;
            
            //Desktop.Window desktop = dest_widget as Desktop.Window;
            
            // check if we're dragging over an item
            Desktop.Item item = _grid.hit_test (x, y);
            Fm.FileInfo? fi;
            
            // we can only allow dropping on desktop entry file, folder, or executable files
            if (item != null) {
                fi = item.get_fileinfo ();
                
               // FIXME: libfm cannot detect if the file is executable!
               // !fm_file_info_is_executable_type(item->fi) &&
                if (fi != null && fi.is_dir () == false &&
                   fi.is_desktop_entry () == false)
                   
                   item = null;
            }

            // handle moving desktop items
            if (item != null) {
                
                stdout.printf ("item\n");
                target = Gdk.Atom.intern_static_string (dnd_targets[0].target);
                
                if (Fm.drag_context_has_target (drag_context, target)
                    && (drag_context.actions & Gdk.DragAction.MOVE) != 0) {
                        
                    // desktop item is being dragged
                    this._dnd_dest.set_dest_file (null);
                    action = Gdk.DragAction.MOVE; // move desktop items
                    ret = true;
                }
            }

            if (ret) {
                
                target = this._dnd_dest.find_target (drag_context);
                
                // try FmDndDest
                if (target != Gdk.Atom.NONE) {
                    
                    Fm.FileInfo? dest_file = null;
                    
                    if (item != null) {
                        
                        // if (fm_file_info_is_dir(item->fi)) commented in PCManFm...
                        dest_file = item.get_fileinfo ();
                    }
                    
                    if (dest_file == null) {
                        // FIXME: prevent direct access to data member
                        dest_file = global_model.dir.dir_fi;
                    }

                    this._dnd_dest.set_dest_file (dest_file);
                    action = this._dnd_dest.get_default_action (drag_context, target);
                    
                    ret = (action != 0);
                    
                } else {
                    
                    ret = false;
                    action = 0;
                }
            }
            
            Gdk.drag_status (drag_context, action, time);

            Desktop.Item? _drop_hilight = null; // temporary fake item...
            
            if (_drop_hilight != item) {
                
                Desktop.Item old_drop = _drop_hilight;
                _drop_hilight = item;
                
                if (old_drop != null)
                    old_drop.redraw (this.get_window ());
                
                if (item != null)
                    item.redraw (this.get_window ());
            }

            return ret;
        }

        private void _on_drag_leave  (Gdk.DragContext drag_context,
                                      uint time) {
                                          
            this._dnd_dest.drag_leave (drag_context, time);

            Desktop.Item? _drop_hilight = null; // temporary fake item...
            if (_drop_hilight != null) {
                
                Desktop.Item? old_drop = _drop_hilight;
                
                _drop_hilight = null;
                
                old_drop.redraw (this.get_window ());
            }

            return; // void function in Vala...
        }

        private bool _on_drag_drop (Gtk.Widget dest_widget,
                                    Gdk.DragContext drag_context,
                                    int x,
                                    int y,
                                    uint time) {
                                        
            bool ret = false;
            
            Gdk.Atom target;
            
            // check if we're dragging over an item
            Desktop.Item item = _grid.hit_test (x, y);
            
            // we can only allow dropping on desktop entry file, folder, or executable files
            if (item != null) {
                
                // FIXME: libfm cannot detect if the file is executable!
                // !fm_file_info_is_executable_type(item->fi) &&
                
                Fm.FileInfo? fi;
                fi = item.get_fileinfo ();
                
                if (fi != null
                    && fi.is_dir () == false
                    && fi.is_desktop_entry () == false)
                   item = null;
            }

            // handle moving desktop items
            if (item != null) {
                
                target = Gdk.Atom.intern_static_string (dnd_targets[0].target);
                
                if (Fm.drag_context_has_target (drag_context, target) == true
                   && (drag_context.actions & Gdk.DragAction.MOVE) != 0) {
                       
                    _grid.move_items (x, y, _drag_start_x, _drag_start_y);
                    
                    ret = true;
                    
                    Gtk.drag_finish (drag_context, true, false, time);

                    // FIXME: save position of desktop icons everytime is
                    // extremely inefficient, but currently inevitable.
                    
                     this._save_item_pos ();

                    this._grid.queue_layout_items ();
                }
            }

            if (ret) {
                
                target = this._dnd_dest.find_target (drag_context);
                
                // try FmDndDest
                ret = this._dnd_dest.drag_drop (drag_context, target, x, y, time);
                
                if (ret == false)
                    Gtk.drag_finish (drag_context, false, false, time);
            }
            return ret;
        }

        private void _on_drag_data_received (Gtk.Widget dest_widget,
                                             Gdk.DragContext drag_context,
                                             int x,
                                             int y,
                                             Gtk.SelectionData sel_data,
                                             uint info,
                                             uint time) {
                                                 
            switch (info) {
                
                case DesktopDndDest.DESKTOP_ITEM:
                    // This shouldn't happen since we handled everything in drag-drop handler already.
                break;
                
                default:
                    // check if files are received.
                    
                    // FIXME: this segfault :(
                    //this._dnd_dest.drag_data_received (drag_context, x, y, sel_data, info, time);
                break;
            }
        }

        private void _on_drag_data_get (Gdk.DragContext drag_context,
                                        Gtk.SelectionData sel_data,
                                        uint info,
                                        uint time) {
                                            
            // desktop items are being dragged
            if (info == DesktopDndDest.DESKTOP_ITEM)
                Signal.stop_emission_by_name (this, "drag-data-get");
            
        }


        private void _on_dnd_src_data_get () {
            
            Fm.FileInfoList files = _grid.get_selected_files ();
            
            if (files != null) {
                
                _dnd_src.set_files (files);
                
                // files.unref(); is it needed in Vala ???
            }
        }


        /***************************************************************************************************************
         * Single click...
         * 
         * 
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

        private bool _save_item_pos () {
            // temporary...
            return true;
        }
        
        
        /***************************************************************************************************************
         * Contextual Menu...
         * 
         * 
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
        
        
/* *********************************************************************************************************************
 * Currently unused functions....
 * 
 * 
 * 
 **********************************************************************************************************************/
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
        
        
        /* *************************************************************************************************************
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


        /***************************************************************************************************************
         * Actions...
         * 
         * 
         * 
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


    }
}


/***********************************************************************************************************************
 * These are original function, I plan to implement these a different way...
 * Grid.append_item () replaces layout_items ()
 * 
 * 
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


/***********************************************************************************************************************
 * Load save item positions...
 * 
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

***********************************************************************************************************************/


/* unused function even in PCManFm...
private inline bool is_atom_in_targets (List? targets, string name) {
    
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
    
    return false;
}*/


