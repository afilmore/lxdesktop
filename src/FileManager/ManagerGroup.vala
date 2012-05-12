/***********************************************************************************************************************
 * ManagerGroup.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: 
 * 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {

    public class Group {
        
        bool                        _debug_mode = false;
        
        private Gtk.WindowGroup?    _wingroup = null;
        
        //private List<Manager.Window>? _window_list; // use a list ???

        public Group (bool debug = false) {
            
            _debug_mode = debug;
            
            //_window_list = new List<Manager.Window> ();
        }
        
        public bool create_manager (string[] files) {
            
            if (_wingroup == null)
                _wingroup = new Gtk.WindowGroup ();
            
            Manager.Window manager = new Manager.Window ();
            manager.create (files, "", _debug_mode);
            
            _wingroup.add_window (manager);
            
            //_window_list.append (manager);
            
            return true;
        }
    }
}


