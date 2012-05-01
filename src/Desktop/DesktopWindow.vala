/***********************************************************************************************************************
 * DesktopWindow.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: The Desktop Widget. It's simply a derived Gtk.Window, it can be created in a debug mode,
 *          in that mode, it's not full screen but 3/4 of the screen in a regular window.
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    
    
    /*********************************************************************************************************
     * Drag And Drop.
     * 
     * 
     ********************************************************************************************************/
    public enum DesktopDndDest {
        DESKTOP_ITEM = Fm.DndDestTarget.DEFAULT + 1
    }

    private const Gtk.TargetEntry dnd_targets[] = {
        {"application/x-desktop-item", Gtk.TargetFlags.SAME_WIDGET, DesktopDndDest.DESKTOP_ITEM}
    };

    private const Gtk.TargetEntry desktop_default_dnd_dest_targets[] = {
        
        {"application/x-fmlist-ptr",    Gtk.TargetFlags.SAME_APP,   Fm.DndDestTarget.FM_LIST},
        {"text/uri-list",               0,                          Fm.DndDestTarget.URI_LIST}, // text/uri-list
        { "XdndDirectSave0",            0,                          Fm.DndDestTarget.XDS}       // X direct save
    };

    
    /***********************************************************************************************
     * Desktop Window.
     * 
     * 
     **********************************************************************************************/
    public class Window : Gtk.Window {
        
        bool _debug_mode = false;
        
        /*********************************************************************************
         * Desktop Menu.
         * 
         * 
         ********************************************************************************/
        /*private const Gtk.ActionEntry _default_popup_actions[] = {
            {"CreateNew", null, N_("Create _New..."), "", null,                     null},
            {"NewFolder", "folder", N_("Folder"), "<Ctrl><Shift>N", null,           _on_action_new_folder},
            {"NewBlank", "text-x-generic", N_("Blank File"), null, null,            _on_action_new_file},
            {"Paste", Gtk.Stock.PASTE, null, null, null,                            _on_action_paste},
            {"SelAll", Gtk.Stock.SELECT_ALL, null, null, null,                      _on_action_select_all},
            {"InvSel", null, N_("_Invert Selection"), "<Ctrl>I", null,              _on_action_invert_select},
            {"Properties", Gtk.Stock.PROPERTIES, N_("Desktop Preferences"),
                           "<Alt>Return", null,                                     _on_action_desktop_settings}
        };*/

        // The desktop grid
        private Desktop.Grid    _grid;
        public  Desktop.Item?   drop_hilight = null;         /*** Drop Target Highlighted Item ***/
        public  Desktop.Item?   hover_item = null;      /*** Highlighted item for Single Click Mode ***/
        
        // Rubber banding / Drag And Drop
        private bool            _rubber_started = false;
        private int             _rubber_bending_x = 0;
        private int             _rubber_bending_y = 0;
        private bool            _button_pressed = false;
        private int             _drag_start_x = 0;
        private int             _drag_start_y = 0;
        private bool            _dnd_started = false;
        
        private Gdk.Cursor      crossed_circle = null;
        private Fm.DndSrc       _fm_dnd_src;
        private Fm.DndDest      _fm_dnd_dest;
        
        /*********************************************************************************
         * Single click...
         * 
         * uint single_click_timeout_handler;
         * private GdkCursor* hand_cursor = null;
         * hand_cursor = gdk_cursor_new (GDK_HAND2);
         *
         ********************************************************************************/
        
        // Desktop Popup...
        private Desktop.Popup?  _desktop_popup_class;
        private bool            _show_wm_menu = false;  /*** Show the window manager's menu ***/
        private Gtk.Menu?       _desktop_popup;
        private Gtk.Menu?       _popup_menu;
        
        
        private Fm.FileMenu     _file_menu;             // Doesn't work if not global........
        
        public Window () {
            
            crossed_circle = new Gdk.Cursor (Gdk.CursorType.X_CURSOR);
            
            this.destroy.connect ( () => {
                
                _grid.save_item_pos ();
                
                Gtk.main_quit ();
            });
            
            this.realize.connect                (_on_realize);
            
#if ENABLE_GTK3
            this.size_allocate.connect          (_on_size_allocate);
            this.draw.connect                   (_on_draw);
#else
            // GTK3_REMOVE
            this.size_allocate.connect          (_on_gtk2_size_allocate);
            this.size_request.connect           (_on_gtk2_size_request);
            this.expose_event.connect           (_on_gtk2_expose);
#endif            

            this.button_press_event.connect     (_on_button_press);
            this.button_release_event.connect   (_on_button_release);
            this.motion_notify_event.connect    (_on_motion_notify);
            
            this.drag_begin.connect_after       (_on_drag_begin);
            this.drag_motion.connect            (_on_drag_motion);
            this.drag_leave.connect             (_on_drag_leave);
            this.drag_drop.connect              (_on_drag_drop);
            this.drag_data_received.connect     (_on_drag_data_received);
            this.drag_failed.connect            (_on_drag_failed);
            
            this.leave_notify_event.connect     (_on_leave_notify); /*** for single click... ***/
            
            /*****************************************************************************
             * Other Handlers to connect when needed...
             *
             * 
            this.key_press_event.connect (_on_key_press);
            this.style_set.connect (_on_style_set);
            
            this.direction_changed.connect (_on_direction_changed);
            this.focus_in_event.connect (_on_focus_in);
            this.focus_out_event.connect (_on_focus_out);
            
            this.delete_event.connect ((DeleteEvtHandler) Gtk.true);
            * 
            *****************************************************************************/
        }
        
        ~Window () {
            
            /*****************************************************************************
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

            *****************************************************************************/
        }

        
        /*********************************************************************************
         * Widget Creation...
         * 
         * 
         ********************************************************************************/
        public bool create (string config_file, bool debug = false) {
            
            _debug_mode = debug;
            
            Gdk.Screen screen = this.get_screen ();

            _grid = new Desktop.Grid (this, config_file, debug);
            
            if (_debug_mode) {
                
                /*************************************************************************
                 * Debug mode, show the desktop in a regular window, very handy :)
                 *
                 ************************************************************************/
                this.set_default_size ((screen.get_width() / 4) * 3, (screen.get_height() / 4) * 3);
                this.set_position (Gtk.WindowPosition.CENTER);
                this.set_app_paintable (true);

            } else {
                
                /*************************************************************************
                 * This is the normal running mode, full screen
                 *
                 ************************************************************************/
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

            // Connect model's custom signals.
            global_model.row_inserted.connect (this.get_grid ().on_row_inserted);
            global_model.row_deleted.connect (this.get_grid ().on_row_deleted);
            /*** global_model.row_changed.connect (this.get_grid ().on_row_changed);        ***/
            /*** global_model.rows_reordered.connect (this.get_grid ().on_rows_reordered);  ***/
            
            /*******************************************************************
             * Setup root window events.
             * 
             * Gdk.Window root = screen.get_root_window ();
             * root.set_events (root.get_events () | GDK_PROPERTY_CHANGE_MASK);
             * root.add_filter (on_root_event);
             * screen.size_changed.connect (on_screen_size_changed);
             */
            
            this._init_drag_and_drop ();
            this.realize ();
            this.show_all ();
            
            if (_debug_mode == false)
                this.get_window ().lower();

            return true;
        }
        
        private void _init_drag_and_drop () {

            Gtk.drag_source_set (this,
                                 0,
                                 desktop_default_dnd_dest_targets, // Doesn't build with Fm.default_dnd_dest_targets...
                                 Gdk.DragAction.COPY
                                 | Gdk.DragAction.MOVE
                                 | Gdk.DragAction.LINK
                                 | Gdk.DragAction.ASK);

            Gtk.TargetList targets = Gtk.drag_source_get_target_list (this);
            
            /*** There's an error in the Vapi files,
             *   that will be corrected in the next realize
             *   https://bugzilla.gnome.org/show_bug.cgi?id=673117 ***/
            targets.add_table (dnd_targets); 
            
            // Override FmDndSrc.
            this.drag_data_get.connect (_on_drag_data_get);
            
            _fm_dnd_src = new Fm.DndSrc (this);
            
            _fm_dnd_src.data_get.connect (_on_dnd_src_data_get);

            Gtk.drag_dest_set (this,
                               0,
                               null, // See If There's a way to avoid this warning in Vala Vapi Files...
                               Gdk.DragAction.COPY
                               | Gdk.DragAction.MOVE
                               | Gdk.DragAction.LINK
                               | Gdk.DragAction.ASK);
            
            Gtk.drag_dest_set_target_list (this, targets);

            _fm_dnd_dest = new Fm.DndDest (this);
        }

        public Desktop.Grid? get_grid () {
            return _grid;
        }
        

        /*********************************************************************************
         * *** Widget Signal Handlers ***
         * 
         *     Widget creation/sizing/drawing...
         * 
         * 
         ********************************************************************************/
        private void _on_realize () {
            
            /*** stdout.printf ("_on_realize\n"); ***/
            
            base.realize ();
            
            _grid.init_gc (this.get_window());
            
            this.set_resizable (false);
            
            if (_debug_mode == false) {
                this.set_skip_pager_hint (true);
                this.set_skip_taskbar_hint (true);
            }
            
            this.set_background ();
            
        }

        
#if ENABLE_GTK3
        private void _on_size_allocate (Gtk.Allocation allocation) {
            
            /*** stdout.printf ("_on_size_allocate: %i, %i, %i, %i\n", rect.x, rect.y, rect.width, rect.height); ***/
            
            // Setup the size of items.
            _grid.init_layout ((Gdk.Rectangle) allocation);
            
            // Scale the wallpaper
            if (base.get_realized () == true
                && global_config.wallpaper_mode != Fm.WallpaperMode.COLOR
                && global_config.wallpaper_mode != Fm.WallpaperMode.TILE) {
                
                this.set_background ();
            }

            base.size_allocate (allocation);
        }

        public override void get_preferred_width (out int minimal_width, out int natural_width) {
            
            Gdk.Screen screen = this.get_screen ();
            if (_debug_mode == true )
                minimal_width = natural_width = (screen.get_width () /4) *3;
            else
                minimal_width = natural_width = screen.get_width ();
            
        }

        public override void get_preferred_height (out int minimal_height, out int natural_height) {
            
            Gdk.Screen screen = this.get_screen ();
            if (_debug_mode == true )
                minimal_height = natural_height = (screen.get_height () /4) *3;
            else
                minimal_height = natural_height = screen.get_height ();
        }

        private bool _on_draw (Cairo.Context cr) {
            
            if (this.get_visible () == false || this.get_mapped () == false)
                return true;

            Gdk.Rectangle rect = {0, 0, 0, 0};
            Gdk.cairo_get_clip_rectangle (cr, out rect);
            
            // Rubber banding
            if (_rubber_started == true)
                this._paint_rubber_banding_rect (cr, rect);
            
            // Draw desktop icons
            this._grid.draw_items_in_rect (cr, rect);
            
            return true;
        }

#else

        // GTK3_REMOVE
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
#endif


        /*********************************************************************************
         * *** Widget Signal Handlers ***
         * 
         *     Key Press/Release, Motion Notify...
         *     
         *     Create/Update the Rubber banding rect, create contextual menus.
         *     Handle single clicks, double clicks on icons.
         *     Handle Drag And Drop.
         * 
         * 
         ********************************************************************************/
        private bool _on_button_press (Gdk.EventButton evt) {
            
            Desktop.Item? clicked_item = _grid.hit_test (evt.x, evt.y);
            
            /**********************************************************************
             * Left double click on a selected item, launch the selected file...
             * 
             * 
             *********************************************************************/
            if (evt.type == Gdk.EventType.2BUTTON_PRESS
                && evt.button == 1
                && clicked_item != null) {
                
                //Fm.FileInfo? fi = ;
                
                this._action_open_file (clicked_item.get_fileinfo ());
                
                
//~                 if (fi.is_dir ()
//~                 || fi.is_mountable ()
//~                 || fi.is_unknown_type ()) { /* TODO use is_uri () ??? or something... */
//~                     
//~                     this.action_open_folder (fi);
//~                 
//~                 /***} else if (fi.is_unknown_type ()) {
//~                     stdout.printf ("Special item !!!\n"); ***/
//~                 } else {
//~                     
//~                     this.action_open_file (fi);
//~                 }
                
                if (!this.has_focus)
                    this.grab_focus ();

                return true;
                
            /*********************************************************
             * Single click...
             * 
             * 
             ********************************************************/
            } else if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                
                // Left button, save state for drag and drop
                if (evt.button == 1) {
                    
                    this._button_pressed = true;
                    this._drag_start_x = (int) evt.x;
                    this._drag_start_y = (int) evt.y;
                }

                // If ctrl / shift is not pressed, deselect all, don't cancel selection if clicking on selected items
                if ((evt.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) == 0
                     && ((evt.button == 1 || evt.button == 3)
                          && clicked_item != null
                          && clicked_item.is_selected) == false) {
                    
                    _grid.deselect_all ();
                }

                if (clicked_item != null) {
                    
                    if ((evt.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) != 0)
                        clicked_item.is_selected = ! clicked_item.is_selected;
                    else
                        clicked_item.is_selected = true;

                    /*** maybe the redraw can be included in set_selected_item ()... ***/
                    _grid.set_selected_item (clicked_item);
                    clicked_item.invalidate_rect (this.get_window ());

                    if (evt.button == 3)
                        this._create_popup_menu (evt);
                        
                    if (!this.has_focus)
                        this.grab_focus ();

                    return true;
                
                // Start rubber banding
                } else if (evt.button == 1) {
                        
                    Gtk.grab_add (this);
                    
                    this._rubber_started = true;
                    this._rubber_bending_x = (int) evt.x;
                    this._rubber_bending_y = (int) evt.y;
                    
                    if (!this.has_focus)
                        this.grab_focus ();

                    return true;
                
                
                /*************************************************************************
                 * Desktop Popup Menu
                 * 
                 */
                } else if (evt.button == 3 && this._show_wm_menu == false) {
                            
                    // Is it needed to destroy/unref previous created menu ???
                    
                    if (_desktop_popup_class == null)
                        _desktop_popup_class = new Desktop.Popup (this, Fm.Path.get_desktop());
                    
                    _desktop_popup = _desktop_popup_class.create_desktop_popup (/*_default_popup_actions*/);
                    
                    if (_desktop_popup == null) {
                        stdout.printf ("cannot create contextual popup, popup == null\n");
                        return true;
                    }
                    
                    if (_desktop_popup.get_attach_widget () != null)
                        _desktop_popup.detach ();
                    
                    _desktop_popup.attach_to_widget (this, null);
                    
                    _desktop_popup.popup (null, null, null, 3, evt.time);
                    
                }
            }
            
            // Forward the event to root window
            Gdk.Event* real_e = (Gdk.Event*)(&evt);
            XLib.forward_event_to_rootwin (this.get_screen(), real_e);

            if (!this.has_focus)
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
            
            // Open File/folder with single click...
            } else if (global_config.single_click == true && evt.button == 1) {
                
                if (clicked_item != null) {
                    
                    /*** Left Single Click ***

                    Fm.launch_file_simple (this, null, fi, null); */
                    
                    return true;
                }
            }

            // Forward the event to root window...
            if (clicked_item == null) {
                
                Gdk.Event* real_e = (Gdk.Event*)(&evt);
                XLib.forward_event_to_rootwin (this.get_screen(), real_e);
            }
            
            return true;
        }
        
        private bool _on_motion_notify (Gdk.EventMotion evt) {

            if (this._button_pressed == false) {
                
                // Single click...
                if (global_config.single_click == true) {
                    /**************************************************************************************
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
                    **************************************************************************************/
                }
                return true;
            }

            if (this._dnd_started == true)
                return true;
            
            // Move the rubber banding
            if (this._rubber_started == true) {
                this._update_rubberbanding ((int) evt.x, (int) evt.y);
            
            // Start Drag And Drop
            } else if (Gtk.drag_check_threshold (this, _drag_start_x, _drag_start_y, (int) evt.x, (int) evt.y)) {
                
                
                Fm.FileInfoList? files = _grid.get_selected_files ();
                Gtk.TargetList target_list;
               
                if (files != null) {
                    
                    this._dnd_started = true;
                    target_list = Gtk.drag_source_get_target_list (this);
                    
                    Desktop.Item item = _grid.hit_test ((int) evt.x, (int) evt.y, true);
                    if (item != null) {
                        _grid.set_selected_item (item);
                    }

                    /*******************************************************************************
                     * This is a workaround to convert GdkEventButton* to GdkEvent* in Vala.
                     * Thanks to Eric Gregory: 
                     * https://mail.gnome.org/archives/vala-list/2012-March/msg00123.html
                     * forward_event_to_rootwin () needs the same trick to pass events.
                     ******************************************************************************/
                    Gdk.Event* real_e = (Gdk.Event*)(&evt);
                    Gtk.drag_begin (this,
                                    target_list,
                                    Gdk.DragAction.COPY
                                    | Gdk.DragAction.MOVE
                                    | Gdk.DragAction.LINK,
                                    1,
                                    real_e);
                    

                } else {
                    stdout.printf ("empty list\n");
                }
            }

            return true;
        }
        
        
        /*******************************************************************************************
         * Rubber Banding Rect
         * 
         * 
         ******************************************************************************************/
        private void _paint_rubber_banding_rect (Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            Gdk.Rectangle rect = {0};
            
            this._calc_rubber_banding_rect ((int) this._rubber_bending_x, (int) this._rubber_bending_y, out rect);

            if (rect.width <= 0 || rect.height <= 0)
                return;

            if (expose_area.intersect (rect, out rect) == false)
                return;

            // The style and color should be cached and configurable...
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
            // DEPRECATED
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

            // Update selection
            this._grid.select_items_in_rect (new_rect);
            
            return;
        }

        
        /*******************************************************************************************
         *  *** Widget Signal Handlers ***
         * 
         *      Drag And Drop Handling
         * 
         *      http://developer.gnome.org/gtk/2.24/GtkWidget.html#GtkWidget-drag-begin
         * 
         ******************************************************************************************/
        private inline void _set_drop_hilight (Desktop.Item? dest_item) {
            
            if (dest_item != drop_hilight) {
                
                if (drop_hilight != null)
                    drop_hilight.invalidate_rect (this.get_window ());
                
                if (dest_item != null)
                    dest_item.invalidate_rect (this.get_window ());
                
                drop_hilight = dest_item;
            }
        }

        private void _on_drag_begin (Gtk.Widget dest_widget, Gdk.DragContext drag_context) {
            
            /***************************************************************************************
             * From Gtk+ Reference Manual. (2.24)
             * 
             * The ::drag-begin signal is emitted on the drag source when a drag is started.
             * A typical reason to connect to this signal is to set up a custom drag icon with
             * gtk_drag_source_set_icon().
             * Note that some widgets set up a drag icon in the default handler of this signal,
             * so you may have to use g_signal_connect_after() to override what the default
             * handler did.
             * 
             ***/
            
            Desktop.Item selected = _grid.get_selected_item ();
            if (selected != null) {
                stdout.printf ("ICON !!!\n");
                Gtk.drag_set_icon_pixbuf (drag_context, selected.icon, -5, -5);
            }
            stdout.printf ("DRAG BEGIN !!!\n");
            return;
             
        }
        
        private bool _on_drag_motion (Gtk.Widget dest_widget,
                                      Gdk.DragContext drag_context,
                                      int x,
                                      int y,
                                      uint time) {
            
            /***************************************************************************************
             * From Gtk+ Reference Manual. (2.24)
             * 
             * The drag-motion signal is emitted on the drop site when the user moves the cursor
             * over the widget during a drag. The signal handler must determine whether the cursor
             * position is in a drop zone or not. If it is not in a drop zone, it returns FALSE
             * and no further processing is necessary. Otherwise, the handler returns TRUE. In
             * this case, the handler is responsible for providing the necessary information for
             * displaying feedback to the user, by calling gdk_drag_status().
             * 
             * If the decision whether the drop will be accepted or rejected can't be made based
             * solely on the cursor position and the type of the data, the handler may inspect
             * the dragged data by calling gtk_drag_get_data() and defer the gdk_drag_status() call
             * to the "drag-data-received" handler.
             * 
             * Note that you cannot not pass GTK_DEST_DEFAULT_DROP, GTK_DEST_DEFAULT_MOTION 
             * or GTK_DEST_DEFAULT_ALL to gtk_drag_dest_set() when using the drag-motion signal
             * that way.
             * 
             * Also note that there is no drag-enter signal. The drag receiver has to keep track
             * of whether he has received any drag-motion signals since the last "drag-leave"
             * and if not, treat the drag-motion signal as an "enter" signal. Upon an "enter",
             * the handler will typically highlight the drop site with gtk_drag_highlight().
             * 
             ***/
            
            Gdk.Atom target;
            
            // Check if we're dragging over an item.
            Desktop.Item dest_item = _grid.hit_test (x, y, true);
            
            Desktop.Item selected = _grid.get_selected_item ();
            
            // None selected ?
            if (selected == null)
                stdout.printf ("selected == null !!!!\n");
            
            // Same item ?
            if (dest_item != null && dest_item == selected) {
                
                //stdout.printf ("_on_drag_motion: %u SAME ITEM !!!\n", time);
                return false;
            }
            
            // Move item ?
            if (dest_item == null) {
                
                Gdk.drag_status (drag_context, Gdk.DragAction.MOVE, time);
                this._set_drop_hilight (dest_item);
                
                //stdout.printf ("%u:_on_drag_motion: MOVE ITEM !!!\n", time);
                return true;
            }
            
            Fm.FileInfo? fi = dest_item.get_fileinfo ();
            
            // We can only allow dropping on desktop entry file or folder.
            if (fi != null
                && !fi.is_dir ()
                && !fi.is_desktop_entry ()
                && !fi.get_path ().is_trash_root ()) {
               
                Gdk.drag_status (drag_context, 0, time);
                return false;
            }

            // Move files with LibFm...
            target = Gdk.Atom.intern_static_string (dnd_targets[0].target);
            
            Gdk.DragAction action = 0;
            
#if !ENABLE_GTK3
// GTK3_TODO            
            if (Fm.drag_context_has_target (drag_context, target)
                && (drag_context.actions & Gdk.DragAction.MOVE) != 0) {
                    
                _fm_dnd_dest.set_dest_file (null);
                action = Gdk.DragAction.MOVE;
                
                target = _fm_dnd_dest.find_target (drag_context);
                
                if (target == Gdk.Atom.NONE) {
                    
                    Gdk.drag_status (drag_context, 0, time);
                    this._set_drop_hilight (dest_item);

                    return false;
                }
                
                _fm_dnd_dest.set_dest_file (fi);
                action = _fm_dnd_dest.get_default_action (drag_context, target);
            }
#endif
            Gdk.drag_status (drag_context, action, time);
            this._set_drop_hilight (dest_item);

            return (action != 0);
        }

        private void _on_drag_leave  (Gdk.DragContext drag_context,
                                      uint time) {
                                          
            /***************************************************************************************
             * From Gtk+ Reference Manual. (2.24)
             * 
             * The ::drag-leave signal is emitted on the drop site when the cursor leaves the
             * widget. A typical reason to connect to this signal is to undo things done in
             * "drag-motion", e.g. undo highlighting with gtk_drag_unhighlight()
             * 
             ***/
            
            stdout.printf ("%u: DRAG LEAVE !!!\n", time);
            
            _fm_dnd_dest.drag_leave (drag_context, time);

            if (drop_hilight != null) {
                
                drop_hilight.invalidate_rect (this.get_window ());
                drop_hilight = null;
            }

            //this.get_window ().set_cursor (crossed_circle);
            return;
        }

        private bool _on_drag_drop (Gtk.Widget dest_widget,
                                    Gdk.DragContext drag_context,
                                    int x,
                                    int y,
                                    uint time) {
                                        
            /***************************************************************************************
             * From Gtk+ Reference Manual. (2.24)
             * 
             * The ::drag-drop signal is emitted on the drop site when the user drops the data
             * onto the widget. The signal handler must determine whether the cursor position is
             * in a drop zone or not. If it is not in a drop zone, it returns FALSE and no further
             * processing is necessary. Otherwise, the handler returns TRUE.
             * 
             * In this case, the handler must ensure that gtk_drag_finish() is called to let the
             * source know that the drop is done. The call to gtk_drag_finish() can be done either
             * directly or in a "drag-data-received" handler which gets triggered by calling
             * gtk_drag_get_data() to receive the data for one or more of the supported targets.
             * 
             ***/
            
            // Check if we're dragging over an item.
            Desktop.Item dest_item = _grid.hit_test (x, y);
            
            Gdk.Atom target = Gdk.Atom.intern_static_string (dnd_targets[0].target);

// GTK3_TODO
#if !ENABLE_GTK3
            bool can_drop = (Fm.drag_context_has_target (drag_context, target)
                             && (drag_context.actions & Gdk.DragAction.MOVE) != 0);
#else
            bool can_drop = false;
#endif
            if (dest_item == null
                && can_drop) {
                
                _grid.move_items ((x - _drag_start_x), (y - _drag_start_y));
                
                Gtk.drag_finish (drag_context, true, false, time);

                this._grid.save_item_pos ();
                this._grid.queue_layout_items ();
                
                return true;
            }
            
            /*******************************************************************
             * Drop Into A Desktop Item.
             * 
             * Drop on Desktop Entry files, folders or Trash Can.
             * It seems that LibFm cannot detect if the file is executable !
             * 
             ***/
            Fm.FileInfo fi = dest_item.get_fileinfo ();
            
            if ((fi == null
                || fi.is_dir ()
                || fi.is_desktop_entry ()
                || fi.get_path ().is_trash_root ())
                && can_drop) {
                   
                target = _fm_dnd_dest.find_target (drag_context);
                
                if (_fm_dnd_dest.drag_drop (drag_context, target, x, y, time))
                    return true;
            }
            
            Gtk.drag_finish (drag_context, false, false, time);
            return false;
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
                    // Check if files are received.
                    _fm_dnd_dest.drag_data_received (drag_context, x, y, sel_data, info, time);
                break;
            }
        }

        private void _on_drag_data_get (Gdk.DragContext drag_context,
                                        Gtk.SelectionData sel_data,
                                        uint info,
                                        uint time) {
                                            
            // Desktop items are being dragged
            if (info == DesktopDndDest.DESKTOP_ITEM)
                Signal.stop_emission_by_name (this, "drag-data-get");
            
        }

        private void _on_dnd_src_data_get () {
            
            Fm.FileInfoList? files = _grid.get_selected_files ();
            
            if (files == null)
                return;
                
            _fm_dnd_src.set_files (files);
        }

        private bool _on_drag_failed (Gtk.Widget dest_widget, Gdk.DragContext drag_context, Gtk.DragResult result) {
            
            /***************************************************************************************
             * From Gtk+ Reference Manual. (2.24)
             * 
             * The ::drag-failed signal is emitted on the drag source when a drag has failed.
             * The signal handler may hook custom code to handle a failed DND operation based on
             * the type of error, it returns TRUE is the failure has been already handled
             * (not showing the default "drag operation failed" animation),
             * otherwise it returns FALSE.
             ***/
             
            stdout.printf ("DRAG FAILED !!!\n");
            return true;
        }
        
        
        /*******************************************************************************************
         * *** Widget Signal Handlers ***
         * 
         *     Single click...
         * 
         * 
         ******************************************************************************************/
        private bool _on_leave_notify (Gdk.EventCrossing evt) {
            
            /***
            if (this.single_click_timeout_handler) {
                Source.remove (this.single_click_timeout_handler);
                this.single_click_timeout_handler = 0;
            }
            ***/
            
            return true;
        }
        
        
        
        
        
        /*******************************************************************************************
         * Desktop background...
         * 
         * 
         ******************************************************************************************/
        public void set_background (bool set_root = false) {
            #if ENABLE_GTK3
            this._gtk3_set_background (set_root);
            #else
            this._gtk2_set_background (set_root);
            #endif
        }
        
