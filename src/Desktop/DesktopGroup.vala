/***********************************************************************************************************************
 * 
 *      DesktopGroup.vala
 * 
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License Version 2.
 *      http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 *      An experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 *      Purpose: The Desktop Window Group.
 * 
 *      The application creates a FolderModel and sets the desktop path to that model.
 *      The Model manages files that exists in the desktop folder, then a Desktop window is created for
 *      every screen.
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {

    
    // A Global Model to handle Files/Folder on the desktop...
    Fm.FolderModel?     global_model = null;    
    
    
    // TODO_axl: Try to derivate a window group instead...
    public class Group {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        int                         _n_screens = 0;
        private Desktop.Window[]    _desktops;
        

        public Group (bool debug = false) {
            
            _debug_mode = debug;
        }
        
        public bool create_desktop () {
            
            if (global_model != null)
                return false;
                
            if (_wingroup == null)
                _wingroup = new Gtk.WindowGroup ();
            
            // Create a global Folder Model for the user's Desktop Directory.
            string desktop_path = Environment.get_user_special_dir (UserDirectory.DESKTOP);
            DirUtils.create_with_parents (desktop_path, 0700);
            
            Fm.Path? path = Fm.Path.get_desktop();
            if (path == null)
                return false;
            
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
            
            return true;
        }
        
        private void _on_model_loaded () {
            
            // Create an array of desktop widgets and create a widget for every screen...
            _n_screens = Gdk.Display.get_default ().get_n_screens ();
            _desktops = new Desktop.Window [_n_screens];
            
            int i;
            for (i = 0; i < _n_screens; i++) {
                
                Desktop.Window desktop = new Desktop.Window ();

                string config_file;
                if (_debug_mode)
                    config_file = "%s/.items-%d-debug.conf".printf (
                                  Environment.get_user_special_dir (UserDirectory.DESKTOP),
                                  i);                
                else
                    config_file = "%s/.items-%d.conf".printf (
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
                Gdk.Pixbuf? pixbuf = null;
                Fm.FileInfo? fi;
                
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
                 * My Music
                 * 
                 ********************************************************************/
                icon_name = "folder-music";
                try {
                    pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                } catch (Error e) {
                }
                                               
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.MUSIC);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                
                /*********************************************************************
                 * My Pictures...
                 * 
                 ********************************************************************/
                icon_name = "folder-pictures";
                try {
                    pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                } catch (Error e) {
                }
                                               
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.PICTURES);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                
                /*********************************************************************
                 * My Downloads...
                 * 
                 ********************************************************************/
                icon_name = "folder-download";
                try {
                    pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                } catch (Error e) {
                }
                                               
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.DOWNLOAD);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                
                /*********************************************************************
                 * My Videos...
                 * 
                 ********************************************************************/
                icon_name = "folder-videos";
                try {
                    pixbuf = icon_theme.load_icon (icon_name,
                                               (int) global_config.big_icon_size,
                                               Gtk.IconLookupFlags.FORCE_SIZE);
                } catch (Error e) {
                }
                                               
                fi = new Fm.FileInfo.user_special_dir (UserDirectory.VIDEOS);
                if (fi != null) {
                    item = new Desktop.Item (pixbuf, fi);
                    desktop.get_grid ().get_saved_position (item);
                    desktop.get_grid ().insert_item (item);
                }
                

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
            
            if (i > 0)
                global_num_windows++;
        }
    }
}


