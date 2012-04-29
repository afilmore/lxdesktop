/***********************************************************************************************************************
 * misc.c
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: Misc XLib functions.
 * 
 * 
 **********************************************************************************************************************/
#include <gdk/gdk.h>
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <math.h>

#include <fm.h>


/***********************************************************************************************************************
 * Adapted from PCManFM's update_working_area
 * 
 * 
 **********************************************************************************************************************/
void xlib_get_working_area (GdkScreen *screen, GdkRectangle *out_rect) {
    
    GdkWindow   *root = gdk_screen_get_root_window (screen);
    Atom        ret_type;
    int         format;
    gulong      len;
    gulong      after;
    guchar      *prop;
    
    guint32     n_desktops;
    guint32     cur_desktop;
    gulong      *working_area;
    
    // default to screen size
    out_rect->x = 0;
    out_rect->y = 0;
    out_rect->width = gdk_screen_get_width (screen);
    out_rect->height = gdk_screen_get_height (screen);

    // get the number of desktops
    if ((XGetWindowProperty (GDK_WINDOW_XDISPLAY (root),
                             GDK_WINDOW_XID (root),
                             XInternAtom (GDK_WINDOW_XDISPLAY (root),
                                          "_NET_NUMBER_OF_DESKTOPS",
                                          False),
                             0,
                             1,
                             False,
                             XA_CARDINAL,
                             &ret_type,
                             &format,
                             &len,
                             &after,
                             &prop) != Success)
         || prop == NULL)
        return;
    
    n_desktops = *(guint32*) prop;
    XFree (prop);

    // get current desktop
    if ((XGetWindowProperty (GDK_WINDOW_XDISPLAY (root),
                             GDK_WINDOW_XID (root),
                             XInternAtom (GDK_WINDOW_XDISPLAY (root),
                                          "_NET_CURRENT_DESKTOP",
                                          False),
                             0,
                             1,
                             False,
                             XA_CARDINAL,
                             &ret_type,
                             &format,
                             &len,
                             &after,
                             &prop) != Success)
         || prop == NULL)
        return;
            
    cur_desktop = *(guint32*) prop;
    XFree (prop);

    // get working area
    if ((XGetWindowProperty (GDK_WINDOW_XDISPLAY (root),
                             GDK_WINDOW_XID (root),
                             XInternAtom (GDK_WINDOW_XDISPLAY (root),
                                          "_NET_WORKAREA",
                                          False),
                             0,
                             4 * 32,
                             False,
                             AnyPropertyType,
                             &ret_type,
                             &format,
                             &len,
                             &after,
                             &prop) != Success)
         || prop == NULL)
        return;
        
    if (ret_type == None || format == 0 || len != n_desktops*4) {
        if (prop)
            XFree (prop);
        return;
    }
    
    working_area = ((gulong*) prop) + cur_desktop * 4;

    // set the working area for the current desktop
    out_rect->x =       (gint) working_area[0];
    out_rect->y =       (gint) working_area[1];
    out_rect->width =   (gint) working_area[2];
    out_rect->height =  (gint) working_area[3];

    XFree (prop);
    return;
}


/***********************************************************************************************************************
 * This function is taken from xfdesktop...
 *  
 * 
 **********************************************************************************************************************/
