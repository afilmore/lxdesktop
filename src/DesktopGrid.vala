/***********************************************************************************************************************
 * DesktopGrid.vala
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
    
    const int SPACING = 2;
    const int PADDING = 6;
//    const int MARGIN = 2;

    
    /*******************************************************************************************************************
     * The Desktop grid basically contains a linked list to store desktop items and the desktop working area.
     * 
     * 
     ******************************************************************************************************************/
    public class Grid {
        
        private bool _debug_mode = false;
        
        // Desktop Widget
        private Gtk.Window _desktop;
        private Gdk.Window _window;
        uint _idle_layout = 0;
        
        // The list of Desktop items
        private List<Desktop.Item> _grid_items;
        
        // Desktop working area, this working area doesn't include docked panels
        private Gdk.Rectangle _working_area;
        
        // Geometry of one cell in the grid, index of last cells
        private int _cell_width = 50;
        private int _cell_height = 50;
        private uint _index_last_v = 0;
        private uint _index_last_h = 0;
        
        // List fixed_items;
        private Desktop.Item? _selected_item = null;
        private Desktop.Item? _drop_hilight = null;
        private Desktop.Item? _hover_item = null;

        // Icon Pixbuf renderer, replace with a Fm.CellRendererPixbuf later
        private Gtk.CellRendererPixbuf _icon_renderer;
        
        // Text drawing...
        // GTK3_MIGRATION
        private Gdk.GC _gc;
        private Pango.Layout _pango_layout;
        uint _text_h = 0;
        uint _text_w = 0;
        uint _pango_text_h = 0;
        uint _pango_text_w = 0;
        
        
        public Grid (Gtk.Window desktop, bool debug = false) {
            
            _desktop = desktop;
            _debug_mode = debug;
            
            _grid_items = new List<Desktop.Item> ();
            
            // setup pango layout.
            _pango_layout = _desktop.create_pango_layout (null);
            _pango_layout.set_alignment (Pango.Alignment.CENTER);
            _pango_layout.set_ellipsize (Pango.EllipsizeMode.END);
            _pango_layout.set_wrap (Pango.WrapMode.WORD_CHAR);
            
            
            /***********************************************************************************************************
             * Create the Pixbuf renderer, start with a GtkPixbufRenderer and switch to a FmPixbufRenderer later.
             * 
             * 
            _icon_renderer = new Fm.CellRendererPixbuf ();
            Object.set (_icon_renderer, "follow-state", true, null);
            Object.ref_sink (_icon_renderer);
            _icon_renderer.set_fixed_size (global_config.big_icon_size, global_config.big_icon_size);
            */
            
            _icon_renderer = new Gtk.CellRendererPixbuf ();
            _icon_renderer.set ("follow-state", true, null);
            _icon_renderer.ref_sink ();
            _icon_renderer.set_fixed_size ((int) global_config.big_icon_size, (int) global_config.big_icon_size);
        }
        
        ~Grid () {
        
            if (this._idle_layout != 0)
                Source.remove (this._idle_layout);
        }
        
        
        /***************************************************************************************************************
         * This function is called from the realize handler,
         * from the desktop's GtkWindow.
         * 
         * 
         * ************************************************************************************************************/
        public void init_gc (Gdk.Window window) {
            
            _window = window;
            
            // GTK3_MIGRATION
            this._gc = new Gdk.GC (window);
        }
        
        
        /***************************************************************************************************************
         * Initialize the grid..., this function is called from the size_allocate handler,
         * from the desktop's GtkWindow.
         * 
         * 
         * ************************************************************************************************************/
        public void init_layout (Gdk.Rectangle rect) {
            
            _window = _desktop.get_window ();

            if (_debug_mode == true) {
                
                _working_area.x = 0;
                _working_area.y = 0;
                _working_area.width = rect.width;
                _working_area.height = rect.height;
                
            } else {
                
                XLib.get_working_area (_desktop.get_screen (), out _working_area);
                
                // stdout.printf ("%i, %i, %i, %i\n",
                //                _working_area.x,
                //                _working_area.y,
                //                _working_area.width,
                //                _working_area.height);
            }
            
            
            /***********************************************************************************************************
             * From Gtk+ docs :
             * The Pango.SCALE constant represents the scale between dimensions used for Pango distances and device
             * units. (The definition of device units is dependent on the output device; it will typically be pixels
             * for a screen, and points for a printer.) Pango.SCALE is currently 1024, but this may be changed in the
             * future. When setting font sizes, device units are always considered to be points
             * (as in "12 point font"), rather than pixels.
             */
            Pango.Context pango_context = _desktop.get_pango_context ();
            Pango.FontMetrics metrics = pango_context.get_metrics (null, null);

            int font_h = (metrics.get_ascent () + metrics.get_descent ()) / Pango.SCALE;
            
            // set the text rect to a maximum of 72 pixels width and two lines of text.
            this._text_w = 72;
            this._text_h = font_h * 2;
            
            this._pango_text_w = _text_w * Pango.SCALE;
            this._pango_text_h = _text_h * Pango.SCALE;
            
            // 4 is for drawing border
            _text_h += 4;
            _text_w += 4;
            
            // stdout.printf ("font_h:%i, text_h:%i, text_w:%i, pango_text_h:%u, pango_text_w:%u\n",
            //               font_h, text_h, text_w, _pango_text_h, _pango_text_w);
            
            _cell_height = (int) global_config.big_icon_size + SPACING + (int) _text_h + PADDING * 2;
            _cell_width = int.max ((int) _text_w, (int) global_config.big_icon_size) + PADDING * 2;
            
            _index_last_v = (_working_area.height / _cell_height) -1;
            _index_last_h = (_working_area.width / _cell_width) -1;
            
            this.queue_layout_items ();
            
            return;
        }
        
        
        /***************************************************************************************************************
         * Drawing...
         *
         * 
         **************************************************************************************************************/
        public void draw_items (Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                //stdout.printf ("expose event => grid.draw_items () x = %i, y = %i, w = %i, h = %i\n",
                //               item.text_rect.x,
                //               item.text_rect.y,
                //               item.text_rect.width,
                //               item.text_rect.height);
            
                Gdk.Rectangle? intersect = null;
                
                Gdk.Rectangle tmp;
                if (expose_area.intersect (item.icon_rect, out tmp) == true)
                    intersect = tmp;
                else
                    intersect = null;

                Gdk.Rectangle tmp2;
                if (expose_area.intersect (item.text_rect, out tmp2) == true) {
                    if (intersect != null)
                        intersect.union (tmp2, out intersect);
                    else
                        intersect = tmp2;
                }

                if (intersect != null)
                    this._draw_item (item, cr, intersect);
            }
        }
        
        private void _draw_item (Desktop.Item item, Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            // stdout.printf ("item.draw: %i, %i, %i, %i\n", expose_area.x, expose_area.y, expose_area.width, expose_area.height);
            
            // GTK3_MIGRATION
            Gtk.CellRendererState state = 0;
            
            Desktop.Item? drop_hilight = null; // temporary fake item....
            
            // selected item
            if (item.is_selected == true || item == drop_hilight)
                state = Gtk.CellRendererState.SELECTED;
            
            
            /***********************************************************************************************************
             * Draw the icon...
             * 
             * Fm.CellRendererPixbuf needs to be ported to GTK3, it's reeded to draw the small arrow for symlinks...
             * 
             * 
            renderer.set ("pixbuf", item.icon, "info", item._fileinfo.ref (), null);
            renderer.render (desktop.get_window (),
                             desktop,
                             this.icon_rect,
                             this.icon_rect,
                             expose_area,
                             state);
             **********************************************************************************************************/
            this._icon_renderer.set ("pixbuf", item.icon);
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

            // FIXME: do we need to cache this?
            int text_x = (int) item.origin_x + (_cell_width - (int) _text_w) / 2 + 2;
            int text_y = (int) item.icon_rect.y + item.icon_rect.height + 2;

            // draw background for text label
            Gtk.Style style = _desktop.get_style ();
            Gdk.Color fg;
            
            // selected item
            if (state == Gtk.CellRendererState.SELECTED) {
                
                cr.save ();
                Gdk.cairo_rectangle (cr, item.text_rect);
                Gdk.cairo_set_source_color (cr, style.bg[Gtk.StateType.SELECTED]);
                cr.clip ();
                cr.paint ();
                cr.restore ();
                
                fg = style.fg[Gtk.StateType.SELECTED];
                
            // normal item / text shadow
            } else {
                
                _gc.set_rgb_fg_color (global_config.color_shadow);
                Gdk.draw_layout (_window,
                                 this._gc,
                                 text_x + 1,
                                 text_y + 1,
                                 this._pango_layout);
                
                fg = global_config.color_text;
            }
            
            // real text
            _gc.set_rgb_fg_color (fg);
            
            Gdk.draw_layout (_window,
                             this._gc,
                             text_x,
                             text_y,
                             this._pango_layout);
            
            _pango_layout.set_text ("", 0);

            // draw a selection rectangle for the selected item
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
        
        
        public void move_items (int x, int y, int drag_x, int drag_y) {
            
            // desktop items are being dragged
            int offset_x = x - drag_x;
            int offset_y = y - drag_y;

            foreach (Desktop.Item item in _grid_items) {
//                this.move_item (item2, item2.x + offset_x, item2.y + offset_y, false);
            }
        }

        public void append_item (Desktop.Item item) {
            
            unowned List<Desktop.Item>? last = _grid_items.last ();
            
            // The list is empty, set the item on the first grid cell (0, 0)
            if (last == null) {
            
                item.index_horizontal = 0;
                item.index_vertical = 0;
                
                this._calc_item_size (item);
                _grid_items.append (item);
                
                return;
            }
            
            Desktop.Item? previous = last.data as Desktop.Item;
            
            // If current vertical row is full, append on the next row
            if (previous.index_vertical + 1 > _index_last_v) {
                item.index_vertical = 0;
                item.index_horizontal = previous.index_horizontal + 1;
                
                    if (previous.index_horizontal > _index_last_h) {
                        // the grid is full... :-D
                        return;
                    }
                    
                this._calc_item_size (item);
                _grid_items.append (item);
                
                return;
            }
            
            if (previous.index_horizontal > _index_last_h) {
                // the grid is full... :-D
                return;
            }
            
            item.index_vertical = previous.index_vertical + 1;
            item.index_horizontal = previous.index_horizontal;
            
            this._calc_item_size (item);
            _grid_items.append (item);
                        
            return;
        }
        
        private void _calc_item_size (Desktop.Item item) {

            string disp_name = item.get_disp_name ();
            // get text size...
            _pango_layout.set_text ("", 0);
            _pango_layout.set_height ((int) _pango_text_h);
            _pango_layout.set_width ((int) _pango_text_w);
            _pango_layout.set_text (disp_name, -1);

            Pango.Rectangle logical_rect;
            _pango_layout.get_pixel_extents (null, out logical_rect);
            _pango_layout.set_text ("", 0);

            // set icon / text size...
            item.icon_rect.width =  (int) global_config.big_icon_size;
            item.icon_rect.height = (int) global_config.big_icon_size;
            item.text_rect.width =  logical_rect.width + 4;
            item.text_rect.height = logical_rect.height + 4;

            // origin on the grid...
            item.origin_x = (item.index_horizontal * _cell_width);
            item.origin_y = (item.index_vertical * _cell_height);
            
            // icon / text position...
            item.icon_rect.x = item.origin_x + (_cell_width - item.icon_rect.width) / 2;
            item.icon_rect.y = item.origin_y;
            
            // FIXME seems incorrect....
            item.text_rect.x = item.origin_x + (_cell_width - logical_rect.width - 4) / 2;
            item.text_rect.y = item.icon_rect.y + item.icon_rect.height + logical_rect.y;
            // FIXME: do we need to cache this?
            //int text_x = (int) item.origin_x + (_cell_width - (int) _text_w) / 2 + 2;
            //int text_y = (int) item.icon_rect.y + item.icon_rect.height + 2;
            
            
            /***********************************************************************************************************
             * The way PCManFm does it, it's a bit different :-D
             * 
             * 
            item.icon_rect.width =  gdk_pixbuf_get_width (item.icon);
            item.icon_rect.height = gdk_pixbuf_get_height (item.icon);
            item.icon_rect.x =      item.x + (_cell_width - item.icon_rect.width) / 2;
            item.icon_rect.y =      item.y + PADDING + (global_config.big_icon_size - item.icon_rect.height) / 2;
            item.icon_rect.height   += SPACING;
            
            */

        }

        public void queue_layout_items () {
            
            if (_idle_layout == 0)
                _idle_layout = GLib.Idle.add ((SourceFunc) this._on_idle_layout);
        }

        private bool _on_idle_layout () {
            
            this._idle_layout = 0;
            this._layout_items ();
            return false;
        }

        private void _layout_items () {
            
            //stdout.printf ("_layout_items\n");
            
            // the original function is different... see Grid.append_item ()
            
            //this.queue_draw ();
        }


        /***************************************************************************************************************
         * Items selection.
         * 
         * 
         **************************************************************************************************************/
        static inline bool point_in_rect (double x, double y, Gdk.Rectangle rect) {
            
            return ((x > rect.x) &&  (x < (rect.x + rect.width)) && (y > rect.y) && (y < (rect.y + rect.height)));
        }

        public Desktop.Item? hit_test (double x, double y) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                if (Grid.point_in_rect (x, y, item.icon_rect)
                    || Grid.point_in_rect (x, y, item.text_rect))
                    return item;
            }
            
            return null;
        }

        /***************************************************************************************************************
         * Select items when moving the rubber banding...
         * 
         **************************************************************************************************************/
        public void update_selection (Gdk.Rectangle rect) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                bool selected;
                if (rect.intersect (item.icon_rect, null)
                    || rect.intersect (item.text_rect, null))
                    selected = true;
                else
                    selected = false;

                if (item.is_selected != selected) {
                    item.is_selected = selected;
                    item.redraw (_window);
                }
            }
        }
        
        public void set_selected_item (Desktop.Item? item) {
            
            if (this._selected_item != null)
                _selected_item.redraw (_window);
            
            this._selected_item = item;
            
        }

        public void deselect_all () {
            
            foreach (Desktop.Item item in _grid_items) {
                if (item.is_selected == true) {
                    item.is_selected = false;
                    item.redraw (_window);
                }
            }
        }
        
        public Fm.FileInfoList? get_selected_files () {
            
            Fm.FileInfoList<Fm.FileInfo> files = new Fm.FileInfoList<Fm.FileInfo> ();
            
            int num_files = 0;
            
            foreach (Desktop.Item item in _grid_items) {
                
                if (item.is_selected) {
                    files.push_tail (item.get_fileinfo ());
                    num_files++;
                }
            }
            
            //stdout.printf ("%i files added\n", num_files);
            
            if (files.is_empty())
                return null;
            
            return files;
        }
        
        
        /***************************************************************************************************************
         * Folder Model functions. When files/folders on the desktop have been changed, created, deleted, etc...
         * The model sends a signal and these functions are called. 
         * 
         * 
         * ************************************************************************************************************/
        public void on_row_inserted (Gtk.TreePath path, Gtk.TreeIter it) {
            
            stdout.printf ("on_row_inserted\n");
            
            return; // needs testing...
            
            Gdk.Pixbuf icon;
            Fm.FileInfo fi;
            
            global_model.get (it, Fm.FileColumn.ICON, out icon, Fm.FileColumn.INFO, out fi, -1);
            
            Desktop.Item item = new Desktop.Item (icon, fi);
            
            // ????
            weak int[] indices = path.get_indices ();
            this.append_item (item);
            
            //this.queue_layout_items (); // needed ???
        }

        public void on_row_deleted (Gtk.TreePath tp) {
            
            stdout.printf ("on_row_deleted\n");
            
            return; // needs testing...
            
            int current = -1;
            int idx = tp.get_indices () [0];
            
            unowned List<Desktop.Item>? list;
            
            for (list = _grid_items; list != null; list = list.next) {
                
                current++;
                Desktop.Item? item = list.data as Desktop.Item;
                
                if (current == idx) {
                    
                    if (item == _selected_item) {
                        
                        if (list.next != null) {
                            
                            _selected_item = list.next.data as Desktop.Item;
                        
                        } else if (list.prev != null) {
                            
                            _selected_item = list.prev.data as Desktop.Item;
                            
                        } else {
                            
                            _selected_item = null;
                        }
                    }
                    
                    if (item == _drop_hilight)
                        _drop_hilight = null;
                    if (item == _hover_item)
                        _hover_item = null;
                    
                    _grid_items.delete_link (list);
                    
                    free (item);
                    
                    //queue_layout_items (desktop);
                    return;
                }
            }
        
            return;    
        }

        public void on_row_changed (Gtk.TreePath tp, Gtk.TreeIter it) {
            
            stdout.printf ("on_row_changed\n");
            
            return; // needs testing...

            foreach (Desktop.Item item in _grid_items) {
                
                /*******************************************************************************************************
                 * We don't have the item's TreeIter...
                 * 
                 * 
                if (item.it.user_data == it.user_data) {
                    
                    if (item.icon != null)
                        item.icon = null; // g_object_unref (item.icon);
                    
                    Fm.FileInfo fi; // must set the new fileinfo ????
                    
                    global_model.get (it, Fm.FileColumn.ICON, out item.icon, Fm.FileColumn.INFO, out fi, -1);
                            
                    item.redraw (_window);
                    
                    // FIXME: check if sorting of files is changed.
                    // queue_layout_items(desktop); // needed ???
                    
                    return;
                }
                
                */
            }
            
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
    }
}


