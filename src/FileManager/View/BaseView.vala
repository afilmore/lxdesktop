/***********************************************************************************************************************
 *      
 *      BaseView.vala
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

    public interface BaseView : Gtk.Widget {

        public static Type register_type () {return typeof (Manager.BaseView);}
    }
}