void xlib_forward_event_to_rootwin (GdkScreen *gscreen, GdkEvent *event) {
    
    XButtonEvent xev;
    XButtonEvent xev2;
    
    Display *dpy = GDK_DISPLAY_XDISPLAY (gdk_screen_get_display (gscreen));

    if (event->type == GDK_BUTTON_PRESS || event->type == GDK_BUTTON_RELEASE) {
        
        if (event->type == GDK_BUTTON_PRESS) {
            
            xev.type = ButtonPress;
            
            /*********************************************************************
             * Rox has an option to disable the next instruction. it is called
             * "blackbox_hack". Does anyone know why exactly it is needed ?
             * 
             */
            XUngrabPointer (dpy, event->button.time);
            
        } else {
            xev.type = ButtonRelease;
        }

        xev.button =    event->button.button;
        xev.x =         event->button.x;                // Needed for icewm
        xev.y =         event->button.y;
        xev.x_root =    event->button.x_root;
        xev.y_root =    event->button.y_root;
        xev.state =     event->button.state;

        xev2.type = 0;
        
    } else if  (event->type == GDK_SCROLL) {
        
        xev.type =      ButtonPress;
        xev.button =    event->scroll.direction + 4;
        xev.x =         event->scroll.x;                // Needed for icewm
        xev.y =         event->scroll.y;
        xev.x_root =    event->scroll.x_root;
        xev.y_root =    event->scroll.y_root;
        xev.state =     event->scroll.state;

        xev2.type =     ButtonRelease;
        xev2.button =   xev.button;
        
    } else {
        
        return;
    }
    
    xev.window =        gdk_x11_window_get_xid (gdk_screen_get_root_window (gscreen));
    xev.root =          xev.window;
    xev.subwindow =     None;
    xev.time =          event->button.time;
    xev.same_screen =   True;

    XSendEvent (dpy,
                xev.window,
                False,
                ButtonPressMask | ButtonReleaseMask,
                (XEvent*) &xev);
                
    if (xev2.type == 0)
        return ;

    // send button release for scroll event
    xev2.window =       xev.window;
    xev2.root =         xev.root;
    xev2.subwindow =    xev.subwindow;
    xev2.time =         xev.time;
    xev2.x =            xev.x;
    xev2.y =            xev.y;
    xev2.x_root =       xev.x_root;
    xev2.y_root =       xev.y_root;
    xev2.state =        xev.state;
    xev2.same_screen =  xev.same_screen;

    XSendEvent (dpy,
                xev2.window,
                False,
                ButtonPressMask | ButtonReleaseMask,
                (XEvent*) &xev2);
    
    return;
}

#if !ENABLE_GTK3
void xlib_set_pixmap (GtkWidget *widget, GdkPixmap *pixmap) {
    
    GdkWindow *window = gtk_widget_get_window (widget);
    GdkWindow *root = gdk_screen_get_root_window (gtk_widget_get_screen (widget));
    
    Pixmap pixmap_id;
    pixmap_id = GDK_DRAWABLE_XID (pixmap);
    
    XChangeProperty (GDK_WINDOW_XDISPLAY (root),
                     GDK_WINDOW_XID (root),
                     gdk_x11_get_xatom_by_name ("_XROOTPMAP_ID"), // XA_XROOTMAP_ID
                     XA_PIXMAP,
                     32,
                     PropModeReplace,
                     (guchar*) &pixmap_id, 1);

    // set root map here
    Display *xdisplay = GDK_WINDOW_XDISPLAY (root);
    Window xroot = GDK_WINDOW_XID (root);

    XGrabServer (xdisplay);

    Pixmap xpixmap = 0;
    if (pixmap) {
        
        xpixmap = GDK_WINDOW_XWINDOW (pixmap);

        XChangeProperty (xdisplay,
                         xroot,
                         gdk_x11_get_xatom_by_name ("_XROOTPMAP_ID"),
                         XA_PIXMAP,
                         32,
                         PropModeReplace,
                         (guchar*) &xpixmap, 1);

        XSetWindowBackgroundPixmap (xdisplay, xroot, xpixmap);
    
    } else {
        
        // how to handle this correctly ???
    }
    
    XClearWindow (xdisplay, xroot);

    XUngrabServer (xdisplay);
    XFlush (xdisplay);

    if (pixmap) g_object_unref (pixmap);

    gdk_window_clear (root);
    gdk_window_clear (window);
    gdk_window_invalidate_rect (window, NULL, TRUE);
    
    return;
}
#endif

