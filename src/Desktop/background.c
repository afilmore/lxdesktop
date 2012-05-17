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
#include <math.h>

#include <fm.h>


/*****************************************************************************************
 * 
 * 
 * 
 ****************************************************************************************/
#if 0
void desktop_set_background ()
{
    GtkWidget* widget = (GtkWidget*)desktop;
    GdkPixbuf* pix, *scaled;
    GdkPixmap* pixmap;
    Pixmap pixmap_id;
    int src_w, src_h;
    int dest_w, dest_h;
    GdkWindow* root = gdk_screen_get_root_window(gtk_widget_get_screen(widget));
    GdkWindow *window = gtk_widget_get_window(widget);

    Display* xdisplay;
    Pixmap xpixmap = 0;
    Window xroot;

    if(app_config->wallpaper_mode == FM_WP_COLOR
       || !app_config->wallpaper
       || !*app_config->wallpaper
       || ! (pix = gdk_pixbuf_new_from_file(app_config->wallpaper, NULL)) ) /* solid color only */
    {
        GdkColor bg = app_config->desktop_bg;

        gdk_rgb_find_color(gdk_drawable_get_colormap(window), &bg);
        gdk_window_set_back_pixmap(window, NULL, FALSE);
        gdk_window_set_background(window, &bg);
        gdk_window_set_back_pixmap(root, NULL, FALSE);
        gdk_window_set_background(root, &bg);
        gdk_window_clear(root);
        gdk_window_clear(window);
        gdk_window_invalidate_rect(window, NULL, TRUE);
        return;
    }

    src_w = gdk_pixbuf_get_width(pix);
    src_h = gdk_pixbuf_get_height(pix);
    if(app_config->wallpaper_mode == FM_WP_TILE)
    {
        dest_w = src_w;
        dest_h = src_h;
        pixmap = gdk_pixmap_new(window, dest_w, dest_h, -1);
    }
    else
    {
        GdkScreen* screen = gtk_widget_get_screen(widget);
        dest_w = gdk_screen_get_width(screen);
        dest_h = gdk_screen_get_height(screen);
        pixmap = gdk_pixmap_new(window, dest_w, dest_h, -1);
    }

    if(gdk_pixbuf_get_has_alpha(pix)
        || app_config->wallpaper_mode == FM_WP_CENTER
        || app_config->wallpaper_mode == FM_WP_FIT)
    {
        gdk_gc_set_rgb_fg_color(desktop->gc, &app_config->desktop_bg);
        gdk_draw_rectangle(pixmap, desktop->gc, TRUE, 0, 0, dest_w, dest_h);
    }

    switch(app_config->wallpaper_mode)
    {
        case FM_WP_TILE:
            gdk_draw_pixbuf(pixmap, desktop->gc, pix, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
            break;
        case FM_WP_STRETCH:
            if(dest_w == src_w && dest_h == src_h)
                scaled = (GdkPixbuf*)g_object_ref(pix);
            else
                scaled = gdk_pixbuf_scale_simple(pix, dest_w, dest_h, GDK_INTERP_BILINEAR);
            gdk_draw_pixbuf(pixmap, desktop->gc, scaled, 0, 0, 0, 0, dest_w, dest_h, GDK_RGB_DITHER_NORMAL, 0, 0);
            g_object_unref(scaled);
            break;
        case FM_WP_FIT:
            if(dest_w != src_w || dest_h != src_h)
            {
                gdouble w_ratio = (float)dest_w / src_w;
                gdouble h_ratio = (float)dest_h / src_h;
                gdouble ratio = MIN(w_ratio, h_ratio);
                if(ratio != 1.0)
                {
                    src_w *= ratio;
                    src_h *= ratio;
                    scaled = gdk_pixbuf_scale_simple(pix, src_w, src_h, GDK_INTERP_BILINEAR);
                    g_object_unref(pix);
                    pix = scaled;
                }
            }
            /* continue to execute code in case FM_WP_CENTER */
        case FM_WP_CENTER:
            {
                int x, y;
                x = (dest_w - src_w)/2;
                y = (dest_h - src_h)/2;
                gdk_draw_pixbuf(pixmap, desktop->gc, pix, 0, 0, x, y, -1, -1, GDK_RGB_DITHER_NORMAL, 0, 0);
            }
            break;
    }
    gdk_window_set_back_pixmap(root, pixmap, FALSE);
    gdk_window_set_back_pixmap(window, NULL, TRUE);

    pixmap_id = GDK_DRAWABLE_XID(pixmap);
    XChangeProperty(GDK_WINDOW_XDISPLAY(root), GDK_WINDOW_XID(root),
                    XA_XROOTMAP_ID, XA_PIXMAP, 32, PropModeReplace, (guchar*)&pixmap_id, 1);

    /* set root map here */
    xdisplay = GDK_WINDOW_XDISPLAY(root);
    xroot = GDK_WINDOW_XID(root);

    XGrabServer (xdisplay);

    if( pixmap )
    {
        xpixmap = GDK_WINDOW_XWINDOW(pixmap);

        XChangeProperty( xdisplay,
                    xroot,
                    gdk_x11_get_xatom_by_name("_XROOTPMAP_ID"), XA_PIXMAP,
                    32, PropModeReplace,
                    (guchar *) &xpixmap, 1);

        XSetWindowBackgroundPixmap( xdisplay, xroot, xpixmap );
    }
    else
    {
        /* FIXME: Anyone knows how to handle this correctly??? */
    }
    XClearWindow( xdisplay, xroot );

    XUngrabServer( xdisplay );
    XFlush( xdisplay );

    g_object_unref(pixmap);
    if(pix)
        g_object_unref(pix);

    gdk_window_clear(root);
    gdk_window_clear(window);
    gdk_window_invalidate_rect(window, NULL, TRUE);
}

#endif

