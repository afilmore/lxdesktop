/***********************************************************************************************************************
 *      
 *      TerminalView.vala
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
 *  
 **********************************************************************************************************************/
namespace Manager {

    public class TerminalView : Gtk.Grid, BaseView {
        
        public TerminalView (Gtk.Notebook parent, string directory) {
            
            Terminal.Widget terminal_widget = new Terminal.Widget ();
            terminal_widget.scrollback_lines = -1;
            
            
            Gtk.Scrollbar scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, terminal_widget.vadjustment);
            this.attach (terminal_widget,  0, 0, 1, 1);
            this.attach (scrollbar,        1, 0, 1, 1);

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
            
            int new_page = parent.get_current_page () + 1;
            
            parent.insert_page (this, view_tab, new_page);
            parent.set_tab_reorderable (parent.get_nth_page (new_page), true);

            // Bind signals to the new tab
            view_tab.clicked.connect (() => {
                
                // It was doing something
                if (terminal_widget.has_foreground_process ()) {
                    
                    Terminal.CloseDialog close_dialog = new Terminal.CloseDialog ();
                    
                    if (close_dialog.run () == 1)
                        parent.remove (this);
                        //this.close_tab (this);
                    
                    close_dialog.destroy ();
                
                } else {
                    parent.remove (this);
                    //this.close_tab (this);
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
            
            terminal_widget.selection_changed.connect (() => {
                //~ main_actions.get_action("Copy").set_sensitive (terminal_widget.get_has_selection ());
            });
            
            //~ terminal_widget.set_font (system_font);
            set_size_request (terminal_widget.calculate_width (30), terminal_widget.calculate_height (8));
            
            
            
            terminal_widget.child_exited.connect (() => {
                parent.remove (this);
                //this.close_tab (this);
            });
            
            
            
            // ???
            //view_tab.grab_focus ();
            terminal_widget.grab_focus ();
            
            this.show_all ();
            
            parent.page = new_page;
            
        }
        
        public bool create () {
        
            return true;
        }
        
        public static Type register_type () {return typeof (TerminalView);}
        
        
    }
}

