/***********************************************************************************************************************
 * DesktopFilePopup.vala
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
 **********************************************************************************************************************/
namespace Desktop {
    
    public class FilePopup {
        
        private Gtk.Widget  _owner_widget;
        private Fm.Path     _dest_directory;
        
        private Fm.FileMenu _file_menu;
        //private Gtk.Menu?   _popup_menu;

        public Gtk.Menu get_menu (Gtk.Widget owner,
                                  Fm.Path destination,
                                  Fm.FileInfoList<Fm.FileInfo>? files,
                                  Fm.LaunchFolderFunc? func) {
            
            _owner_widget = owner;
            _dest_directory = destination;
            
            // Create The Popup Menu.
            _file_menu = new Fm.FileMenu.for_files ((Gtk.Window) _owner_widget, files, _dest_directory, false);
            _file_menu.set_folder_func (func);
            
            Gtk.ActionGroup act_grp = _file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            return _file_menu.get_menu ();
        }
    }
}


