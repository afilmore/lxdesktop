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

        construct {
            
            //stdout.printf ("Manager.FolderView construct \n");
            //base.mode = Fm.FolderViewMode.LIST_VIEW;
            //base.new (Fm.FolderViewMode.LIST_VIEW);
            
            //Object ();
            //base (Fm.FolderViewMode.LIST_VIEW);
        
        }
        
        public FolderView () {
            
            stdout.printf ("Manager.FolderView constructor \n");
            
            //Object (mode: Fm.FolderViewMode.LIST_VIEW);
            
            //base (Fm.FolderViewMode.LIST_VIEW);
            
            base.new (Fm.FolderViewMode.LIST_VIEW);
        }
        
        public bool create () {
        
            return true;
        }
        
        public static Type register_type () {return typeof (Manager.FolderView);}
        
    }
}



