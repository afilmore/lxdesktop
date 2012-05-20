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

        Terminal.TerminalWidget test_terminal;
        
        public ViewContainer () {
            
            /***
            
            Gtk.HBox right_box = new Gtk.HBox (false, 0);
            right_box.show ();
            this.set_action_widget (right_box, PackType.END);
            
            ***/
            
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
                
                
                int new_page = this.get_current_page () + 1;
                this.append_page (folder_view);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);
                //this.set_tab_detachable (this.get_nth_page (new_page), true);
            
                return folder_view;
            
            } else if (type == Manager.ViewType.TERMINAL) {
                
                test_terminal = new Terminal.TerminalWidget ();
                
                test_terminal.scrollback_lines = -1;
                
//~                 current_terminal = test_terminal;
                Gtk.Grid grid_container = new Gtk.Grid ();
                
                Gtk.Scrollbar sb = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, test_terminal.vadjustment);
                grid_container.attach (test_terminal, 0, 0, 1, 1);
                grid_container.attach (sb, 1, 0, 1, 1);

                /* Make the terminal occupy the whole GUI */
                test_terminal.vexpand = true;
                test_terminal.hexpand = true;

                /* Set up the virtual terminal */
                test_terminal.active_shell ();
                
                /* Set up actions releated to the terminal */
//~                 main_actions.get_action ("Copy").set_sensitive (test_terminal.get_has_selection ());
                
                /* Create a new tab with the terminal */
                Manager.ViewTab tab = new Manager.ViewTab (_("Terminal"));
                test_terminal.tab = tab;
                
//~                 tab.scroll_event.connect (on_scroll_event);
//~                 tab.terminal = current_terminal;
                tab.width_request = 64;
                
                int new_page = this.get_current_page () + 1;
                tab.index = new_page;
                
                this.insert_page (grid_container, tab, new_page);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);
                this.set_tab_detachable (this.get_nth_page (new_page), true);

                /* Bind signals to the new tab */
                tab.clicked.connect (() => {
                    
                    /* It was doing something */
                    if (test_terminal.has_foreground_process ()) {
                        Terminal.CloseDialog close_dialog = new Terminal.CloseDialog ();
                        if (close_dialog.run () == 1) {
                            this.remove (grid_container);
//~                             terminals.remove (test_terminal);
                        }
                        close_dialog.destroy ();
                    }
                    else {
                        this.remove (grid_container);
//~                         terminals.remove (test_terminal);
                    }
                });

                test_terminal.window_title_changed.connect (() => {
                    string new_text = test_terminal.get_window_title ();

                    /* commented in original code... Strips the location */
                    /*
                    for (int i = 0; i < new_text.length; i++) {
                        if (new_text[i] == ':') {
                            new_text = new_text[i + 2:new_text.length];
                            break;
                        }
                    }

                    if (new_text.length > 50) {
                        new_text = new_text[new_text.length - 50:new_text.length];
                    }
                    */

                    tab.set_text (new_text);
                });
                
                test_terminal.child_exited.connect (() => {
                    this.remove (grid_container);
//~                     terminals.remove (test_terminal);
                });
                
                test_terminal.selection_changed.connect (() => {
//~                     main_actions.get_action("Copy").set_sensitive (test_terminal.get_has_selection ());
                });
                
//~                 test_terminal.set_font (system_font);
                set_size_request (test_terminal.calculate_width (30), test_terminal.calculate_height (8));
                tab.grab_focus ();
                
                grid_container.show_all ();
                
                this.page = new_page;
//~                 terminals.append (test_terminal);
                
            }
            
            return null;
        }
    }
}





