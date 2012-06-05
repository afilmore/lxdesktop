/***********************************************************************************************************************
 * DesktopGrid.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: A grid to manage the desktop layout.
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    
    const int SPACING = 2;
    const int PADDING = 6;
    /*** const int MARGIN = 2; ***/

    
    /*************************************************************************************
     * The Desktop grid basically contains a linked list to store desktop items.
     * 
     * 
     ************************************************************************************/
    public class Grid {
        
        // Application's Running Mode
        private bool                    _debug_mode = false;
        
        // Desktop Widget
        private Desktop.Window          _desktop;
        private Gdk.Window              _window;
        uint                            _idle_layout = 0;
        
        // Desktop working area, this working area doesn't include docked panels
        private Gdk.Rectangle           _working_area;
        
        // The list of Desktop items
        private List<Desktop.Item>      _grid_items;
        private string                  _items_config_file;
        
        // Geometry of one cell in the grid, total number of cells
        private int                     _cell_width = 50;
        private int                     _cell_height = 50;
        private Gdk.Point               _num_cell;
        
        private Desktop.Item?           _selected_item = null;
        private Fm.CellRendererPixbuf   _icon_renderer; 
        
        // Text drawing...
        private Pango.Layout            _pango_layout;
        uint                            _text_h = 0;
        uint                            _text_w = 0;
        uint                            _pango_text_h = 0;
        uint                            _pango_text_w = 0;
        
        
        public Grid (Desktop.Window desktop, string config_file, bool debug = false) {
            
            _desktop = desktop;
            _items_config_file = config_file;
            _debug_mode = debug;
            
            _grid_items = new List<Desktop.Item> ();
            
            // Setup The Pango Layout.
            _pango_layout = _desktop.create_pango_layout (null);
            _pango_layout.set_alignment (Pango.Alignment.CENTER);
            _pango_layout.set_ellipsize (Pango.EllipsizeMode.END);
            _pango_layout.set_wrap (Pango.WrapMode.WORD_CHAR);
            
            // Setup The Icon Renderer.
            _icon_renderer = new Fm.CellRendererPixbuf ();
            _icon_renderer.set ("follow-state", true, null);
            _icon_renderer.ref_sink ();
            _icon_renderer.set_fixed_size ((int) global_config.big_icon_size, (int) global_config.big_icon_size);
        }
        
        ~Grid () {
        
            if (this._idle_layout != 0)
                Source.remove (this._idle_layout);
        }
        
        
        /***********************************************************************
         * This function is called from the Desktop Widget's Realize handler.
         * 
         * 
         * ********************************************************************/
        public void init_gc (Gdk.Window window) {
            
            _window = window;
        }    
        
        /***********************************************************************
         * Initialize the grid..., this function is called from the
         * size_allocate handler, from the desktop's GtkWindow.
         * 
         * 
         * ********************************************************************/
        public void init_layout (Gdk.Rectangle rect) {
            
            _window = _desktop.get_window ();

            if (_debug_mode == true) {
                
                _working_area.x = 0;
                _working_area.y = 0;
                _working_area.width = rect.width;
                _working_area.height = rect.height;
                
            } else {
                
                XLib.get_working_area (_desktop.get_screen (), out _working_area);
            }
            
            /*****************************************************************************
             * From Gtk+ docs :
             * 
             * The Pango.SCALE constant represents the scale between dimensions used for
             * Pango distances and device units. (The definition of device units is
             * dependent on the output device; it will typically be pixels for a screen,
             * and points for a printer.) Pango.SCALE is currently 1024, but this may be
             * changed in the future. When setting font sizes, device units are always
             * considered to be points (as in "12 point font"), rather than pixels.
             */
            Pango.Context pango_context = _desktop.get_pango_context ();
            Pango.FontMetrics metrics = pango_context.get_metrics (null, null);

            int font_h = (metrics.get_ascent () + metrics.get_descent ()) / Pango.SCALE;
            
            // Set the text rect to a maximum of 72 pixels width and two lines of text.
            this._text_w = 72;
            this._text_h = font_h * 2;
            
            this._pango_text_w = _text_w * Pango.SCALE;
            this._pango_text_h = _text_h * Pango.SCALE;
            
            // Add four pixels to draw a text border.
            _text_h += 4;
            _text_w += 4;
            
            /*** 
                stdout.printf ("font_h:%i, text_h:%i, text_w:%i, pango_text_h:%u, pango_text_w:%u\n",
                               font_h, text_h, text_w, _pango_text_h, _pango_text_w); ***/
            
            _cell_height = (int) global_config.big_icon_size + SPACING + (int) _text_h + PADDING * 2;
            _cell_width = int.max ((int) _text_w, (int) global_config.big_icon_size) + PADDING * 2;
            
            _num_cell.x = (_working_area.width  / _cell_width);
            _num_cell.y = (_working_area.height / _cell_height);
            
            this.queue_layout_items ();
            
            return;
        }
        
        
        /***********************************************************************
         * 
         * 
         * 
         **********************************************************************/
        private void _calc_item_size (Desktop.Item item) {

            string disp_name = item.get_disp_name ();
            
            // Get text size...
            _pango_layout.set_text ("", 0);
            _pango_layout.set_height ((int) _pango_text_h);
            _pango_layout.set_width  ((int) _pango_text_w);
            _pango_layout.set_text (disp_name, -1);

            Pango.Rectangle logical_rect;
            _pango_layout.get_pixel_extents (null, out logical_rect);
            _pango_layout.set_text ("", 0);

            // Set Icon/Text size...
            item.icon_rect.width =  (int) global_config.big_icon_size;
            item.icon_rect.height = (int) global_config.big_icon_size;
            item.text_rect.width =  logical_rect.width + 4;
            item.text_rect.height = logical_rect.height + 4;

            // Origin on the grid...
            item.pixel_pos.x = (item.cell_pos.x  * _cell_width);
            item.pixel_pos.y = (item.cell_pos.y  * _cell_height);
            item.index = item.cell_to_index (_num_cell.y);
            // Icon position...
            item.icon_rect.x = item.pixel_pos.x    + (_cell_width - item.icon_rect.width) / 2;
            item.icon_rect.y = item.pixel_pos.y;
            
            // Text position...
            item.text_rect.x = item.pixel_pos.x    + (_cell_width - logical_rect.width - 4) / 2;
            item.text_rect.y = item.icon_rect.y + item.icon_rect.height + logical_rect.y;
            
            
            /*** is it needed to cache this ? see draw_item () ...
            int text_x = (int) item.pixel_pos.x + (_cell_width - (int) _text_w) / 2 + 2;
            int text_y = (int) item.icon_rect.y + item.icon_rect.height + 2; ***/
            
            
            /*********************************************************
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
        
        
        /***********************************************************************
         * Drawing...
         *
         * 
         **********************************************************************/
        private void _draw_item (Desktop.Item item, Cairo.Context cr, Gdk.Rectangle expose_area) {
            
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

            this._icon_renderer.render (cr,
                                        _desktop,
                                        item.icon_rect,
                                        item.icon_rect,
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
            
            Gtk.StyleContext context = _desktop.get_style_context ();
            //Gtk.StateFlags flags;
            Gdk.RGBA color = {0, 0, 0, 0};
            
            // Selected item
            if (state == Gtk.CellRendererState.SELECTED) {
                
                cr.save ();
                Gdk.cairo_rectangle (cr, item.text_rect);
                
                // DEPRECATED replace with gdk_cairo_set_source_rgba ()
                Gdk.cairo_set_source_color (cr, style.bg[Gtk.StateType.SELECTED]);
                
                cr.clip ();
                cr.paint ();
                cr.restore ();
                
                fg = style.fg[Gtk.StateType.SELECTED];
                
            // Normal item / text shadow
            } else {
                
                cr.save ();
                
                // Clip.
                Gdk.cairo_rectangle (cr, item.text_rect);
                cr.clip ();
                
                //state = _desktop.get_state_flags ();
                //rgba = context.get_color (Gtk.StateFlags.SELECTED);
                
                color.parse ("Black");
                Gdk.cairo_set_source_rgba (cr, color);
                
                // draw the text.
                cr.move_to (text_x + 1, text_y + 1);
                Pango.cairo_show_layout (cr, this._pango_layout);
                
                cr.restore ();
                
                fg = global_config.color_text;
            }
            
            // Real text.
            cr.save ();
            
            // Clip.
            Gdk.cairo_rectangle (cr, item.text_rect);
            cr.clip ();
            
            // Set the correct source color.
            //context = _desktop.get_style_context ();
            //state = _desktop.get_state_flags ();
            //rgba = context.get_color (Gtk.StateFlags.NORMAL);

            color.parse ("White");
            Gdk.cairo_set_source_rgba (cr, color);
            
            // Draw the text.
            cr.move_to (text_x, text_y);
            Pango.cairo_show_layout (cr, this._pango_layout);
            
            cr.restore ();
                
            _pango_layout.set_text ("", 0);

            // Draw a selection rectangle for the selected item
            if (item == _selected_item /*&& _desktop.has_focus*/) {
                
                    context.render_focus (cr,
                                          item.text_rect.x,
                                          item.text_rect.y,
                                          item.text_rect.width,
                                          item.text_rect.height);
            }
        }

        public void draw_items_in_rect (Cairo.Context cr, Gdk.Rectangle expose_area) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                /***
                    stdout.printf ("expose event => grid.draw_items () x = %i, y = %i, w = %i, h = %i\n",
                                   item.text_rect.x,
                                   item.text_rect.y,
                                   item.text_rect.width,
                                   item.text_rect.height); ***/
            
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

                if (intersect != null) {
                    this._draw_item (item, cr, intersect);
                }
            }
        }
        
        public void move_items (int offset_x, int offset_y, bool align_items = true) {
            
//~             stdout.printf ("Desktop.Grid.move_items (): MOVE !!!!!!!\n");

            unowned List<Desktop.Item>? list;
            
            for (list = _grid_items.first (); list != null; list = list.next) {
            
                Desktop.Item item = list.data as Desktop.Item;
                if (item.is_selected) {
                    
                    int new_x = item.pixel_pos.x + offset_x;
                    int new_y = item.pixel_pos.y + offset_y;
                    
                    // nearest cell index...
                    int xx = (new_x + (_cell_width / 2)) / _cell_width;
                    int yy = (new_y + (_cell_height / 2)) / _cell_height;
//~                     stdout.printf ("move_items: move item to %d, %d\n", xx, yy);
                    
                    // cell index to top left pixel
                    int xxx = xx * _cell_width;
                    int yyy = yy * _cell_height;
//~                     stdout.printf ("move_items: move item to %d, %d\n", xxx, yyy);
                    
                    // TODO_axl: to align on the grid we need to invalidate the index pos and move the item...
                    if (align_items) {
                        new_x = xxx;
                        new_y = yyy;
                    }
                    
                    item.cell_pos.x = xx;
                    item.cell_pos.y = yy;
                    item.index = item.cell_to_index (_num_cell.y);
                    
                    item.move (_window, new_x, new_y, true);
                }
            }

            _grid_items.sort ((CompareFunc<Desktop.Item>) _compare_func);
            
            /*
             * TODO_axl: sort the list of items....
             * 
             * _grid_items.sort (_compare_func)
             * 
             * 
             */
        }
        
        public static int _compare_func (Desktop.Item item1, Desktop.Item item2) {
        
            string name1 = item1.get_disp_name ();
            string name2 = item2.get_disp_name ();
            
//~             stdout.printf ("comparing %s and %s\n", name1, name2);
            
            return item1.index - item2.index;
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
            
            /*** stdout.printf ("_layout_items\n"); ***/
            
            // If some items don't have a valid position on the grid, try to find a free position for them...
            
            foreach (Desktop.Item item in _grid_items) {
                
                if (item.cell_to_index (_num_cell.y) < 0) {
                    
                    /*** stdout.printf ("%s INVALID ITEM !!!!\n", item.get_disp_name ()); ***/
                    
                    Gdk.Point pos;
                    
                    if (this.find_free_pos (out pos)) {
                        item.cell_pos.x = pos.x;
                        item.cell_pos.y = pos.y;
                        this._calc_item_size (item);
                    }
                }
            }

            /*** this.queue_draw (); ***/
        }


        /* *****************************************************************************************
         * 
         * 
         * 
         ******************************************************************************************/
        public bool find_free_pos (out Gdk.Point pos) {
            
            int count = -1;
                
            unowned List<Desktop.Item>? list;
            
            for (list = _grid_items.first (); list != null; list = list.next) {
            
                count++;
                
                Desktop.Item current = list.data as Desktop.Item;
                int current_idx = current.cell_to_index (_num_cell.y);

                if (current_idx > count) {
                    
                    Utils.index_to_cell (count, _num_cell.y, out pos);
                    return true;
                
                } else if (list.next == null && current_idx < (_num_cell.x * _num_cell.y)) {
                
                    Utils.index_to_cell (current_idx + 1, _num_cell.y, out pos);
                    return true;
                }

            }

            return false;
        }    
        
        public void insert_item (Desktop.Item new_item) {
            
            // Invalid position ?
            if (new_item.index == -1
                || new_item.cell_pos.x == -1
                || new_item.cell_pos.y == -1) {
                
            // Empty grid ?
            } else if (_grid_items.length () != 0) {
                
                int new_idx = new_item.cell_to_index (_num_cell.y);
                
                unowned List<Desktop.Item>? list;
                
                for (list = _grid_items.first (); list != null; list = list.next) {
                
                    Desktop.Item current = list.data as Desktop.Item;
                    int current_idx = current.cell_to_index (_num_cell.y);
                    
                    // There's already an item here, we need to find a free position...
                    if (current_idx == new_idx) {
                        
                        Gdk.Point pos;
                        if (this.find_free_pos (out pos)) {
                            new_item.index = new_idx;
                            new_item.cell_pos.x = pos.x;
                            new_item.cell_pos.y = pos.y;
                            break;
                        }
                        return;
                    
                    } else if (current_idx > new_idx) {
                        
                        // Most items are inserted here, that may not be very efficient but it works... :-)
                        this._calc_item_size (new_item);
                        _grid_items.insert_before (list, new_item);
                        return;
                    }
                }
            }
            
            this._calc_item_size (new_item);
            _grid_items.append (new_item);
            return;
        }    
        
        
        /*******************************************************************************************
         * *** Items Selection ***
         * 
         * 
         * 
         * 
         ******************************************************************************************/
        public Desktop.Item? hit_test (double x, double y, bool extended = false) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                Gdk.Rectangle rect;
                if (extended) {
                    rect = {item.icon_rect.x,
                            item.icon_rect.y,
                            item.icon_rect.width,
                            item.text_rect.y - item.icon_rect.y + 1}; // why this pixel ?
                } else {                                              // is there a bug in point_in_rect () ?
                    rect = {item.icon_rect.x,
                            item.icon_rect.y,
                            item.icon_rect.width,
                            item.icon_rect.height};
                }
                
                if (Utils.point_in_rect (x, y, rect)
                    || Utils.point_in_rect (x, y, item.text_rect))
                    return item;
            }
            
            return null;
        }

        public void select_items_in_rect (Gdk.Rectangle rect) {
            
            foreach (Desktop.Item item in _grid_items) {
                
                bool selected;
                if (rect.intersect (item.icon_rect, null)
                    || rect.intersect (item.text_rect, null))
                    selected = true;
                else
                    selected = false;

                if (item.is_selected != selected) {
                    item.is_selected = selected;
                    item.invalidate_rect (_window);
                }
            }
        }
        
        public inline Desktop.Item? get_selected_item () {
            
            return _selected_item;
        }

        public void set_selected_item (Desktop.Item? item) {
            
            if (this._selected_item == item)
                return;
                
            if (item != null)
                item.invalidate_rect (_window);
            
            if (_selected_item != null)
                _selected_item.invalidate_rect (_window);
            
            this._selected_item = item;
            
            /*if (this._selected_item == null)
                return;
                
            _selected_item.invalidate_rect (_window);
            this._selected_item = item;*/
            return;
        }

        public void deselect_all () {
            
            foreach (Desktop.Item item in _grid_items) {
                if (item.is_selected == true) {
                    item.is_selected = false;
                    item.invalidate_rect (_window);
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
            
            if (files.is_empty())
                return null;
            
            return files;
        }
        
        
        /*******************************************************************************************
         * Folder Model functions. When files/folders on the desktop have been changed, created,
         * deleted, etc... The model sends a signal and these functions are called. 
         * 
         * 
         ******************************************************************************************/
        public void on_row_inserted (Gtk.TreePath path, Gtk.TreeIter it) {
            
            Gdk.Pixbuf icon;
            Fm.FileInfo fi;
            
            global_model.get (it, Fm.FileColumn.ICON, out icon, Fm.FileColumn.INFO, out fi, -1);
            Desktop.Item item = new Desktop.Item (icon, fi);
            
            Gdk.Point pos;
            
            if (this.find_free_pos (out pos)) {
                item.cell_pos.x = pos.x;
                item.cell_pos.y = pos.y;
                this.insert_item (item);
            
            } else {
                
                // If the grid is full, we should set the item as hidden with (-1, -1) position...
                
                return;
            }
            
            /** Original code in PCManFm calls queue_layout_items (), a redraw also works...
             * this.queue_layout_items (); */
            
            item.invalidate_rect (_window);
        }

        public void on_row_deleted (Gtk.TreePath tp) {
            
            int count = 0;
            
            unowned List<Desktop.Item>? list;
            
            for (list = _grid_items; list != null; list = list.next) {
                
                Desktop.Item item = list.data as Desktop.Item;
                
                unowned Fm.Path path = item.get_fileinfo ().get_path ();
                
                if (path.is_virtual ())
                    continue;
                
                count++;
                
                File file = path.to_gfile ();
                if (file != null && !file.query_exists ()) {
                    
                    if (item == _selected_item) {
                        
                        if (list.next != null) {
                            
                            _selected_item = list.next.data as Desktop.Item;
                        
                        } else if (list.prev != null) {
                            
                            _selected_item = list.prev.data as Desktop.Item;
                            
                        } else {
                            
                            _selected_item = null;
                        }
                    }
                    
                    if (item == _desktop.drop_hilight)
                        _desktop.drop_hilight = null;
                    
                    if (item == _desktop.hover_item)
                        _desktop.hover_item = null;
                    
                    item.invalidate_rect (_window);
                    _grid_items.delete_link (list);
                    
                    /*** queue_layout_items (desktop); ***/
                }
            }
            
            return;    
        }
        
        public void on_row_changed (Gtk.TreePath tp, Gtk.TreeIter it) {
            
            // This callback loads Desktop thumbnails...
            
            
            // Get the pixbuf and FileInfo...
            Gdk.Pixbuf pixbuf;
            Fm.FileInfo fi = null;
            global_model.get (it, Fm.FileColumn.ICON, out pixbuf, Fm.FileColumn.INFO, out fi, -1);
            
            // Find the corresponding Desktop Item and set the thumbnail pixbuf...
            foreach (Desktop.Item item in _grid_items) {
                
                Fm.FileInfo? item_fi = item.get_fileinfo ();
                
                if (item_fi != null && (fi.get_disp_name () == item_fi.get_disp_name ())) {
                
                    //stdout.printf ("found : %s\n", item_fi.get_disp_name ());
                
                    if (item.icon != null)
                        item.icon = null;   // Is it needed to unref the old pixbuf ??? g_object_unref (item.icon);
                        
                    item.icon = pixbuf;
                    
                    item.invalidate_rect (_window);
                }
            }
            
            return;
        }

        
        /*******************************************************************************************
         * Load/Save the position of Items.
         * 
         * 
         * ****************************************************************************************/
        public bool save_item_pos () {
            
            string config = "";
            
            try {
                
                File file = File.new_for_path (_items_config_file);
                
                // For some reasons we need to delete the file if it exists...
                if (file.query_exists ())
                    file.delete ();
                
                DataOutputStream dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
                
                /*********************************************************************************************
                 * We save the full Item path to differentiate real folders on the desktop and virtual ones.
                 * Needed if we have "/home/me/My Documents" and "/home/me/Desktop/My Documents"
                 * 
                 */
                foreach (Desktop.Item item in _grid_items) {
                    config += "[%s]\n".printf (item.get_fileinfo ().get_path ().to_str ());
                    config += "index    = %d\n".printf (item.index);
                    config += "cell_x   = %d\n".printf (item.cell_pos.x);
                    config += "cell_y   = %d\n".printf (item.cell_pos.y);
                    config += "pixel_x  = %d\n".printf (item.pixel_pos.x);
                    config += "pixel_y  = %d\n".printf (item.pixel_pos.y);
                    config += "\n";
                }

                dos.put_string (config);
                
            } catch (Error e) {
            }
            
            return true;
        }
        
        public bool get_saved_position (Desktop.Item item) {
            
            KeyFile kf = new KeyFile();
            try {
                
                kf.load_from_file (_items_config_file, KeyFileFlags.NONE);
                string group = item.get_fileinfo ().get_path ().to_str ();

                if (kf.has_group (group) == false)
                    return false;
                
                item.index      = kf.get_integer (group, "index");;
                item.cell_pos.x = kf.get_integer (group, "cell_x");;
                item.cell_pos.y = kf.get_integer (group, "cell_y");;
            
            } catch (Error e) {
                
                item.index      = -1;
                item.cell_pos.x = -1;
                item.cell_pos.y = -1;
                return false;
            }
            
            return true;
        }
    }
}


