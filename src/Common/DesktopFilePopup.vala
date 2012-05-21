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
        
        // Single Directory Popup Actions
//~         private const Gtk.ActionEntry _test_folder_menu_actions[] = {
//~             
//~             // Popup Actions...
//~             {"TerminalHere", Gtk.Stock.NEW, "Terminal Here...", null, null,               _action_terminal_tab}
//~             
//~         };
        
        private const string _test_folder_menu_xml = """
            <popup>
            
              <placeholder name='SPECIAL_ACTIONS'>
                
                <menuitem action='TerminalHere'/>
                
              </placeholder>
            
            </popup>
        """;

        private Gtk.Widget      _owner_widget;
        private Fm.Path         _dest_directory;
        
        private Fm.FileMenu     _fm_file_menu;

        public FilePopup () {
        }
        
        public unowned Fm.FileMenu create (Gtk.Widget owner,
                                  Fm.Path destination,
                                  Fm.FileInfoList<Fm.FileInfo>? file_info_list,
                                  Fm.LaunchFolderFunc? folder_func,
                                  Gtk.ActionEntry[] folder_actions,
                                  string folder_xml) {
            
            _owner_widget = owner;
            _dest_directory = destination;
            
            stdout.printf ("object type: %s\n", owner.get_type ().name ());
            // Create The Popup Menu.
            _fm_file_menu = new Fm.FileMenu.for_files ((Gtk.Window) _owner_widget,
                                                       file_info_list,
                                                       _dest_directory, false);
            _fm_file_menu.set_folder_func (folder_func);
            
            Gtk.ActionGroup act_grp = _fm_file_menu.get_action_group ();
            act_grp.set_translation_domain ("");
            
            // Add Terminal Here... Action...
            Fm.FileInfo? file_info = file_info_list.peek_head ();
            if (file_info.is_dir ()) {
                
                Gtk.UIManager ui = _fm_file_menu.get_ui ();
                Gtk.ActionGroup action_group = _fm_file_menu.get_action_group ();
//~                 action_group.add_actions (_test_folder_menu_actions, this);
//~                 try {
//~                     ui.add_ui_from_string (_test_folder_menu_xml, -1);
//~                 } catch (Error e) {
//~                 }
                action_group.add_actions (folder_actions, this);
                try {
                    ui.add_ui_from_string (folder_xml, -1);
                } catch (Error e) {
                }
            }

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

        
//~         private void _action_terminal_tab (Gtk.Action act) {
            
//~             Fm.Path current = _tree_view.get_cwd ();
//~             
//~             stdout.printf ("sux \n");
//~             
//~             if (current == null)
//~                 return;
//~             
            
            
            // app.new_terminal ();
            //_container_view.new_tab (ViewType.TERMINAL, _dest_directory);
            
            
            
            
//~         }
    }
}


