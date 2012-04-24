/***********************************************************************************************************************
 * Utils.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * 
 * Purpose: Mics usefull functions, some may be merged to LibFm Core.
 * 
 * 
 **********************************************************************************************************************/
namespace Utils {
    
    public enum NewFileNameType {
        UNKNOWN,
        FILE,
        TEXT_DOCUMENT,
        FOLDER,
        FROM_DESCRIPTION
    }
    
    static inline bool point_in_rect (double x, double y, Gdk.Rectangle rect) {
        
        return ((x > rect.x) &&  (x < (rect.x + rect.width)) && (y > rect.y) && (y < (rect.y + rect.height)));
    }

    public bool index_to_cell (int idx, int num_cell_y, out Gdk.Point cell) {
        
        return_val_if_fail (num_cell_y != 0, false);
        
        cell.x = idx / num_cell_y;
        cell.y = idx - (cell.x * num_cell_y);
        return true;
    }

    public string get_new_file_name (Fm.Path base_dir, NewFileNameType type, string description = "") {
        
        string tmp_name = "New ";
        
        if (type == NewFileNameType.FILE) {
            
            tmp_name += "File ";
            
        } else if (type == NewFileNameType.FOLDER) {
            
            tmp_name += "Folder ";
            
        } else if (type == NewFileNameType.TEXT_DOCUMENT) {
            
            tmp_name += "Text Document ";

        } else if (type == NewFileNameType.FROM_DESCRIPTION) {
            
            tmp_name += description;
            tmp_name += " ";
        
        } else {
            
            return "";
        }
        
        string test_name = "";
        Fm.Path dest;
        File dest_file = null;
        
        int max_tries = 50;
        for (int i = 1; i < max_tries; i++) {
            
            test_name = "%s (%d)".printf (tmp_name, i);
            
            dest = new Fm.Path.child (base_dir, test_name);
            dest_file = dest.to_gfile ();
            if (!dest_file.query_exists ())
                break;
        }
        
        return test_name;
    }
}


