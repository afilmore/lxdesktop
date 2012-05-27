/***********************************************************************************************************************
 *      
 *      FolderView.vala
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

    public class FolderView : Fm.FolderView, BaseView {

        public FolderView (Gtk.Notebook parent, string directory) {
            
            // -----------------------------------------------------------------
            // That's the implementation of fm_folder_view_new (mode)...
            Object ();
            
            base.set_mode (Fm.FolderViewMode.LIST_VIEW);
            
            base.small_icon_size =  16;
            base.big_icon_size =    36;
            base.single_click =     false;
            // -----------------------------------------------------------------
            
            base.set_show_hidden (true);
            base.sort (Gtk.SortType.ASCENDING, Fm.FileColumn.NAME);
            base.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
            
            // Create A New Notebook Page...
            Manager.ViewTab view_tab = new Manager.ViewTab (directory);
            
            int new_page = parent.get_current_page () + 1;
            parent.insert_page (base, view_tab, new_page);
            parent.set_tab_reorderable (parent.get_nth_page (new_page), true);
        
            // Connect the close event...
            view_tab.clicked.connect (() => {
                parent.remove (base);
            });

            base.grab_focus ();
            
            base.chdir (new Fm.Path.for_str (directory));
            base.show_all ();
            
            parent.page = new_page;
        }
        
        public bool create () {
        
            return true;
        }
        
        public static Type register_type () {return typeof (Manager.FolderView);}
        
    }
}



