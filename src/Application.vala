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
 * Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace XLib {
    
    extern void set_wallpaper ();
    extern void get_working_area (Gdk.Screen screen, out Gdk.Rectangle rect);
    extern void forward_event_to_rootwin (Gdk.Screen screen, Gdk.Event event);
}

namespace Desktop {

    Application     global_app;
    Desktop.Config? global_config;
    Fm.FolderModel? global_model = null;    
    
    public class Application {
        
        bool _debug_mode = false;
        
        int _n_screens = 0;
        
        
        /***************************************************************************************************************
         * See where to use all these variables when needed...
         * 
         ***************************************************************************************************************
        private GtkWindowGroup* win_group = null;
        private GtkWidget **desktops = null;
        private GtkAccelGroup* acc_grp = null;

        // 
        private uint icon_theme_changed = 0;
        private uint big_icon_size_changed = 0;
        private uint desktop_text_changed = 0;
        private uint desktop_font_changed = 0;

        // insert GtkUIManager XML definitions
        #include "desktop-ui.c"
        private GtkWidget* desktop_popup = null;

        typedef bool (*DeleteEvtHandler) (GtkWidget*, GdkEvent*);

        char* desktop_font;
        private PangoFontDescription* font_desc = null;

        
        ***************************************************************************************************************/

        public Application () {
            
            Gdk.Display display = Gdk.Display.get_default ();
            _n_screens = display.get_n_screens ();
            
        }
        
        public bool run (bool debug = false) {
            
            if (global_model != null)
                return false;
                
            _debug_mode = debug;
            
            global_config = new Desktop.Config ();

            /***********************************************************************************************************
             * Create a window group...
             * 
             * 
            if (win_group == null)
                win_group = gtk_window_group_new();
            
            */
            
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
            wallpaper_changed = g_signal_connect(global_config, "changed::wallpaper", G_CALLBACK(on_wallpaper_changed), NULL);
            desktop_text_changed = g_signal_connect(global_config, "changed::desktop_text", G_CALLBACK(on_desktop_text_changed), NULL);
            desktop_font_changed = g_signal_connect(global_config, "changed::desktop_font", G_CALLBACK(on_desktop_font_changed), NULL);
            big_icon_size_changed = g_signal_connect(global_config, "changed::big_icon_size", G_CALLBACK(on_big_icon_size_changed), NULL);

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
            
            /***********************************************************************************************************
             *  an array of desktop, one for each screen...
             * 
             * 
            if (desktop_font)
                font_desc = pango_font_description_from_string (desktop_font);
            
            desktops = g_new (GtkWidget*, _n_screens);
            
            */
            
            for (int i = 0; i < _n_screens; i++) {
                
                Desktop.Window desktop = new Desktop.Window ();
                desktop.create (_debug_mode);
            
                /*******************************************************************************************************
                 * Add the dektop window to the window array and to the window group...
                 * 
                 * 
                desktops[i] = desktop;
                win_group.add_window (desktop);
                
                */      

                Gtk.TreeIter it;
                Gdk.Pixbuf icon;
                Fm.FileInfo fi;
                
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
            
            // stdout.printf ("int......\n");
            Fm.init ();
            
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
            
            global_config.wallpaper_changed.disconnect ();
            Gtk.IconTheme.get_default ().disconnect (icon_theme_changed);
            global_config.big_icon_size_changed.disconnect ();
            global_config.desktop_text_changed.disconnect ();
            global_config.desktop_font_changed.disconnect ();
            
            desktop_popup.destroy ();
            
            */
            
            // stdout.printf ("finalize......\n");
            Fm.finalize ();
            
            return 0;
        }
        
        
        /* *************************************************************************************************************
         * Currently unused functions....
         * 
         * 
         */
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
        
        private void _on_icon_theme_changed (Gtk.IconTheme theme) {
            
            /***********************************************************************************************************
             * The user changed the system icon theme.
             * 
             */
            
            this._reload_icons();
            
        }
        
        private void _on_big_icon_size_changed () {
            
            /***********************************************************************************************************
             * The user changed the icon size in the desktop configuration dialog.
             * 
             * 
            
            global_model.set_icon_size (global_config.big_icon_size);
            
            */
            
            this._reload_icons();
            
        }

        private void _reload_icons() {
            
            /***********************************************************************************************************
             * Reload icons when the icon size or the icon theme has changed
             * 
             * 
            
            int i;
            for (i=0; i < _n_screens; ++i) {
                FmDesktop* desktop = desktops[i];
                
                List l;
                for (l=desktop.items; l; l=l.next) {
                    
                    Desktop.Item item = l.data as Desktop.Item;
                    
                    if (item.icon) {
                        item.icon = null;
                        global_model.get (item.it, COL_FILE_ICON, out item.icon, -1);
                    }
                }
                
                this.queue_resize ();
            }
            
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


