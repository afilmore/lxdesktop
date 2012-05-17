/***********************************************************************************************************************
 * background.c
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: 
 * 
 * 
 **********************************************************************************************************************/
#include <gdk/gdk.h>
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>

#include <cairo.h>
#include <cairo-xlib.h>

#include <math.h>

#include <fm.h>


/*****************************************************************************************
 * 
 * 
 * 
 ****************************************************************************************/
void desktop_set_background (GtkWidget *desktop, gchar *wallpaper, FmWallpaperMode wallpaper_mode,
                             GdkColor *color_background)
{
    
    GdkPixbuf *pixbuf;

    
    GdkWindow *root = gdk_screen_get_root_window (gtk_widget_get_screen (desktop));
    GdkWindow *window = gtk_widget_get_window (desktop);

    if (wallpaper_mode == FM_WP_COLOR
       || !wallpaper
       || !*wallpaper
       || !(pixbuf = gdk_pixbuf_new_from_file (wallpaper, NULL)))
    {
        //GdkColor bg = color_background;

        //gdk_rgb_find_color (gdk_drawable_get_colormap (window), &bg);
        
        //gdk_window_set_back_pixmap (window, NULL, FALSE);
        gdk_window_set_background (window, color_background);
        
        //gdk_window_set_back_pixmap (root, NULL, FALSE);
        gdk_window_set_background (root, color_background);
        
        //gdk_window_clear (root);
        //gdk_window_clear (window);
        
        gdk_window_invalidate_rect (window, NULL, TRUE);
        
        return;
    }

//    #if 0
    
    int src_w = gdk_pixbuf_get_width (pixbuf);
    int src_h = gdk_pixbuf_get_height (pixbuf);
    
    
    cairo_surface_t *surface;
    int dest_w;
    int dest_h;
    
    if (wallpaper_mode == FM_WP_TILE)
    {
        dest_w = src_w;
        dest_h = src_h;
        
        //pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
        surface = gdk_window_create_similar_surface (window, CAIRO_CONTENT_COLOR, dest_w, dest_h);
    
    }
    else
    {
        GdkScreen *screen = gtk_widget_get_screen (desktop);
        dest_w = gdk_screen_get_width (screen);
        dest_h = gdk_screen_get_height (screen);
        
        //pixmap = gdk_pixmap_new (window, dest_w, dest_h, -1);
        surface = gdk_window_create_similar_surface (window, CAIRO_CONTENT_COLOR, dest_w, dest_h);
    }

    //~ if (gdk_pixbuf_get_has_alpha (pixbuf)
        //~ || wallpaper_mode == FM_WP_CENTER
        //~ || wallpaper_mode == FM_WP_FIT)
    //~ {
        //~ gdk_gc_set_rgb_fg_color (desktop->gc, &color_background);
        //~ gdk_draw_rectangle (pixmap, desktop->gc, TRUE, 0, 0, dest_w, dest_h);
    //~ }

//    GdkPixbuf *scaled;

    cairo_t *cr;

    switch (wallpaper_mode)
    {
        case FM_WP_COLOR:
        break;
        
        case FM_WP_TILE:
        
            //gdk_draw_pixbuf (pixmap, desktop->gc, pixbuf, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
            
            cr = cairo_create (surface);
            gdk_cairo_set_source_pixbuf (cr, pixbuf, 0, 0);
            cairo_paint (cr);
            cairo_destroy (cr);
            
        break;
        
        case FM_WP_STRETCH:
            //~ if (dest_w == src_w && dest_h == src_h)
                //~ scaled = (GdkPixbuf*) g_object_ref (pixbuf);
            //~ else
                //~ scaled = gdk_pixbuf_scale_simple (pixbuf, dest_w, dest_h, GDK_INTERP_BILINEAR);
            //~ 
            //~ gdk_draw_pixbuf (pixmap, desktop->gc, scaled, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
            //~ 
            //~ g_object_unref (scaled);
        break;
        
        case FM_WP_FIT:
            
            //~ if (dest_w != src_w || dest_h != src_h)
            //~ {
                //~ gdouble w_ratio = (float) dest_w / src_w;
                //~ gdouble h_ratio = (float) dest_h / src_h;
                //~ gdouble ratio = MIN (w_ratio, h_ratio);
                //~ 
                //~ if (ratio != 1.0)
                //~ {
                    //~ src_w *= ratio;
                    //~ src_h *= ratio;
                    //~ 
                    //~ scaled = gdk_pixbuf_scale_simple (pixbuf, src_w, src_h, GDK_INTERP_BILINEAR);
                    //~ 
                    //~ g_object_unref (pixbuf);
                    //~ pixbuf = scaled;
                //~ }
            //~ }
        
        case FM_WP_CENTER:
        {
            //~ int x;
            //~ int y;
            //~ x = (dest_w - src_w) / 2;
            //~ y = (dest_h - src_h) / 2;
            //~ 
            //~ gdk_draw_pixbuf (pixmap, desktop->gc, pixbuf, 0, 0, x, y, -1, -1, GDK_RGB_DITHER_NORMAL, 0, 0);
        }
        break;
    }
    
    
    Display *xdisplay;
    Pixmap xpixmap = 0;
    Window xroot;
    
    cairo_pattern_t *pattern = cairo_pattern_create_for_surface (surface);
    
    //gdk_window_set_back_pixmap (root, pixmap, FALSE);
	gdk_window_set_background_pattern (root, pattern);

    //gdk_window_set_back_pixmap (window, NULL, TRUE);
	gdk_window_set_background_pattern (window, pattern);

    cairo_pattern_destroy (pattern);
    
    Pixmap pixmap_id = cairo_xlib_surface_get_drawable (surface);
    
    XChangeProperty (GDK_WINDOW_XDISPLAY (root),
                     GDK_WINDOW_XID (root),
                     gdk_x11_get_xatom_by_name ("_XROOTPMAP_ID"),   //XA_XROOTMAP_ID,
                     XA_PIXMAP,
                     32,
                     PropModeReplace, 
                     (guchar*) &pixmap_id,
                     1);

    // Set root map here...
    xdisplay = GDK_WINDOW_XDISPLAY (root);
    xroot = GDK_WINDOW_XID (root);

    XGrabServer (xdisplay);

    if (surface)
    {
        xpixmap = cairo_xlib_surface_get_drawable (surface);

        XChangeProperty (xdisplay,
                         xroot,
                         gdk_x11_get_xatom_by_name ("_XROOTPMAP_ID"),
                         XA_PIXMAP,
                         32,
                         PropModeReplace,
                         (guchar *) &xpixmap,
                         1);

        XSetWindowBackgroundPixmap (xdisplay, xroot, xpixmap);
    }
    else
    {
        // Anyone knows how to handle this correctly ?
    }
    
    XClearWindow (xdisplay, xroot);

    XUngrabServer (xdisplay);
    XFlush (xdisplay);

    cairo_surface_destroy (surface);
    
    if (pixbuf)
        g_object_unref (pixbuf);

//    gdk_window_clear (root);
//    gdk_window_clear (window);
    
    gdk_window_invalidate_rect (window, NULL, TRUE);
//    #endif
}



