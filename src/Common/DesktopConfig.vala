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
    
    extern void set_background (Gtk.Widget desktop, string wallpaper, Fm.WallpaperMode wallpaper_mode,
                                Gdk.Color color_background);
    
    public class Config : Fm.Config {
        
        
        /*********************************************************************************
         * LibFmCore's parameters... see libfmcore/src/fmvala/fm-config.vala
         * 
         *
         *********************************************************************************
        // Icons Sizes...
        public uint small_icon_size         = 16;       // size of small icons
        public uint big_icon_size           = 36;       // size of big icons
        public uint pane_icon_size          = 16;       // size of side pane icons

        // Trash Can Settings...
        public bool use_trash               = true;     // delete file to trash can
        public bool confirm_del             = true;     // ask before deleting files
        
        // Show Internal Volumes...
        public bool show_internal_volumes   = false;    // show system internal volumes in side pane. (udisks-only)

        // Thumbnails...
        public bool show_thumbnail          = false;    // show thumbnails
        public uint thumbnail_size          = 128;      // size of thumbnail icons
        public uint thumbnail_max           = 2048;     // show thumbnails for files smaller than 'thumb_max' KB
        public bool thumbnail_local         = true;     // show thumbnails for local files only

        // Single Click...
        public bool single_click            = false;    // single click to open file

        // Default Applications...
        public string terminal;
        public string panel;
        public string run;
        public string taskmanager;
        public string archiver;
        
        // SI Prefix...
        public bool si_unit;                            // use SI prefix for file sizes
            
        *********************************************************************************/
        
        public string           wallpaper;
        public Fm.WallpaperMode wallpaper_mode = Fm.WallpaperMode.COLOR;
        public uint             wallpaper_changed = 0;
        
        public Gdk.Color        color_background;
        public Gdk.Color        color_text;
        public Gdk.Color        color_shadow;
        
        // Folder Model Sorting
        public Gtk.SortType     sort_type = Gtk.SortType.ASCENDING;
        
        // Generates a compile error in Vala....
        // public Fm.FileColumn    sort_by = Fm.FileColumn.NAME;
        
        public bool             show_mycomputer = false;
        public bool             show_mydocuments = false;
        public bool             show_trashcan = true;
        public bool             show_mount = false;
        
        public Config () {
            
            wallpaper = "/home/hotnuma/Bureau/Wallpapers/at-the-beach-hd-wallpaper-1440x900.jpg";
            
            // Set a default background color.
            Gdk.Color.parse ("#3C6DA5", out color_background);
            Gdk.Color.parse ("#FFFFFF", out color_text);
            Gdk.Color.parse ("#000000", out color_shadow);
            
            // Overload LibFmcore's Default Config...
            base.show_thumbnail = true;
            base.confirm_delete = false;
        }
        
        public void set_background (Gtk.Widget desktop) {
            
            //string wall = "/home/hotnuma/Bureau/Wallpapers/at-the-beach-hd-wallpaper-1440x900.jpg";
            
            Settings settings;
            
            settings = new Settings ("desktop.noname.settings");
            this.wallpaper = settings.get_string ("wallpaper");
            
            Desktop.set_background (desktop,
                                    wallpaper,
                                    Fm.WallpaperMode.TILE,
                                    global_config.color_background);
        }
    }
}