#if ENABLE_GTK3
        private void _gtk3_set_background (bool set_root = false) {
            
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
                
// GTK3_TODO
                //Gdk.rgb_find_color (this.get_colormap (), ref bg);
                
                //window.set_back_pixmap (null, false);
                // DEPRECATED
                window.set_background (bg);
                
                if (set_root) {
                    Gdk.Window root = this.get_screen ().get_root_window ();
                    //root.set_back_pixmap (null, false);
                    // DEPRECATED
                    root.set_background (bg);
                    //root.clear ();
                }
                //window.clear ();
                window.invalidate_rect (null, true);
                return;
            }
            
            this._set_wallpaper ();
            
            return;
        }
#else        
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
        
        private void _set_wallpaper () {
            /*** This function is in TEMP.vala, currently unused... ***/
        }
        
        
        
        
        
        
        
        /*******************************************************************************************
         * Contextual Menus...
         * 
         * 
         * 
         ******************************************************************************************/
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
            
            Fm.FileInfoList<Fm.FileInfo>? files = _grid.get_selected_files ();
            if (files == null)
                return;
            
            // Create a menu and set the open folder function.
            _file_menu = new Fm.FileMenu.for_files (this, files, Fm.Path.get_desktop (), false);
            
            Gtk.ActionGroup act_grp = _file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            _popup_menu = _file_menu.get_menu ();
            
            if (_popup_menu != null)
                _popup_menu.popup (null, null, null, 3, evt.time);
            
            return;
        }
        
        
        
        
        
        
        
        
        
        
        /*******************************************************************************************
         * Application actions...
         * 
         * 
         * 
         ******************************************************************************************/
        private bool _action_open_file (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            /*** how to handle different file types ???
            fi.is_desktop_entry ()
            fi.is_shortcut ()
            fi.is_executable_type ();
            fi.is_hidden ();
            fi.is_image ();
            fi.is_text ();
            fi.is_symlink () ***/
            
            if (fi.is_dir ()
            || fi.is_mountable ()
            || fi.is_unknown_type ()) { /* TODO use is_uri () ??? or something... */
                
                this._action_open_folder (fi);
            
            /***} else if (fi.is_unknown_type ()) {
                stdout.printf ("Special item !!!\n"); ***/
            } else {
                
                Fm.launch_file (this, null, fi, null);
            }
            
            return true;
        }
        
        private bool _action_open_folder (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            if (global_manager_group == null)
                global_manager_group = new Manager.Group (_debug_mode);
            
            string[] folders = {};
            folders[0] = fi.get_path ().to_str ();
            folders[1] = "";
            global_manager_group.create_manager (folders);
            
            return true;
        }
        
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
    }
}


