/***********************************************************************************************************************
 * 
 *      ManagerGroup.vala
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

    public class Group {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        
        public Group (bool debug = false) {
            
            _debug_mode = debug;
        
        }
        
        public bool create_manager (string[] files) {
            
            if (_wingroup == null)
                _wingroup = new Gtk.WindowGroup ();
            
            Manager.Window manager = new Manager.Window ();
            manager.create (files, "", _debug_mode);
            
            _wingroup.add_window (manager);
            
            return true;
        }
    }
}


