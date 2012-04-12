/***********************************************************************************************************************
 * DesktopConfig.vala
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
namespace Desktop {
    
    public class Config : Fm.Config {
        
        
        /***************************************************************************************************************
         * LibFmCore's parameters... see libfmcore/src/fmvala/fm-config.h
         * 
         * 
            single_click;
            use_trash;
            confirm_del;
            small_icon_size;
            pane_icon_size;
            thumbnail_size;
            thumbnail_local;
            thumbnail_max;
            show_internal_volumes;
            terminal;
            si_unit;
            archiver;
            
        */
        
        public string           app_filemanager = "pcmanfm";
        
        public Fm.WallpaperMode wallpaper_mode = Fm.WallpaperMode.COLOR;
        public string           wallpaper;
        public uint             wallpaper_changed = 0;
        
        public Gdk.Color        color_background;
        public Gdk.Color        color_text;
        public Gdk.Color        color_shadow;
        
        // Folder Model Sorting
        public Gtk.SortType     sort_type = Gtk.SortType.ASCENDING;
        
        public bool             show_mycomputer = false;
        public bool             show_mydocuments = false;
        public bool             show_trashcan = true;
        public bool             show_mount = false;
        
        /*
        char*                 desktop_font;
        private PangoFontDescription* font_desc = null;
            if (desktop_font)
                font_desc = pango_font_description_from_string (desktop_font);
            
        wallpaper_changed = g_signal_connect (global_config,
                                              "changed::wallpaper",
                                              G_CALLBACK(on_wallpaper_changed),
                                              NULL);
        desktop_text_changed = g_signal_connect (global_config,
                                                 "changed::desktop_text",
                                                 G_CALLBACK(on_desktop_text_changed),
                                                 NULL);
        desktop_font_changed = g_signal_connect (global_config,
                                                 "changed::desktop_font",
                                                 G_CALLBACK(on_desktop_font_changed),
                                                 NULL);
        big_icon_size_changed = g_signal_connect (global_config,
                                                  "changed::big_icon_size",
                                                  G_CALLBACK(on_big_icon_size_changed),
                                                  NULL);
                                                  
        global_config.wallpaper_changed.disconnect ();
        global_config.big_icon_size_changed.disconnect ();
        global_config.desktop_text_changed.disconnect ();
        global_config.desktop_font_changed.disconnect ();
        private uint big_icon_size_changed = 0;
        private uint desktop_text_changed = 0;
        private uint desktop_font_changed = 0;
        */
        
        //public Fm.FileColumn    sort_by = Fm.FileColumn.NAME; // generates a compile error in Vala....
        
        
        /***************************************************************************************************************
         * 
         * 
         * 
        // font colors...
        Gdk.Color desktop_fg;
        Gdk.Color desktop_shadow;
        */
        
        public Config () {
            
            // set a default background color.
            Gdk.Color.parse ("#3C6DA5", out color_background); // Win2K's blue desktop :P
            Gdk.Color.parse ("#FFFFFF", out color_text);
            Gdk.Color.parse ("#000000", out color_shadow);
            
            // overload libfm default config (see LibFm/src/base/fm-config.h)
            big_icon_size = 36;
            show_thumbnail = false;
            
        }
        
        
        /***************************************************************************************************************
         * Desktop Configuration handlers.
         *
         **************************************************************************************************************/
        private void _on_wallpaper_changed () {
            
            /***********************************************************************************************************
             * The user changed the wallpaper in the desktop configuration dialog.
             * 
             * 
            
            for (int i=0; i < _n_screens; ++i)
                desktops[i].update_background ();
            
            */
        }
        
        private void _on_big_icon_size_changed () {
            
            /***********************************************************************************************************
             * The user changed the icon size in the desktop configuration dialog.
             * 
             * 
            
            global_model.set_icon_size (global_config.big_icon_size);
            
            this._reload_icons();
            */
            
            
        }

        private void _on_desktop_text_changed () {

            /***********************************************************************************************************
             * Handle text changes...
             * FIXME: we only need to redraw text lables
            
            for (int i=0; i < _n_screens; ++i)
                desktops[i].queue_draw ();
            
            */
        }
        
        private void _on_desktop_font_changed () {
            
            /***********************************************************************************************************
             * Handle font change...
             * 
             * 
            font_desc = null;
            // FIXME: this is a little bit dirty
            if (font_desc)
                pango_font_description_free (font_desc);

            if (desktop_font) {
                
                font_desc = new Pango.FontDescription.from_string (desktop_font);
                
                if (font_desc) {
                    int i;
                    for (i=0; i < _n_screens; ++i) {
                        FmDesktop* desktop = desktops[i];
                        
                        Pango.Context pc = this.get_pango_context ();
                        pc.set_font_description (font_desc);
                        this.grid._pango_layout.context_changed ();
                        
                        this.queue_resize ();
                        // layout_items(desktop);
                        // this.queue_draw(desktops[i]);
                    }
                }
                
            } else {
                font_desc = null;
            }
            */
            
            return;
        }
    }
}


