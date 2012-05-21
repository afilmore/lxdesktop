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
 * 
 * 
 * 
 ****************************************************************************************/
uint global_num_windows = 0;


/*****************************************************************************************
 * 
 * 
 * 
 ****************************************************************************************/
namespace Desktop {

    Application                 global_app;
    Desktop.Config?             global_config;
    
    
    /*************************************************************************************
     * 
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
            
            // NOTE: Members can only be set after alling Object () otherwise it would segfault.
            _debug_mode = options.debug;
            _args = args;
            _options = options;
            
        }
        
        public bool run_local () {
        
            try {
            
                this.register (null);
            
            } catch (Error e) {
            
                print ("GApplication Register Error: %s\n", e.message);
                return true;
            }
            
            
            if (this.get_is_remote ())
                return false;
                
            this.command_line.connect (this._on_command_line);
            
            
            /*****************************************************************************
             * Primary Instance... Create A Desktop Window Or A FileManager...
             * 
             * 
             ****************************************************************************/
                
            // Create the Desktop configuration, this object derivates of Fm.Config.
            global_config = new Desktop.Config ();
        
            Gtk.init (ref _args);
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
                
            // Or A Manager Window....
            } else {
                
                this.new_manager_window (_options.remaining);
                
                Gtk.main ();
            }
            
            /*** fm_volume_manager_finalize (); ***/
            Fm.finalize ();

            return true;
        }
        
        
        private int _on_command_line (ApplicationCommandLine command_line) {
            
            /*** We handle only remote command lines here... ***/
            if (!command_line.get_is_remote ())
                return 0;
            
            string[] args = command_line.get_arguments ();
            Desktop.OptionParser options = new Desktop.OptionParser (args);
            
            if (options.desktop)
                return 0;
                

            return 0;
        }
        
        public bool new_manager_window (string[] folders) {
            
            _manager_group.new_manager_window (Manager.ViewType.FOLDER, folders);

            return true;
        }
        
        public bool new_manager_tab (string[] folders) {
            
            //_manager_group.new_manager_window (folders);

            return true;
        }
        
        public bool new_terminal_window (string[] folders) {
            
            _manager_group.new_manager_window (Manager.ViewType.TERMINAL, folders);

            return true;
        }
        
        public bool new_terminal_tab (string[] folders) {
            
            //_manager_group.new_manager_window (folders);

            return true;
        }
        
        
        /*********************************************************************************
         * Application's entry point.
         *
         * 
         * 
         ********************************************************************************/
        private static int main (string[] args) {
            
            
            global_app = new Desktop.Application (args);
            

            /*****************************************************************************
             * Remote Instance... Calling GApplication.run () will send the command line
             * to the primary instance via DBus :) Marvelous :-P
             * 
             * 
             ****************************************************************************/
            if (!global_app.run_local ())
                return global_app.run (args);
            
            return 0;
        }
    }
}


