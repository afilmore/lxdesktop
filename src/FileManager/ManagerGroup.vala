/***********************************************************************************************************************
 * 
 *      ManagerGroup.vala
 *
 *      An experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 *      
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 *      
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License Version 2.
 *      This program is distributed without any warranty,
 *      See the GNU General Public License for more details.
 *      http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * 
 *      Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {

    
    public enum ViewType {
        NONE,
        FOLDER,
        TERMINAL,
        SEARCH
    }
    
    
    // TODO_axl: Try to derivate a window group instead...
    public class Group {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        
        public Group (bool debug = false) {
            
            _debug_mode = debug;
        
            _wingroup = new Gtk.WindowGroup ();
        }
        
        public bool new_manager_window (Manager.ViewType view_type, string[] folders) {
            
            Manager.Window manager = new Manager.Window (_debug_mode);
            
            manager.create (view_type, folders);
            
            _wingroup.add_window (manager);
            
            return true;
        }
        
        public bool new_manager_tab (Manager.ViewType view_type, string[] folders) {
            
            List<weak Gtk.Window>? _window_list = _wingroup.list_windows ();
            
            if (_window_list != null) {
            
                foreach (Gtk.Window wnd in _window_list) {
                
                     unowned Manager.Window? manager = wnd as Manager.Window;
                     manager.get_view ().new_tab (view_type, folders[0]);
                     manager.present ();
                     return true;
                }
            }
            
            this.new_manager_window (view_type, folders);
            
            return true;
        }
        
        public bool new_search_tab (string directory, string expression) {
            
            List<weak Gtk.Window>? _window_list = _wingroup.list_windows ();
            
            if (_window_list != null) {
            
                foreach (Gtk.Window wnd in _window_list) {
                
                     unowned Manager.Window? manager = wnd as Manager.Window;
                     manager.get_view ().new_tab (Manager.ViewType.SEARCH, directory, expression);
                     manager.present ();
                     return true;
                }
            }
            
            //this.new_manager_window (Manager.ViewType.SEARCH, directory, expression);
            
            return true;
        }
    }
}


