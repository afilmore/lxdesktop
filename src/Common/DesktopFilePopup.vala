/***********************************************************************************************************************
 * 
 *      DesktopFilePopup.vala
 * 
 *      An experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 *
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License Version 2.
 *      http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 *      Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    
    
    public class FilePopup {
        
        // Single Directory Popup Actions
        private const Gtk.ActionEntry _folders_actions [] = {
            
            // Popup Actions...
            {"TerminalHere", "utilities-terminal", "Terminal Here...", null, null, _action_terminal_tab}
            
        };
        
        private const string _folders_xml = """
            <popup>
                <placeholder name='SPECIAL_ACTIONS'>
                    <menuitem action='TerminalHere'/>
                </placeholder>
            </popup>
        """;

        
        private Gtk.Widget      _owner_widget;
        private Fm.Path         _dest_directory;
        
        private Fm.FileMenu     _fm_file_menu;
        
        private string          _open_terminal_dir;

        
        public FilePopup () {
        }
        
        public Gtk.Menu get_menu (Gtk.Widget owner,
                                  Fm.Path destination,
                                  Fm.FileInfoList<Fm.FileInfo>? file_info_list) {
            
            _owner_widget = owner;
            _dest_directory = destination;
            
            // Create The Popup Menu.
            _fm_file_menu = new Fm.FileMenu.for_files ((Gtk.Window) _owner_widget,
                                                       file_info_list,
                                                       _dest_directory, false);
            
            Gtk.ActionGroup action_group = _fm_file_menu.get_action_group ();
            action_group.set_translation_domain ("");
            
            _fm_file_menu.set_folder_func (this.action_open_folder_func);
            
            // Add Terminal Here... Action...
            Fm.FileInfo? file_info = file_info_list.peek_head ();
            if (file_info.is_dir ()) {
                
                _open_terminal_dir = file_info.get_path ().to_str ();
                
                Gtk.UIManager ui = _fm_file_menu.get_ui ();
                
                action_group.add_actions (_folders_actions, this);
                try {
                    ui.add_ui_from_string (_folders_xml, -1);
                } catch (Error e) {
                }
            }

            return _fm_file_menu.get_menu ();
        }
        
        public bool action_open_folder_func (GLib.AppLaunchContext ctx, GLib.List<Fm.FileInfo>? folder_infos,
                                             void *user_data) {
            
            unowned List<Fm.FileInfo>? folder_list = (GLib.List<Fm.FileInfo>) folder_infos;
            
            foreach (Fm.FileInfo fi in folder_list) {
                
                string[] folders = new string [1];
                folders[0] = fi.get_path ().to_str ();
                
                global_app.new_manager_tab (folders);
            }
            return true;
        }
        
        private void _action_terminal_tab (Gtk.Action act) {
            
            string[] folders = new string [1];
            folders[0] = _open_terminal_dir;
            
            global_app.new_terminal_tab (folders);
        }
    }
}


