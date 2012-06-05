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
        
        cell = {0, 0};
        
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
    
    public void filemanager_new_document (Fm.Path base_dir,
                                            Utils.NewFileNameType file_type,
                                            string template_name = "",
                                            string template_description = "") {
        
        string msg;
        string tmp_name = "";
        
        
        if (file_type == Utils.NewFileNameType.FOLDER) {
            
            msg = "Enter a name for the newly created folder:";
            tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
            
            /*** ask user for a file name... ***/
            while (true) {
                
                string basename = Fm.get_user_input (null, _("Create New..."), _(msg), tmp_name);
                
                if (basename == null || basename == "")
                    return; // cancelled...
                
                Fm.Path dest = new Fm.Path.child (base_dir, basename);
                File dest_file = dest.to_gfile ();
                
                string error_msg = "Unknown Error...";
                try {

                    if (dest_file.make_directory (null))
                        return; // successfull...
                        
                } catch (Error error) {
                    error_msg = error.message;
                }
                Fm.show_error (null, null, error_msg);
            }

        } else if (file_type == Utils.NewFileNameType.FILE) {
            
            msg = "Enter a name for the newly created file:";
            tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
            
            /*** ask user for a file name... ***/
            while (true) {
                
                string basename = Fm.get_user_input (null, _("Create New..."), _(msg), tmp_name);
                
                if (basename == null || basename == "")
                    return; // cancelled...
                
                Fm.Path dest = new Fm.Path.child (base_dir, basename);
                File dest_file = dest.to_gfile ();
                
                string error_msg = "Unknown Error...";
                try {

                    FileOutputStream f = dest_file.create (FileCreateFlags.NONE);
                    if (f != null) {
                        f.close ();
                        return; // successfull...
                    }
                        
                } catch (Error error) {
                    error_msg = error.message;
                }
                Fm.show_error (null, null, error_msg);
            }

        } else if (file_type == Utils.NewFileNameType.FROM_DESCRIPTION) {
            
            msg = "Enter a name for the newly created file:";
            Fm.Path template_dir = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.TEMPLATES));
            Fm.Path template = new Fm.Path.child (template_dir, template_name);
            
            tmp_name = Utils.get_new_file_name (base_dir, file_type, template_description);
            
            /*** ask user for a file name... ***/
            while (true) {
                
                string basename = Fm.get_user_input (null, _("Create New..."), _(msg), tmp_name);
                
                if (basename == null || basename == "")
                    return; // cancelled...
                
                Fm.Path dest_file = new Fm.Path.child (base_dir, basename);
                
                string error_msg = "Unknown Error...";
                try {

                    File file = template.to_gfile ();
                    if (file.copy (dest_file.to_gfile (), FileCopyFlags.NONE))
                        return; // successfull...
                        
                } catch (Error error) {
                    error_msg = error.message;
                }
                Fm.show_error (null, null, error_msg);
            }

            /*** Optionaly it could be possible to open the newly created file...
            string cmdline = "xdg-open \"%s\"".printf (dest_file.to_str ());
            
            try {
                Process.spawn_command_line_async (cmdline);
            } catch (Error e) {
                stdout.printf ("cannot open %s\n", cmdline);
            } ***/
        }
        
        return;
    }
}


