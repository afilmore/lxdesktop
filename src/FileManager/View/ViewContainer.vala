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
            
                // Create A Folder View...
                return new Manager.FolderView (this, directory);
            
            } else if (type == Manager.ViewType.TERMINAL) {
                
                // The A Terminal View...
                return new Manager.TerminalView (this, directory);
            
            } else {
            
                stdout.printf ("ViewContainer.new_tab (): Unknown type !\n");
            }
            
            return null;
        }
        


        
        
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





