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
        SEARCH_RESULT
    }
    
    
    public class Group {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        
        public Group (bool debug = false) {
            
            _debug_mode = debug;
        
            _wingroup = new Gtk.WindowGroup ();
        }
        
        public bool new_manager_window (Manager.ViewType view_type, string[] folders) {
            
            Manager.Window manager = new Manager.Window (_debug_mode);
            
            manager.create (folders, view_type);
            
            _wingroup.add_window (manager);
            
            return true;
        }
        
        public bool new_manager_terminal (string[] folders) {
            
//~             Manager.Window manager = new Manager.Window ();
//~             manager.create (folders, "", _debug_mode);
//~             
//~             _wingroup.add_window (manager);
            
            return true;
        }
    }
}


