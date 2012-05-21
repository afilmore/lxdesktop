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
        
        private Gtk.Widget      _owner_widget;
        private Fm.Path         _dest_directory;
        
        private Fm.FileMenu     _fm_file_menu;

        public FilePopup () {
        }
        
        public unowned Fm.FileMenu create (Gtk.Widget owner,
                                  Fm.Path destination,
                                  Fm.FileInfoList<Fm.FileInfo>? file_info_list,
                                  Fm.LaunchFolderFunc? folder_func) {
            
            _owner_widget = owner;
            _dest_directory = destination;
            
            // Create The Popup Menu.
            _fm_file_menu = new Fm.FileMenu.for_files ((Gtk.Window) _owner_widget,
                                                       file_info_list,
                                                       _dest_directory, false);
            _fm_file_menu.set_folder_func (folder_func);
            
            Gtk.ActionGroup act_grp = _fm_file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            return _fm_file_menu;
        }
        
        public Gtk.Menu get_menu (Gtk.Widget owner,
                                  Fm.Path destination,
                                  Fm.FileInfoList<Fm.FileInfo>? file_info_list,
                                  Fm.LaunchFolderFunc? folder_func) {
            
            _owner_widget = owner;
            _dest_directory = destination;
            
            // Create The Popup Menu.
            _fm_file_menu = new Fm.FileMenu.for_files ((Gtk.Window) _owner_widget,
                                                       file_info_list,
                                                       _dest_directory, false);
            _fm_file_menu.set_folder_func (folder_func);
            
            Gtk.ActionGroup act_grp = _fm_file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            return _fm_file_menu.get_menu ();
        }
        
        public Gtk.Menu get_gtk_menu () {
            
            return _fm_file_menu.get_menu ();
        }
        
//~         public unowned Fm.FileMenu get_fm_menu () {
//~             return _fm_file_menu;
//~         }

    }
}


