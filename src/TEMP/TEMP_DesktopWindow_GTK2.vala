

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


