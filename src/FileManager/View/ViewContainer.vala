/***********************************************************************************************************************
 * 
 *      ViewContainer.vala
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
 *      Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {

    
    public class ViewContainer : Gtk.Notebook {

        public ViewContainer () {
            
            this.set_scrollable (true);
            this.can_focus = false;
            this.set_group_name ("File Manager");
            
            Manager.FolderView.register_type ();
        }
        
        public Gtk.Widget? new_tab (Manager.ViewType type, string directory = GLib.Environment.get_current_dir ()) {
            
            if (type == Manager.ViewType.FOLDER) {
            
                // Create The Folder View...
                Manager.FolderView folder_view = new Manager.FolderView (this, directory);
                
                
/* --------------------------------------------------------------------------------------------------------------------
                folder_view.set_show_hidden (true);
                folder_view.sort (Gtk.SortType.ASCENDING, Fm.FileColumn.NAME);
                folder_view.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
                
                // Create A New Notebook Page...
                Manager.ViewTab view_tab = new Manager.ViewTab (directory);
                
                int new_page = this.get_current_page () + 1;
                this.insert_page (folder_view, view_tab, new_page);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);
            
                // Connect the close event...
                view_tab.clicked.connect (() => {
                    this.remove (folder_view);
                    //this.close_tab (folder_view);
                });

                // ???
                folder_view.grab_focus ();
                
                folder_view.chdir (new Fm.Path.for_str (directory));
                folder_view.show_all ();
                
                this.page = new_page;
                
 -------------------------------------------------------------------------------------------------------------------- */
                return folder_view;
            
            
            } else if (type == Manager.ViewType.TERMINAL) {
                
                // TODO_axl: create a terminal view object ???
                
                // The Container Widget...
                Manager.TerminalView terminal_grid = new Manager.TerminalView (this, directory);
                
                
                
                
                
                
                
                
/* --------------------------------------------------------------------------------------------------------------------
                Gtk.Grid terminal_grid = new Gtk.Grid ();
                
                Terminal.Widget terminal_widget = new Terminal.Widget ();
                terminal_widget.scrollback_lines = -1;
                
                
                Gtk.Scrollbar scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, terminal_widget.vadjustment);
                terminal_grid.attach (terminal_widget,  0, 0, 1, 1);
                terminal_grid.attach (scrollbar,        1, 0, 1, 1);

                // Make the terminal occupy the whole GUI
                terminal_widget.vexpand = true;
                terminal_widget.hexpand = true;

                // Set up the virtual terminal
                terminal_widget.active_shell (directory);
                
                // Set up actions releated to the terminal
                // main_actions.get_action ("Copy").set_sensitive (terminal_widget.get_has_selection ());
                
                // Create a new tab with the terminal
                Manager.ViewTab view_tab = new Manager.ViewTab (_("Terminal"));
                terminal_widget.view_tab = view_tab;
                
                // view_tab.scroll_event.connect (on_scroll_event);
                // view_tab.width_request = 64;
                
                int new_page = this.get_current_page () + 1;
                
                this.insert_page (terminal_grid, view_tab, new_page);
                this.set_tab_reorderable (this.get_nth_page (new_page), true);

                // Bind signals to the new tab
                view_tab.clicked.connect (() => {
                    
                    // It was doing something
                    if (terminal_widget.has_foreground_process ()) {
                        
                        Terminal.CloseDialog close_dialog = new Terminal.CloseDialog ();
                        
                        if (close_dialog.run () == 1)
                            //this.remove (terminal_grid);
                            this.close_tab (terminal_grid);
                        
                        close_dialog.destroy ();
                    
                    } else {
                        //this.remove (terminal_grid);
                        this.close_tab (terminal_grid);
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

                    view_tab.set_text (new_text);
                });
                
                terminal_widget.child_exited.connect (() => {
                    //this.remove (terminal_grid);
                    this.close_tab (terminal_grid);
                });
                
                terminal_widget.selection_changed.connect (() => {
                    //~ main_actions.get_action("Copy").set_sensitive (terminal_widget.get_has_selection ());
                });
                
                //~ terminal_widget.set_font (system_font);
                set_size_request (terminal_widget.calculate_width (30), terminal_widget.calculate_height (8));
                
                // ???
                //view_tab.grab_focus ();
                terminal_widget.grab_focus ();
                
                terminal_grid.show_all ();
                
                this.page = new_page;
 -------------------------------------------------------------------------------------------------------------------- */
                
                return terminal_grid;
            
            } else {
            
                stdout.printf ("ViewContainer.new_tab (): Unknown type !\n");
            }
            
            return null;
        }
        
        
        
        /* that's useless indeed... :(
        public void close_tab (Gtk.Widget widget) {
            this.remove (widget);
        }*/
        
        
        // TODO_axl: review these...
        public Gtk.Widget? get_current_view () {
            
            return this.get_nth_page (this.page);
        }
        
        public Manager.FolderView? get_folder_view () {
            
            Gtk.Widget? current = this.get_current_view ();
            
            if (current == null)
                return null;
                
            string object_type = current.get_type ().name ();
            
            if (object_type == "ManagerFolderView")
                return (Manager.FolderView) current;
            else
                return null;
        }
        
        public Fm.Path get_cwd () {
            
            Gtk.Widget? current = this.get_current_view ();
            if (current == null)
                return new Fm.Path.for_str ("");
                
            //stdout.printf ("object type: %s\n", current.get_type ().name ());
            
            Manager.FolderView? folder_view = this.get_folder_view ();
            
            if (folder_view == null)
                return new Fm.Path.for_str ("");
            
            return folder_view.get_cwd ();
            
        }
    }
}





