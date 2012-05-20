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


        public ViewContainer () {
            
            /***
            
            Gtk.HBox right_box = new Gtk.HBox (false, 0);
            right_box.show ();
            notebook.set_action_widget (right_box, PackType.END);
            
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
            }
            
            return null;
        }
    }
}





