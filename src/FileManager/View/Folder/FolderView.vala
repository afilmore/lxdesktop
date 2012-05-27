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

        public FolderView () {
            
            Object ();
            
            base.set_mode (Fm.FolderViewMode.LIST_VIEW);
            
            base.small_icon_size =  16;
            base.big_icon_size =    36;
            base.single_click =     false;
        }
        
        public bool create () {
        
            return true;
        }
        
        public static Type register_type () {return typeof (Manager.FolderView);}
        
    }
}



