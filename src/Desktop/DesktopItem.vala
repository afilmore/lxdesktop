/***********************************************************************************************************************
 * DesktopItem.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: Desktop item object...
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {
    
    public class Item {
        
        public Gdk.Pixbuf       icon;
        private Fm.FileInfo     _fileinfo;
        
        // Position of the item on the desktop and it's index on the grid
        public int              index;
        public Gdk.Point        pixel_pos;
        public Gdk.Point        cell_pos;
        
        public Gdk.Rectangle    icon_rect;
        public Gdk.Rectangle    text_rect;
        
        public bool             is_selected = false;
        
        /*** TODO_axl: Manage Special Items like "My Computer", "Trash Can", mounted volumes, etc... ***/
        
        /***
        bool is_mount : 1;
        bool is_prelight : 1;
        bool fixed_pos : 1; ***/
        
        
        /******************************************************************************************
         * 
         *
         * 
         *****************************************************************************************/
        public Item (Gdk.Pixbuf pix_icon, Fm.FileInfo? fileinfo = null) {
            
            icon = pix_icon;
            _fileinfo = fileinfo;
            
            index = -1;
            cell_pos.x = -1;
            cell_pos.y = -1;
            icon_rect.x = 0;
            icon_rect.y = 0;
            icon_rect.width = 36;
            icon_rect.height = 36;
        }
    
        public string get_disp_name () {
            
            return_val_if_fail (_fileinfo != null, "INVALID ITEM");
            
            return _fileinfo.get_path ().display_basename ();
            
        }
        
        public Fm.FileInfo? get_fileinfo () {
            return _fileinfo;
        }
        
        public inline void get_rect (out Gdk.Rectangle rect) {
            icon_rect.union (text_rect, out rect);
            return;
        }
        
        public int cell_to_index (int num_cell_y) {
            
            int idx = (num_cell_y * cell_pos.x) + cell_pos.y;
            return (idx > -1 ? idx : -1);
        }

        
        /******************************************************************************************
         * 
         *
         * 
         *****************************************************************************************/
        public void invalidate_rect (Gdk.Window window) {
            
            Gdk.Rectangle rect;
            this.get_rect (out rect);
            
            // expend the area of one pixel ? why ?:-P
            --rect.x;
            --rect.y;
            rect.width += 2;
            rect.height += 2;
            
            window.invalidate_rect (rect, false);
        }

        public void move (Gdk.Window window, int new_x, int new_y, bool redraw = false) {
            
            // invalidate current icon area to queue a redraw.
            if (redraw == true)
                this.invalidate_rect (window);
            
            // calculate the offset.
            int offset_x = new_x - pixel_pos.x;
            int offset_y = new_y - pixel_pos.y;
            
            // new origin.
            pixel_pos.x = new_x;
            pixel_pos.y = new_y;
            
            // move the icon and the text to the new position.
            this.icon_rect.x += offset_x;
            this.icon_rect.y += offset_y;
            this.text_rect.x += offset_x;
            this.text_rect.y += offset_y;
            
            /*** Custom positioned items, I think I'll do this a different way...
            if (item.fixed_pos == false) {
                item.fixed_pos = true;
                this.fixed_items = fixed_items.prepend (item);
            }***/
            
            // invalidate the new position to queue a redraw.
            if (redraw)
                this.invalidate_rect (window);
            
            /*** commented in PCManFm... check if the item is overlapped with another item
            List l;
            for (l = this.items; l; l=l.next) {
                Desktop.Item item2 = l.data as Desktop.Item;
            }***/
        }
    }
}


