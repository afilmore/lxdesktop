/***********************************************************************************************************************
 * 
 *      ViewContainer.vala
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

    public class ViewContainer : Gtk.Notebook {

        private Fm.FolderView? _temp_folder_view;
        
        public ViewContainer () {
            
            this.set_scrollable (true);
            this.can_focus = false;
            this.set_group_name ("File Manager");
        }
        
        public Fm.FolderView? new_tab (Manager.ViewType type) {
            
            if (type == Manager.ViewType.FOLDER) {
            
                // Create The Folder View...
                Fm.FolderView folder_view = new Fm.FolderView (Fm.FolderViewMode.LIST_VIEW);
                
                folder_view.set_show_hidden (true);
                folder_view.sort (Gtk.SortType.ASCENDING, Fm.FileColumn.NAME);
                folder_view.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
                
                // Create The Tab Label And Button...
                Manager.ViewTab tab = new Manager.ViewTab ("");
                
                // Create A New Notebook Page...
                int new_page = this.get_current_page () + 1;
                this.insert_page (folder_view, tab, new_page);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);
            
                
                _temp_folder_view = folder_view;
                
                
                return folder_view;
            
            } else if (type == Manager.ViewType.TERMINAL) {
                
                Terminal.Widget terminal_widget = new Terminal.Widget ();
                
                terminal_widget.scrollback_lines = -1;
                
                Gtk.Grid grid_container = new Gtk.Grid ();
                
                Gtk.Scrollbar scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, terminal_widget.vadjustment);
                grid_container.attach (terminal_widget,   0, 0, 1, 1);
                grid_container.attach (scrollbar,       1, 0, 1, 1);

                // Make the terminal occupy the whole GUI
                terminal_widget.vexpand = true;
                terminal_widget.hexpand = true;

                // Set up the virtual terminal
                terminal_widget.active_shell ();
                
                // Set up actions releated to the terminal
//~                 main_actions.get_action ("Copy").set_sensitive (terminal_widget.get_has_selection ());
                
                // Create a new tab with the terminal
                Manager.ViewTab tab = new Manager.ViewTab (_("Terminal"));
                terminal_widget.tab = tab;
                
//~                 tab.scroll_event.connect (on_scroll_event);
//~                 tab.terminal = current_terminal;
                
                //tab.width_request = 64;
                
                int new_page = this.get_current_page () + 1;
                
                this.insert_page (grid_container, tab, new_page);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);

                // Bind signals to the new tab
                tab.clicked.connect (() => {
                    
                    // It was doing something
                    if (terminal_widget.has_foreground_process ()) {
                        Terminal.CloseDialog close_dialog = new Terminal.CloseDialog ();
                        if (close_dialog.run () == 1) {
                            this.remove (grid_container);
                        }
                        close_dialog.destroy ();
                    }
                    else {
                        this.remove (grid_container);
                    }
                });

                terminal_widget.window_title_changed.connect (() => {
                    string new_text = terminal_widget.get_window_title ();

                    // Strips the location
                    for (int i = 0; i < new_text.length; i++) {
                        if (new_text[i] == ':') {
                            new_text = new_text[i + 2:new_text.length];
                            break;
                        }
                    }

                    if (new_text.length > 50) {
                        new_text = new_text[new_text.length - 50:new_text.length];
                    }

                    tab.set_text (new_text);
                });
                
                terminal_widget.child_exited.connect (() => {
                    this.remove (grid_container);
                });
                
                terminal_widget.selection_changed.connect (() => {
//~                     main_actions.get_action("Copy").set_sensitive (terminal_widget.get_has_selection ());
                });
                
//~                 terminal_widget.set_font (system_font);
                set_size_request (terminal_widget.calculate_width (30), terminal_widget.calculate_height (8));
                tab.grab_focus ();
                
                grid_container.show_all ();
                
                this.page = new_page;
                
            }
            
            return null;
        }
        
        public Fm.FolderView? get_folder_view () {
            
            return _temp_folder_view;
            
        }
        
        public Fm.Path get_cwd () {
            
            Fm.FolderView? folder_view = this.get_folder_view ();
            
            if (folder_view == null)
                return new Fm.Path.for_str ("");
            
            return folder_view.get_cwd ();
            
        }
    }
}





