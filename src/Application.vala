/***********************************************************************************************************************
 * Application.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: The Main Application Class and program's entry point. The application creates a FolderModel and sets
 * the desktop path to that model. The Model manages files that exists in the desktop folder, then a Desktop window
 * is created for every screen. The desktop window is a Gtk.Window, it contains a Grid that manages desktop items.
 * The Grid is not a widget, just an object that contains a list of items and manages the layout and drawing.
 * Each Desktop Item contains a FileInfo object representing the real file/folder on the system and manages the item
 * layout, the size and position of the Item's icon and text.
 * 
 * 
 * 
 **********************************************************************************************************************/
namespace XLib {
    /*** These are XLib specifics written in C (misc.c) ***/
    extern void set_wallpaper (Gdk.Pixbuf pix, Fm.WallpaperMode wallpaper_mode);
    extern void get_working_area (Gdk.Screen screen, out Gdk.Rectangle rect);
    extern void forward_event_to_rootwin (Gdk.Screen screen, Gdk.Event event);
}

namespace Desktop {

    Application     global_app;
    Desktop.Config? global_config;
    Fm.FolderModel? global_model = null;    
    
    bool            global_debug_mode;
        
    public const OptionEntry[] opt_entries = {
        
        {"debug",   'd',    0,  OptionArg.NONE, ref global_debug_mode,  N_("Run In Debug Mode"), null},
        {null}
    };

    public class Application {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        int                         _n_screens = 0;
        private Desktop.Window[]    _desktops;
        
        /*********************************************************************
         * See where to use all these variables when needed...
         * 
         *********************************************************************
           private uint icon_theme_changed = 0;
           typedef bool (*DeleteEvtHandler) (GtkWidget*, GdkEvent*);
        *********************************************************************/

        public Application () {
        }
        
