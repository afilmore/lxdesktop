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
    //extern void set_wallpaper (Gdk.Pixbuf pix, Fm.WallpaperMode wallpaper_mode);
    extern void get_working_area (Gdk.Screen screen, out Gdk.Rectangle rect);
    extern void forward_event_to_rootwin (Gdk.Screen screen, Gdk.Event event);
}

uint global_num_windows = 0;

namespace Desktop {

    Application             global_app;
    Desktop.Config?         global_config;
    
    Desktop.Group?          global_desktop_group;
    Manager.Group?          global_manager_group;
    Desktop.VolumeMonitor?  global_volume_monitor;
    
    public class Application : GLib.Application {
        
        bool _debug_mode = false;
        
        /*********************************************************************
         * See where to use all these variables when needed...
         * 
         *********************************************************************
           private uint icon_theme_changed = 0;
           typedef bool (*DeleteEvtHandler) (GtkWidget*, GdkEvent*);
        *********************************************************************/

        public Application (bool debug = false) {
            
            string app_id = "org.noname.lxdesktop";
            
            if (debug)
                app_id = "org.noname.lxdesktop-debug";
            
            Object (application_id:app_id, flags:(ApplicationFlags.HANDLES_COMMAND_LINE));
            
            _debug_mode = debug;
        }
        
        private void _on_startup () {
            
            stdout.printf ("on_startup\n");
        }
        
        private void _on_activated () {

            stdout.printf ("on_activated\n");
        }
        
        private int _on_command_line (ApplicationCommandLine command_line) {
            
            /*** We handle only remote command lines here... ***/
            if (!command_line.get_is_remote ())
                return 0;
            
            string[] args = command_line.get_arguments ();
            Desktop.OptionParser options = new Desktop.OptionParser (args);
            
            if (!options.desktop) {
                
                //stdout.printf ("create file manager window !!!\n");
                if (global_manager_group == null)
                    global_manager_group = new Manager.Group (options.debug);
                
                global_manager_group.create_manager (options.remaining);
            }

            return 0;
        }
        
       
        /***************************************************************************************************************
         * Application's entry point.
         *
         * 
         * 
         **************************************************************************************************************/
        private static int main (string[] args) {
            
            Desktop.OptionParser options = new Desktop.OptionParser (args);
            
            global_app = new Desktop.Application (options.debug);
            
            global_app.startup.connect (global_app._on_startup);
            global_app.activate.connect (global_app._on_activated);
            global_app.command_line.connect (global_app._on_command_line);
            
            try {
                global_app.register (null);
            } catch (Error e) {
                print ("Application Error: %s\n", e.message);
                return -1;
            }
            
            /*** Primary Instance... Create The Desktop Window ***/
            if (!global_app.get_is_remote ()) {
                
                // Create the Desktop configuration, this object derivates of Fm.Config.
                global_config = new Desktop.Config ();
            
                Gtk.init (ref args);
                Fm.init (global_config);
                
                /*** fm_volume_manager_init (); ***/
                global_volume_monitor = new Desktop.VolumeMonitor ();
                
                
                if (options.desktop) {
                    
                    if (global_desktop_group == null) {
                        global_desktop_group = new Desktop.Group (options.debug);
                        
                        global_desktop_group.create_desktop ();
                        /***
                            icon_theme_changed = g_signal_connect (gtk_icon_theme_get_default(),
                                                                   "changed",
                                                                   on_icon_theme_changed,
                                                                   null);
                        ***/

                        if (global_manager_group == null)
                            global_manager_group = new Manager.Group (options.debug);
                    
                        Gtk.main ();
                        
                        /***
                            Gtk.IconTheme.get_default ().disconnect (icon_theme_changed);
                            desktop_popup.destroy ();
                        ***/
                    }
                    
                // else create a manager window....
                } else {
                    
                    if (global_manager_group == null)
                        global_manager_group = new Manager.Group (options.debug);
                    
                    global_manager_group.create_manager (options.remaining);
                    
                    Gtk.main ();
                }
                
                /*** fm_volume_manager_finalize (); ***/
                Fm.finalize ();

            
            
            /*** Remote Instance... Calling GApplication.run () will send the command line
             *   to the primary instance via DBus :) Marvelous :-P
             ***/
            } else {
                
                /*** stdout.printf ("already an instance !!!\n"); ***/
                return global_app.run (args);
            }
            
            return 0;
        }
    }
}


