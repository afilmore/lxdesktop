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
        private const Gtk.ActionEntry _desktop_actions[] = {
            {"CreateNew",       null,                   N_("Create _New..."),
                                "",                     null,                       null},
            {"NewFolder",       "folder",               N_("Folder"),
                                "<Ctrl><Shift>N",       null,                       _on_action_new_folder},
            {"NewBlank",        "text-x-generic",       N_("Blank File"),
                                null,                   null,                       _on_action_new_file},
            {"Paste",           Gtk.Stock.PASTE,        null,
                                null,                   null,                       _on_action_paste},
            {"SelAll",          Gtk.Stock.SELECT_ALL,   null,
                                null,                   null,                       _on_action_select_all},
            {"InvSel",          null,                   N_("_Invert Selection"),
                                "<Ctrl>I",              null,                       _on_action_invert_select},
            {"Sort",            null,                   N_("_Sort Files"),
                                null,                   null,                       null},
            {"Prop",            Gtk.Stock.PROPERTIES,   N_("Desktop Preferences"),
                                "<Alt>Return",          null,                       _on_action_desktop_settings}
        };
        
        private const string _desktop_menu_xml = """
            <popup>
                <menu action='CreateNew'>
                    <menuitem action='NewFolder'/>
                    <menuitem action='NewBlank'/>
                </menu>
                <separator/>
                <placeholder name='ph1'/>
                <separator/>
                <menuitem action='Paste'/>
                <separator/>
                <menuitem action='SelAll'/>
                <menuitem action='InvSel'/>
                <separator/>
                <menuitem action='Prop'/>
            </popup>
        """;

        // The desktop grid
        private Desktop.Grid    _grid;
        
        // Rubber banding / Drag And Drop
        private bool            _rubber_started = false;
        private int             _rubber_bending_x = 0;
        private int             _rubber_bending_y = 0;
        private bool            _button_pressed = false;
        private int             _drag_start_x = 0;
        private int             _drag_start_y = 0;
        private bool            _dnd_started = false;
        
        private Fm.DndSrc       _dnd_src;
        private Fm.DndDest      _dnd_dest;
        
        /*********************************************************************************
         * Single click...
         * 
         * uint single_click_timeout_handler;
         * private GdkCursor* hand_cursor = null;
         * hand_cursor = gdk_cursor_new (GDK_HAND2);
         *
         ********************************************************************************/
        
        // show the window manager menu
        private bool            _show_wm_menu = false;
        private Gtk.Menu?       _desktop_popup;
        private Gtk.Menu?       _popup_menu;
        private Fm.FileMenu     _file_menu; // doesn't work if not global........
        
        public Window () {
            
            this.destroy.connect ( () => {
                
                _grid.save_item_pos ();
                
                Gtk.main_quit ();
            });
            
            this.realize.connect                (_on_realize);
            this.size_allocate.connect          (_on_size_allocate);
            this.size_request.connect           (_on_size_request);
            
            this.expose_event.connect           (_on_expose);
            
            this.button_press_event.connect     (_on_button_press);
            this.button_release_event.connect   (_on_button_release);
            this.motion_notify_event.connect    (_on_motion_notify);
            
            this.drag_motion.connect            (_on_drag_motion);
            this.drag_drop.connect              (_on_drag_drop);
            this.drag_data_received.connect     (_on_drag_data_received);
            this.drag_leave.connect             (_on_drag_leave);
            
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
            /*** global_model.row_changed.connect (this.get_grid ().on_row_changed); ***/
            /*** global_model.rows_reordered.connect (this.get_grid ().on_rows_reordered); ***/
            
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
                                 desktop_default_dnd_dest_targets, // doesn't build with Fm.default_dnd_dest_targets...
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

        private bool _on_expose (Gdk.EventExpose evt) {
            
            /* stdout.printf ("_on_expose: visible=%u, mapped=%u\n",
                              (uint) this.get_visible (),
                              (uint) this.get_mapped ());*/
            
            if (this.get_visible () == false || this.get_mapped () == false)
                return true;

            Cairo.Context cr = Gdk.cairo_create (this.get_window ());
            
            // rubber bending
            if (_rubber_started == true)
                this._paint_rubber_banding_rect (cr, evt.area);

            // draw desktop icons
            this._grid.draw_items_in_rect (cr, evt.area);
            
            // cr.destroy (); ?????
            
            return true;
        }


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
                
                // action open........
                if (clicked_item.is_special)
                    return true; // TODO: open/browse special items...
                
                Fm.FileInfo? fi = clicked_item.get_fileinfo ();
                
                if (fi.is_dir ()
                || fi.is_mountable ()) {
                    
                    this.action_open_folder (fi);
                
                } else if (fi.is_unknown_type ()) {
                
                } else {
                    
                    this.action_open_file (fi);
                }
                
                if (this.has_focus == 0)
                    this.grab_focus ();
                
                return true;
                
            
            /*********************************************************
             * Single click...
             * 
             * 
             ********************************************************/
            } else if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                
                // left button, save state for drag and drop
                if (evt.button == 1) {
                    
                    this._button_pressed = true;
                    this._drag_start_x = (int) evt.x;
                    this._drag_start_y = (int) evt.y;
                }

                // if ctrl / shift is not pressed, deselect all, don't cancel selection if clicking on selected items
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

                    _grid.set_selected_item (clicked_item);
                    
                    
                    clicked_item.redraw (this.get_window ());

                    if (evt.button == 3)
                        this._create_popup_menu (evt);
                        
                    if (this.has_focus == 0)
                        this.grab_focus ();
                    
                    return true;
                
                // start rubber banding
                } else if (evt.button == 1) {
                        
                    Gtk.grab_add (this);
                    
                    this._rubber_started = true;
                    this._rubber_bending_x = (int) evt.x;
                    this._rubber_bending_y = (int) evt.y;
                    
                    if (this.has_focus == 0)
                        this.grab_focus ();
                    
                    return true;
                
                
                /*************************************************************************
                 * Desktop Popup Menu
                 * 
                 */
                } else if (evt.button == 3 && this._show_wm_menu == false) {
                            
                    // is it needed to destroy/unref previous created menu ???
                    
                    _desktop_popup = this._create_desktop_popup ();
                    
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
            
            // forward the event to root window
            Gdk.Event* real_e = (Gdk.Event*)(&evt);
            XLib.forward_event_to_rootwin (this.get_screen(), real_e);

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
            
            // Open File/folder with single click...
            } else if (global_config.single_click == true && evt.button == 1) {
                
                if (clicked_item != null) {
                    
                    /*** Left Single Click ***

                    Fm.launch_file_simple (this, null, fi, null); */
                    
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

        
        /*******************************************************************************************
         * *** Widget Signal Handlers ***
         * 
         *     Drag And Drop Handling
         * 
         * 
         * 
         ******************************************************************************************/
        private bool _on_drag_motion (Gtk.Widget dest_widget,
                                      Gdk.DragContext drag_context,
                                      int x,
                                      int y,
                                      uint time) {
            
            Gdk.Atom target;
            bool ret = false;
            Gdk.DragAction action = 0;
            
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
                       
                    stdout.printf ("move item\n");
                    _grid.move_items (x, y, _drag_start_x, _drag_start_y);
                    
                    ret = true;
                    
                    Gtk.drag_finish (drag_context, true, false, time);

                    this._grid.save_item_pos ();

                    this._grid.queue_layout_items ();
                }
            }

            if (ret) {
                
                target = this._dnd_dest.find_target (drag_context);
                
                // try FmDndDest
                stdout.printf ("try FmDndDest\n");
                ret = this._dnd_dest.drag_drop (drag_context, target, x, y, time);
                
                if (ret == false) {
                    stdout.printf ("failed\n");
                    Gtk.drag_finish (drag_context, false, false, time);
                }
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
                    this._dnd_dest.drag_data_received (drag_context, x, y, sel_data, info, time);
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


        /*******************************************************************************************
         * *** Widget Signal Handlers ***
         * 
         *     Single click...
         * 
         * 
         ******************************************************************************************/
        private bool _on_leave_notify (Gdk.EventCrossing evt) {
            
            /*
            if (this.single_click_timeout_handler) {
                Source.remove (this.single_click_timeout_handler);
                this.single_click_timeout_handler = 0;
            }
            */
            
            return true;
        }
        
        
        /*******************************************************************************************
         * Desktop background...
         * 
         * 
         ******************************************************************************************/
        public void set_background () {
            
            Gdk.Window window = this.get_window ();
            Gdk.Window root = this.get_screen ().get_root_window ();
            
            Fm.WallpaperMode wallpaper_mode = global_config.wallpaper_mode;
            Gdk.Pixbuf? pix;
            
            if (wallpaper_mode == Fm.WallpaperMode.COLOR
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
            
            this._set_wallpaper ();
            
            return;
        }
        
        private void _set_wallpaper () {
            /*** This function is in TEMP.vala, currently unused... ***/
        }
        
        
        /*******************************************************************************************
         * Contextual Menus...
         * 
         * 
         * 
         ******************************************************************************************/
        private Gtk.Menu _create_desktop_popup () {
            
            Gtk.ActionGroup act_grp = new Gtk.ActionGroup ("Desktop");
            act_grp.set_translation_domain (null);
            act_grp.add_actions (_desktop_actions, this);
            
            Gtk.UIManager ui = new Gtk.UIManager ();
            ui.insert_action_group (act_grp, 0);
            ui.add_ui_from_string (_desktop_menu_xml, -1);
        
            Gtk.AccelGroup accel_group = ui.get_accel_group ();
            this.add_accel_group (accel_group);
        
            string xml_def =    "<popup>\n";
            xml_def +=              "<placeholder name='ph1'>\n";
            
            File template_dir = File.new_for_path (Environment.get_user_special_dir (UserDirectory.TEMPLATES));
            
            FileEnumerator infos = template_dir.enumerate_children (
                "standard::*", FileQueryInfoFlags.NONE);
            
            FileInfo info;
            while ((info = infos.next_file ()) != null) {
                
                FileType type = info.get_file_type();
                
                if (type != FileType.REGULAR /*** && type != FileType.SYMBOLIC_LINK ***/)
                    continue;
                
                string file_name = info.get_name ();
                string file_description = ContentType.get_description (info.get_content_type ());
                    
                Gtk.Action action = new Gtk.Action (file_name,
                                                    file_description,
                                                    "test tooltip...",
                                                    null);
                
                action.activate.connect (this._test_template);
                //gtk_action_set_gicon(act, g_app_info_get_icon(app));
                
                act_grp.add_action (action);
                
                xml_def += "<menuitem action='%s'/>\n".printf (file_name);
            };

            xml_def +=      "</placeholder>\n";
            xml_def +=  "</popup>\n";
            
            ui.add_ui_from_string (xml_def, -1);

            return ui.get_widget ("/popup") as Gtk.Menu;
        }
        
        private void _create_popup_menu (Gdk.EventButton evt) {
            
            /*
            bool all_fixed = true;
            bool has_fixed = false;
             
            List<Desktop.Item> sel_items = _grid.get_selected_items (null);
            
            foreach (Desktop.Item item in sel_items) {
                
                fi = item.get_fileinfo ();
                
                if (fi == null)
                    continue;
                    
                files.push_tail (fi);
                
                if (item.fixed_pos == true)
                    has_fixed = true;
                else
                    all_fixed = false;
            }*/
            
            Fm.FileInfoList<Fm.FileInfo>? files = _grid.get_selected_files ();
            if (files == null)
                return;
            
            // create a menu and set the open folder function.
            _file_menu = new Fm.FileMenu.for_files (this, files, Fm.Path.get_desktop (), false);
            _file_menu.set_folder_func ((Fm.LaunchFolderFunc) this.action_open_folder_func);
            
            Gtk.UIManager ui = _file_menu.get_ui ();
            Gtk.ActionGroup act_grp = _file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            Fm.FileInfo? fi = files.peek_head ();
            
            // merge some specific menu items for folders
            /*if (_file_menu.is_single_file_type () && fi.is_dir ()) {
                act_grp.add_actions (folder_menu_actions, _file_menu);
                ui.add_ui_from_string (folder_menu_xml, -1);
            }*/
            
            // snap to grid...
            // act_grp.add_actions (desktop_icon_actions, this);
            
            // stick to current position...
            // desktop_icon_toggle_actions[0].is_active = all_fixed;
            // act_grp.add_toggle_actions (desktop_icon_toggle_actions, this);
            
            //Gtk.Action act;
            
            // snap to grid
            /*if (has_fixed == false) {
                act = act_grp.get_action ("Snap");
                act.set_sensitive (false);
            }*/
            
            //ui.add_ui_from_string (desktop_icon_menu_xml, -1);
            
            _popup_menu = _file_menu.get_menu ();
            
            if (_popup_menu != null)
                _popup_menu.popup (null, null, null, 3, evt.time);
            
        }
        
        
        /*******************************************************************************************
         * Application actions...
         * 
         * 
         * 
         ******************************************************************************************/
        public bool action_open_file (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            //~ fi.is_desktop_entry ()
            //~ fi.is_shortcut ()
            //~ fi.is_executable_type ();
            //~ fi.is_hidden ();
            //~ fi.is_image ();
            //~ fi.is_text ();
            //|| fi.is_symlink ()
            
            Fm.launch_file_simple (this, null, fi, null);
            
            return true;
        }
        
        public bool action_open_folder_func (GLib.AppLaunchContext ctx,
                                             GLib.List<Fm.FileInfo>? folder_infos,
                                             void* user_data) {
            
            stdout.printf ("DesktopWindow.action_open_folder_func:\n");
            stdout.printf ("\tAppLaunchContext = %#x \n", (uint) ctx);
            stdout.printf ("\tGLib.List = %#x \n", (uint) folder_infos);
            stdout.printf ("\tuser_data = %#x \n", (uint) user_data);
            stdout.printf ("\tDesktopWindow = %#x \n", (uint) this);
            
            /* ***************************************************************************
             * WARNING !!!
             * There's a problem in the Vapi file definition for this function,
             * folder_infos is given as the first parameter which is wrong of course...
             */
            unowned List<Fm.FileInfo>? folder_list = (GLib.List<Fm.FileInfo>) ctx;
            
            if (folder_list == null)
                stdout.printf ("DesktopWindow.action_open_folder_func: GLib.List folder_infos = (null)\n");
            
            foreach (Fm.FileInfo fi in folder_list) {
                
                action_open_folder (fi);
            }
            return true;
        }
        
        public bool action_open_folder (Fm.FileInfo? fi) {
            
            if (fi == null)
                return false;
                
            // FIXME: doesn't work if contains spaces...
            string cmdline = global_config.app_filemanager + " " + fi.get_path ().to_str ();
            
            try {
                Process.spawn_command_line_async (cmdline);
            } catch (Error e) {
                stdout.printf ("action_open_folder cannot open %s\n", cmdline);
            }
            
            return true;
        }
        
        private void _on_action_new_folder (Gtk.Action action) {
            
            this._filemanager_new_document (Fm.Path.get_desktop(), Utils.NewFileNameType.FOLDER);
        }

        private void _on_action_new_file (Gtk.Action action) {
            
            this._filemanager_new_document (Fm.Path.get_desktop(), Utils.NewFileNameType.FILE);
        }

        private void _test_template (Gtk.Action action) {
            
            this._filemanager_new_document (Fm.Path.get_desktop(),
                                            Utils.NewFileNameType.FROM_DESCRIPTION,
                                            action.name,
                                            action.label);
        }
        
        private void _filemanager_new_document (Fm.Path base_dir,
                                                Utils.NewFileNameType file_type,
                                                string template_name = "",
                                                string template_description = "") {
            
            string msg;
            string tmp_name = "";
            
            bool create_from_template = false;
            
            if (file_type == Utils.NewFileNameType.FOLDER) {
                
//~                 msg = "Enter a name for the newly created folder:";
//~                 tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
//~                 
//~                 if (!dest_file.make_directory (null)) {
//~                     
//~                     stdout.printf ("ERRORRRRRR !!!!!!!\n");
//~                     //fm_show_error (parent, null, err->message);
//~                 }

            } else if (file_type == Utils.NewFileNameType.FROM_DESCRIPTION) {
                
                Fm.Path template_dir = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.TEMPLATES));
                Fm.Path template = new Fm.Path.child (template_dir, template_name);
                
                tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
                Fm.Path dest_file = new Fm.Path.child (base_dir, tmp_name);
                
                stdout.printf ("Fm.copy_file %s %s\n", template.to_str (), dest_file.to_str ());
                
                //Fm.copy_file (this, template, base_dir);
                
                File file = template.to_gfile ();
                file.copy (dest_file.to_gfile (), FileCopyFlags.NONE);
                
                string cmdline = "xdg-open \"%s\"".printf (dest_file.to_str ());
                
                try {
                    Process.spawn_command_line_async (cmdline);
                } catch (Error e) {
                    stdout.printf ("action_open_folder cannot open %s\n", cmdline);
                }
                
                // we don't have a file info :(
                //Fm.launch_file_simple (this, null, fi, null);
                
                return;
            
            } else if (file_type == Utils.NewFileNameType.FILE) {
                
                msg = "Enter a name for the newly created file:";
                tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
                
//~                 FileOutputStream f = dest_file.create (FileCreateFlags.NONE);
//~                 if (f == null) {
//~                     
//~                     stdout.printf ("ERRORRRRRR !!!!!!!\n");
//~                     //fm_show_error (parent, null, err->message);
//~                 
//~                 } else {
//~                     
//~                     f.close ();
//~                 }
            }
            
//~             string test_name = "";
//~             Fm.Path dest;
//~             File dest_file = null;
//~             
            /*int max_tries = 50;
            for (int i = 1; i < max_tries; i++) {
                
                test_name = "New%s(%d)".printf (tmp_name, i);
                
                dest = new Fm.Path.child (base_dir, test_name);
                dest_file = dest.to_gfile ();
                if (!dest_file.query_exists ())
                    break;
            }*/
            
            // ask user for a file name...
//~             string basename = Fm.get_user_input (null, _("Create New..."), _(msg), test_name);
//~             
//~             if (basename == null || basename == "" || dest_file == null)
//~                 return;
//~             
            
            return;
        }
        
        private void _on_action_paste (Gtk.Action action) {
            
            Fm.Path path = Fm.Path.get_desktop ();
            Fm.Clipboard.paste_files (this, path);
        }

        private void _on_action_select_all (Gtk.Action action) {
            
            /*
            int i;
            for(i=0; i < n_screens; ++i)
            {
                FmDesktop* desktop = desktops[i];
                select_all(desktop);
            }
            */
        }

        private void _on_action_invert_select (Gtk.Action action) {
            
            /*
            int i;
            for(i=0; i < n_screens; ++i)
            {
                FmDesktop* desktop = desktops[i];
                GList* l;
                for(l=desktop->items;l;l=l->next)
                {
                    FmDesktopItem* item = (FmDesktopItem*)l->data;
                    item->is_selected = !item->is_selected;
                    redraw_item(desktop, item);
                }
            }*/
        }

        private void _on_action_desktop_settings (Gtk.Action action) {
            return;
        }
    }
}


