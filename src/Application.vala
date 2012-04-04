/***********************************************************************************************************************
 * Application.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental rewrite of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: Main Application Class and program's entry point.
 * 
 * 
 **********************************************************************************************************************/
namespace XLib {
    
    extern void set_wallpaper (Gdk.Pixbuf pix, Fm.WallpaperMode wallpaper_mode);
    extern void get_working_area (Gdk.Screen screen, out Gdk.Rectangle rect);
    extern void forward_event_to_rootwin (Gdk.Screen screen, Gdk.Event event);
}

namespace Desktop {

    Application     global_app;
    Desktop.Config? global_config;
    Fm.FolderModel? global_model = null;    
    
    public class Application {
        
        bool    _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        int                         _n_screens = 0;
        private Desktop.Window[]    _desktops;
        
        
        /***************************************************************************************************************
         * See where to use all these variables when needed...
         * 
         ***************************************************************************************************************
        private GtkAccelGroup* acc_grp = null;
        private uint icon_theme_changed = 0;
        private GtkWidget* desktop_popup = null;
        typedef bool (*DeleteEvtHandler) (GtkWidget*, GdkEvent*);
        ***************************************************************************************************************/

        public Application () {
            
        }
        
        public bool run (bool debug = false) {
            
            if (global_model != null)
                return false;
                
            _debug_mode = debug;
            
//            global_config = new Desktop.Config ();

            if (_wingroup == null)
                _wingroup = new Gtk.WindowGroup ();
            
            string desktop_path = Environment.get_user_special_dir (UserDirectory.DESKTOP);
            DirUtils.create_with_parents (desktop_path, 0700);
            
            Fm.Path? path = Fm.Path.get_desktop();
            Fm.Folder? folder = Fm.Folder.get (path);
            if (folder == null)
                return false;
                
            global_model = new Fm.FolderModel (folder, false);
            if (global_model == null)
                return false;
                
            // the desktop window will be created only when the model is loaded in the event handler.
            global_model.set_icon_size (global_config.big_icon_size);
            global_model.loaded.connect (_on_model_loaded);
            global_model.set_sort_column_id (Fm.FileColumn.NAME, global_config.sort_type);
            
            
            /***********************************************************************************************************
             * We need to set configuration event handlers, setup the desktop popup menu, etc...
             * 
             * 
            icon_theme_changed = g_signal_connect (gtk_icon_theme_get_default(), "changed", G_CALLBACK(on_icon_theme_changed), NULL);

            // popup menu
            ui = gtk_ui_manager_new();
            act_grp = gtk_action_group_new("Desktop");
            gtk_action_group_set_translation_domain(act_grp, NULL);
            gtk_action_group_add_actions(act_grp, desktop_actions, G_N_ELEMENTS(desktop_actions), NULL);
            gtk_action_group_add_radio_actions(act_grp, desktop_sort_type_actions, G_N_ELEMENTS(desktop_sort_type_actions), GTK_SORT_ASCENDING, on_sort_type, NULL);
            gtk_action_group_add_radio_actions(act_grp, desktop_sort_by_actions, G_N_ELEMENTS(desktop_sort_by_actions), 0, on_sort_by, NULL);
        
            gtk_ui_manager_insert_action_group(ui, act_grp, 0);
            gtk_ui_manager_add_ui_from_string(ui, desktop_menu_xml, -1, NULL);
        
            acc_grp = gtk_ui_manager_get_accel_group(ui);
            for ( i = 0; i < _n_screens; i++ )
                gtk_window_add_accel_group(GTK_WINDOW(desktops[i]), acc_grp);
        
            desktop_popup = (GtkWidget*)g_object_ref(gtk_ui_manager_get_widget(ui, "/popup"));
            */

            Gtk.main ();

            return true;
        }
        
        private void _on_model_loaded () {
            
            // An array of desktop, one for each screen...
            _n_screens = Gdk.Display.get_default ().get_n_screens ();
            _desktops = new Desktop.Window [_n_screens];
            
            for (int i = 0; i < _n_screens; i++) {
                
                Desktop.Window desktop = new Desktop.Window ();
                desktop.create (_debug_mode);
            
                _desktops [i] = desktop;
                _wingroup.add_window (desktop);

                Gtk.TreeIter it;
                Gdk.Pixbuf icon;
                Fm.FileInfo fi;
                
                this._load_special_items (desktop);

                // Load Desktop files/folders from the Global Model, add Desktop Items to the Grid.
                if (global_model.get_iter_first (out it)) {
                    do {
                        
                        global_model.get (it, Fm.FileColumn.ICON, out icon, Fm.FileColumn.INFO, out fi, -1);
                        Desktop.Item item = new Desktop.Item (icon, fi);
                        
                        // append an item into the grid
                        desktop.get_grid ().append_item (item);
                        
                    } while (global_model.iter_next (ref it) == true);
                }
            }
        }

        private void _load_special_items (Desktop.Window desktop) {
            
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            
            Desktop.Item special;
            string icon_name;
            Gdk.Pixbuf pixbuf;
            
            /* Special icons :
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
            
            // My Computer
            icon_name = "computer";
            pixbuf = icon_theme.load_icon (icon_name,
                                           (int) global_config.big_icon_size,
                                           Gtk.IconLookupFlags.FORCE_SIZE);
            special = new Desktop.Item (pixbuf);
            desktop.get_grid ().append_item (special);
            
            // My Documents
            icon_name = "folder-documents";
            pixbuf = icon_theme.load_icon (icon_name,
                                           (int) global_config.big_icon_size,
                                           Gtk.IconLookupFlags.FORCE_SIZE);
            special = new Desktop.Item (pixbuf);
            desktop.get_grid ().append_item (special);
            
            // Trash Can
            icon_name = "user-trash";
            pixbuf = icon_theme.load_icon (icon_name,
                                           (int) global_config.big_icon_size,
                                           Gtk.IconLookupFlags.FORCE_SIZE);
            special = new Desktop.Item (pixbuf);
            desktop.get_grid ().append_item (special);
            
        }
        
        /***************************************************************************************************************
         * Application's entry point.
         *
         * 
         * 
         **************************************************************************************************************/
        private static int main (string[] args) {
            
            Gtk.init (ref args);
            
            /***********************************************************************************************************
             * Add this later...
             * 
                try (Gtk.init_with_args (ref args, "", opt_entries, GETTEXT_PACKAGE)) {
            }
            catch {

            }
            */
            
            global_config = new Desktop.Config ();
            //Fm.Config config = new Fm.Config ();
            //stdout.printf ("big_icon_size: %u\n", config.big_icon_size);
            Fm.init (global_config);
            
            // fm_volume_manager_init ();

            bool debug = true;
            global_app = new Application ();
            global_app.run (debug);
            
            
            /***********************************************************************************************************
             * Save Desktop Items Positions, disconnect signal handlers, destroy menu popup.
             * 
             * 
            fm_volume_manager_finalize ();

            // save item positions
            for (int i = 0; i < _n_screens; i++) {
                save_item_pos (FM_DESKTOP (desktops[i]));
                desktops[i].destroy ();
            }
            
            Gtk.IconTheme.get_default ().disconnect (icon_theme_changed);
            
            desktop_popup.destroy ();
            
            */
            
            Fm.finalize ();
            
            return 0;
        }
        
        
    }
}


