/***********************************************************************************************************************
 *      
 *      Application.vala
 * 
 *      An experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 *
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License Version 2.
 *      http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * 
 *      Purpose: The Main Application Class and program's entry point.
 * 
 *      The application is limited to a single instance, a second instance of the program
 *      can send command lines to the primary instance via DBus.
 *      The program supports a debug or a normal mode.
 *      In debug mode, the desktop is created in a regular window, instead of full screen.
 * 
 *      The application contains a desktop group and a manager group, these simply encapsulate
 *      a GtkWindowGroup, we use these objects to create a new desktop or a new manager window.
 * 
 * 
 * 
 **********************************************************************************************************************/
/*****************************************************************************************
 * XLib specific funtions written in C (Common/xlib.c)
 * 
 * 
 ****************************************************************************************/
namespace XLib {
    extern void get_working_area (Gdk.Screen screen, out Gdk.Rectangle rect);
    extern void forward_event_to_rootwin (Gdk.Screen screen, Gdk.Event event);
}


/*****************************************************************************************
 * Count the number of desktop/manager window to know if we should exit or not.
 * The program keeps running while there's some desktop and/or manager windows...
 * 
 * 
 ****************************************************************************************/
uint global_num_windows = 0;


namespace Desktop {


    /*************************************************************************************
     * These are the two only global objects in the all program, some widgets need to
     * call application functions, such as open a new window or open a new tab.
     * They also need the global desktop/manager's configuration.
     * 
     * 
     ************************************************************************************/
    Application                         global_app;
    Desktop.Config?                     global_config;
    
    
    /*************************************************************************************
     * The application class
     * 
     * 
     ************************************************************************************/
    public class Application : GLib.Application {
        
        bool                            _debug_mode = false;
        
        unowned string[]                _args;
        Desktop.OptionParser            _options;
        
        private Desktop.Group?          _desktop_group;
        private Manager.Group?          _manager_group;
        
        private Desktop.VolumeMonitor?  _volume_monitor;
        
        
        // TODO_axl: make the dialog private and add accessor functions...
        public Desktop.SettingsDialog?  global_settings_dialog;

        
        public Application (string[] args) {
            
            Desktop.OptionParser options = new Desktop.OptionParser (args);
            
            // Set An Application ID For Normal And Debug Mode...
            string app_id;
            
            if (options.debug)
                app_id = "org.noname.lxdesktop-debug";
            else
                app_id = "org.noname.lxdesktop";
            
            Object (application_id:app_id, flags:(ApplicationFlags.HANDLES_COMMAND_LINE));
            
            // NOTE: Members can only be set after calling Object () otherwise it segfaults.
            _debug_mode = options.debug;
            _args = args;
            _options = options;
            
        }
        
        
        /*********************************************************************************
         * Try to run the program as the primary instance...
         * If it's not the fist instance, the function returns false and the commmand
         * line is sent via DBus...
         * 
         * 
         ********************************************************************************/
        public bool run_local () {
        
            try {
            
                this.register (null);
            
            } catch (Error e) {
            
                print ("GApplication Register Error: %s\n", e.message);
                return true;
            }
            
            
            // If not the first instance, return and send arguments via DBus...
            if (this.get_is_remote ())
                return false;
                
            // Command line handler for the primary instance...
            this.command_line.connect (this._on_command_line);
            
            
            /*******************************************************************
             * Primary Instance.
             * 
             * Initialize libraries, create the desktop config, create a
             * desktop and manager group, create a desktop or a file manager
             * window...
             * 
             * 
             ******************************************************************/
            Gtk.init (ref _args);
            
            // Create the Desktop configuration and initialize LibFmCore.
            global_config = new Desktop.Config ();
            Fm.init (global_config);
            
            /*** fm_volume_manager_init (); ***/
            _volume_monitor = new Desktop.VolumeMonitor ();
            
            _desktop_group = new Desktop.Group (_options.debug);
            _manager_group = new Manager.Group (_options.debug);
            
            
            // Create The Desktop...
            if (_options.desktop) {
                
                _desktop_group.create_desktop ();
                
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
                
            // Or A File Manager....
            } else {
                
                this.new_manager_window (_options.remaining);
                
                Gtk.main ();
            }
            
            /*** fm_volume_manager_finalize (); ***/
            
            Fm.finalize ();

            return true;
        }
        
        
        /*********************************************************************************
         * The primary instance receives command lines from remote instances in that
         * handler...
         * 
         * 
         ********************************************************************************/
        private int _on_command_line (ApplicationCommandLine command_line) {
            
            // Handle only remote command lines...
            if (!command_line.get_is_remote ())
                return 0;
            
            string[] args = command_line.get_arguments ();
            Desktop.OptionParser options = new Desktop.OptionParser (args);
            
            // Don't create several desktops...
            if (options.desktop)
                return 0;
                
            // Create a file manager window...
            this.new_manager_window (_options.remaining);
            
            return 0;
        }
        
        
        /*********************************************************************************
         * Global application commands...
         * 
         * 
         ********************************************************************************/
        public bool new_manager_window (string[] folders) {
            
            _manager_group.new_manager_window (Manager.ViewType.FOLDER, folders);

            return true;
        }
        
        public bool new_manager_tab (string[] folders) {
            
            _manager_group.new_manager_tab (Manager.ViewType.FOLDER, folders);

            return true;
        }
        
        public bool new_terminal_window (string[] folders) {
            
            _manager_group.new_manager_window (Manager.ViewType.TERMINAL, folders);

            return true;
        }
        
        public bool new_terminal_tab (string[] folders) {
            
            _manager_group.new_manager_tab (Manager.ViewType.TERMINAL, folders);

            return true;
        }
        
        
        /*********************************************************************************
         * Application's entry point.
         *
         * The program trie to run as the first instance in run_local (), if it's not
         * the first instance it calls GApplication.run () and sends arguments to the
         * first instance via DBus.
         * 
         ********************************************************************************/
        private static int main (string[] args) {
            
            
            global_app = new Desktop.Application (args);
            
            if (!global_app.run_local ())
                return global_app.run (args);
            
            return 0;
        }
    }
}


