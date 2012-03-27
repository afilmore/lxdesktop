/***********************************************************************************************************************
 * DesktopConfig.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental rewrite of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    
    public class Config {
        
        public string           app_filemanager = "pcmanfm";
        
        // Desktop Config. (see LibFm/src/base/fm-config.h)
        public Fm.WallpaperMode wallpaper_mode = Fm.WallpaperMode.COLOR;
        public string           wallpaper;
        public uint             wallpaper_changed = 0;
        public int              big_icon_size = 36;
        
        public Gdk.Color        color_background;
        public Gdk.Color        color_text;
        public Gdk.Color        color_shadow;
        
        // Folder Model Sorting
        public Gtk.SortType     sort_type = Gtk.SortType.ASCENDING;
        
        //public Fm.FileColumn    sort_by = Fm.FileColumn.NAME; // generates a compile error in Vala....
        
        /***************************************************************************************************************
         * 
         * 
         * 
        // font colors...
        Gdk.Color desktop_fg;
        Gdk.Color desktop_shadow;
        */
        
        public bool             single_click;
        /*
        private bool            use_trash;
        private bool            confirm_del;
        private uint            big_icon_size;
        private uint            small_icon_size;
        private uint            pane_icon_size;
        private uint            thumbnail_size;
        private bool            show_thumbnail;
        private bool            thumbnail_local;
        private uint            thumbnail_max;
        private bool            show_internal_volumes;
        private string          terminal;
        private bool            si_unit;
        private string          archiver;
        */
        
        public Config () {
            
            // set a default background color.
            Gdk.Color.parse ("#3C6DA5", out color_background); // Win2K's blue desktop :P
            Gdk.Color.parse ("#FFFFFF", out color_text);
            Gdk.Color.parse ("#000000", out color_shadow);
        }
    }
}