        public bool run (bool debug = false) {
            
            if (global_model != null)
                return false;
                
            _debug_mode = debug;
            
            if (_wingroup == null)
                _wingroup = new Gtk.WindowGroup ();
            
            // Create a global Folder Model for the user's Desktop Directory.
            string desktop_path = Environment.get_user_special_dir (UserDirectory.DESKTOP);
            DirUtils.create_with_parents (desktop_path, 0700);
            
            Fm.Path? path = Fm.Path.get_desktop();
            Fm.Folder? folder = Fm.Folder.get (path);
            if (folder == null)
                return false;
                
            global_model = new Fm.FolderModel (folder, false);
            if (global_model == null)
                return false;
                
            // Desktop windows will be created when the model is loaded in the "loaded" callback.
            global_model.set_icon_size (global_config.big_icon_size);
            global_model.loaded.connect (_on_model_loaded);
            global_model.set_sort_column_id (Fm.FileColumn.NAME, global_config.sort_type);
            
            /*
                icon_theme_changed = g_signal_connect (gtk_icon_theme_get_default(),
                                                       "changed",
                                                       on_icon_theme_changed,
                                                       null);
            */

            Gtk.main ();
            
            /*
                Gtk.IconTheme.get_default ().disconnect (icon_theme_changed);
                desktop_popup.destroy ();
            */
            
            return true;
        }
        
        
        private void _on_model_loaded () {
            
            // Create an array of desktop widgets and create a widget for every screen...
            _n_screens = Gdk.Display.get_default ().get_n_screens ();
            _desktops = new Desktop.Window [_n_screens];
            
            for (int i = 0; i < _n_screens; i++) {
                
                Desktop.Window desktop = new Desktop.Window ();

                string config_file = "%s/.items-%d.conf".printf (
                                     Environment.get_user_special_dir (UserDirectory.DESKTOP),
                                     i);                

                desktop.create (config_file, _debug_mode);
            
                _desktops [i] = desktop;
                _wingroup.add_window (desktop);
                
                /*********************************************************************
                 * Create special items on the desktop, this should be configurable,
                 * it should be possible to show/hide My Computer, My Documents and
                 * The Trash Can from dconf settings.
                 * 
                 * Some modifications have been done to LibFMCore's FmPath and
                 * FmFileInfo to create easily and hopefully in a safe way these
                 * items.
                 * 
                 ********************************************************************/
                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
                
                Desktop.Item item;
                string icon_name;
                Gdk.Pixbuf pixbuf;
                Fm.FileInfo? fi;
                
                /* See how to handle these special icons...
                 * "computer"
                 * "folder-documents"
                 * "user-trash"
                 * "user-trash-full"
                 * "folder-download"
                 * "folder-music"
                 * "folder-pictures"
                 * "folder-publicshares"
                 * "folder-remote"
                 * "folder-templates"
                 * "folder-videos"
                 * 
                 */
                
                /*********************************************************************
                 * My Computer
                 * 
                 ********************************************************************/
                icon_name = "computer";
                pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                
                fi = new Fm.FileInfo.computer ();
                item = new Desktop.Item (pixbuf, fi);
                desktop.get_grid ().get_saved_position (item);
                desktop.get_grid ().insert_item (item);
                
                /*********************************************************************
                 * From Glib Reference Manual :
                 * 
                 * These are logical ids for special directories which are defined
                 * depending on the platform used. You should use
                 * g_get_user_special_dir() to retrieve the full path associated to
                 * the logical id.
                 * 
                 * The GUserDirectory enumeration can be extended at later date.
                 * Not every platform has a directory for every logical id in this
                 * enumeration.
                 *  
                 * Current User's Directories (GLib 2.32)
                 * 
                 *  The user's Desktop directory:       G_USER_DIRECTORY_DESKTOP
                 *  The user's Documents directory:     G_USER_DIRECTORY_DOCUMENTS
                 *  The user's Downloads directory:     G_USER_DIRECTORY_DOWNLOAD
                 *  The user's Music directory:         G_USER_DIRECTORY_MUSIC
                 *  The user's Pictures directory:      G_USER_DIRECTORY_PICTURES
                 *  The user's shared directory:        G_USER_DIRECTORY_PUBLIC_SHARE
                 *  The user's Templates directory:     G_USER_DIRECTORY_TEMPLATES
                 *  The user's Movies directory:        G_USER_DIRECTORY_VIDEOS
                 *  The number of enum values:          G_USER_N_DIRECTORIES
                 * 
                 */
                
                /*********************************************************************
                 * My Documents
                 * 
                 ********************************************************************/
                icon_name = "folder-documents";
                pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.DOCUMENTS);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                
                /*********************************************************************
                 * My Music
                 * 
                 ********************************************************************/
                icon_name = "folder-music";
                pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                                               
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.MUSIC);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                
                /*********************************************************************
                 * Trash Can
                 * 
                 ********************************************************************/
                icon_name = "user-trash";
                pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                                               
                fi = new Fm.FileInfo.trash_can ();
                item = new Desktop.Item (pixbuf, fi);
                desktop.get_grid ().get_saved_position (item);
                desktop.get_grid ().insert_item (item);
                
                Gtk.TreeIter    it;
                Gdk.Pixbuf      icon;

                // Load Desktop files/folders from the Global Model, add Desktop Items to the Grid.
                if (!global_model.get_iter_first (out it))
                    continue;
                    
                do {
                    global_model.get (it, Fm.FileColumn.ICON, out icon, Fm.FileColumn.INFO, out fi, -1);
                    
                    item = new Desktop.Item (icon, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                    
                } while (global_model.iter_next (ref it) == true);
                
            }
        }

        
        /***************************************************************************************************************
         * Application's entry point.
         *
         * 
         * 
         **************************************************************************************************************/
        private static int main (string[] args) {
            
            try {
                Gtk.init_with_args (ref args, "", opt_entries, VConfig.GETTEXT_PACKAGE);
            } catch {
            }
            
            // Create the Desktop configuration, this object derivates of Fm.Config.
            global_config = new Desktop.Config ();
            
            global_app = new Application ();
            
            GLib.Application unique = new GLib.Application ("org.lxdesktop", 0);
            unique.register ();
            
            if (!unique.get_is_remote () || global_debug_mode) {
                
                Fm.init (global_config);
                /*** fm_volume_manager_init (); ***/

                global_app.run (global_debug_mode);
            
                /*** fm_volume_manager_finalize (); ***/
                Fm.finalize ();
            
            } else {
                
                stdout.printf ("already running !!!!\n");
            }
            
            return 0;
        }
    }
}


