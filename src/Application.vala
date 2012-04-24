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

uint global_num_windows = 0;

namespace Desktop {

    Application     global_app;
    Desktop.Config? global_config;
    
    bool            global_desktop = false;
    bool            global_debug_mode;
        
    public const OptionEntry[] opt_entries = {
        
        {"desktop", '\0',   0,  OptionArg.NONE, ref global_desktop,     N_("Launch desktop manager"),   null},
        {"debug",   'd',    0,  OptionArg.NONE, ref global_debug_mode,  N_("Run In Debug Mode"),        null},
        {null}
    };

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
            
            stdout.printf ("Remote Command Line !!!\n");
            
            string[] args = command_line.get_arguments ();


            // TODO; parse command line, create manager window....

            return 0;
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
            
            global_app = new Desktop.Application (global_debug_mode);
            
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
            
                Fm.init (global_config);
                /*** fm_volume_manager_init (); ***/

                if (global_desktop) {
                    
                    Desktop.Group desktop = new Desktop.Group (global_debug_mode);
                    desktop.create_desktop ();
                    /***
                        icon_theme_changed = g_signal_connect (gtk_icon_theme_get_default(),
                                                               "changed",
                                                               on_icon_theme_changed,
                                                               null);
                    ***/

                    Gtk.main ();
                    
                    /***
                        Gtk.IconTheme.get_default ().disconnect (icon_theme_changed);
                        desktop_popup.destroy ();
                    ***/
                
                // else create a manager window....
                } else {
                    
                    Manager.Window manager = new Manager.Window ();
                    manager.create ("", true);
                    
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


