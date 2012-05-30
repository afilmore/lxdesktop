/***********************************************************************************************************************
 *      
 *      FmSearchView.vala
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

    
//~     enum Column {
//~         COL_FILE_GICON = 0,
//~         COL_FILE_ICON,
//~         COL_FILE_NAME,
//~         COL_FILE_SIZE,
//~         COL_FILE_DESC,
//~         COL_FILE_PERM,
//~         COL_FILE_OWNER,
//~         COL_FILE_MTIME,
//~         COL_FILE_INFO,
//~         N_FOLDER_MODEL_COLS
//~     }
        

    public class FmSearchView : Gtk.ScrolledWindow, BaseView {
        
        private string              _directory;
        private string              _expression;
        
        protected Gtk.TreeView      _tree_view;
        protected Fm.FolderModel    _folder_model;
        
        
        public FmSearchView (Gtk.Notebook parent, string directory, string expression) {
            
            Object (hadjustment: null, vadjustment: null);
            
            _directory = directory;
            _expression = expression;
            
            this._tree_view = new Gtk.TreeView ();
            
            _folder_model = new Fm.FolderModel (Fm.Folder.get (new Fm.Path.for_str ("/")), false);
            //_folder_model = new Fm.FolderModel (Fm.Folder.get (new Fm.Path.for_str ("search://")), false);
                
            _folder_model.set_icon_size (22);
            //_folder_model.loaded.connect (_on_model_loaded);
        
//~             this._folder_model = new Gtk.ListStore (
//~                                                 Column.N_FOLDER_MODEL_COLS,
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string),
//~                                                 typeof (string)
//~                                             );
            
            _tree_view.set_model (_folder_model);

            _tree_view.set_rules_hint (true);
            
            
            Gtk.TreeViewColumn col = new Gtk.TreeViewColumn.with_attributes ("Name",
                                                                             new Gtk.CellRendererText (),
                                                                             "text",
                                                                             Column.COL_FILE_NAME);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_NAME);
            col.set_expand (true);
            col.set_sizing (Gtk.TreeViewColumnSizing.FIXED);
            col.set_fixed_width (200);
            _tree_view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Description",
                                                          new Gtk.CellRendererText (),
                                                          "text",
                                                          Column.COL_FILE_DESC);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_DESC);
            _tree_view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Size",
                                                          new Gtk.CellRendererText (),
                                                          "text",
                                                          Column.COL_FILE_SIZE);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_SIZE);
            _tree_view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Modified",
                                                          new Gtk.CellRendererText (),
                                                          "text",
                                                          Column.COL_FILE_MTIME);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_MTIME);
            _tree_view.append_column (col);

            _tree_view.set_search_column (Column.COL_FILE_NAME);

            _tree_view.set_rubber_banding (true);

            this.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            
            this.add (this._tree_view);
            
            
            /*******************************************************************
             * Create a new tab...
             * 
             * 
             ******************************************************************/
            Manager.ViewTab view_tab = new Manager.ViewTab ("Search...");
            
            /**
            view_tab.scroll_event.connect (on_scroll_event);
            view_tab.width_request = 64;
            **/
            
            int new_page = parent.get_current_page () + 1;
            
            parent.insert_page (this, view_tab, new_page);
            parent.set_tab_reorderable (parent.get_nth_page (new_page), true);

            /*******************************************************************
             * Close signal...
             * 
             * 
             ******************************************************************/
            view_tab.clicked.connect (() => {
                parent.remove (base);
            });

            
            _tree_view.row_activated.connect (on_tree_clicked);

            
            _tree_view.grab_focus ();
            this.show_all ();
            parent.page = new_page;
            
            this._search ();

        }
        
        private void _search () {
            
            //stdout.printf ("search\n");
            
            Gtk.TreeIter iter;
            
            string output;
            string errors;
            int exit;
            
            try {
                //stdout.printf ("run\n");
                Process.spawn_sync ("/",
                                    {"find", _directory, "-name", _expression},
                                    {},
                                    SpawnFlags.SEARCH_PATH,
                                    null, out output, out errors, out exit);
            } catch (Error e) {
                stdout.printf ("errors\n");
                exit = 1;
                errors = e.message;
            }
            
            stdout.printf ("%s\n", output);
            
            if (exit == 0) {
                
                foreach (string row in output.split ("\n")) {
                    if (row != "") {
                        //_folder_model.append (out iter);
                        //_folder_model.set (iter, Column.COL_FILE_NAME, row);
                    }
                }
            }
            stdout.printf ("exit\n");
            
        }
        
        public void on_tree_clicked (Gtk.TreeView widget, Gtk.TreePath path, Gtk.TreeViewColumn column) {
            
            Gtk.TreeIter iter;
            _folder_model.get_iter (out iter, path);
            Value val;
            _folder_model.get_value (iter, Column.COL_FILE_NAME, out val);
            
            string filename = val.get_string ();
            
            //AppInfo app = AppInfo.create_from_commandline (@"xdg-open '$filename'", null, 0);
            //app.launch (null, null);
            
            //Fm.PathList path_list = new Fm.PathList ();
            //path_list.push_tail_noref (new Fm.Path.for_str (filename));
            Fm.FileInfoJob job = new Fm.FileInfoJob (null, 0);
            job.add (new Fm.Path.for_str (filename));
            job.run_sync ();
            
            Fm.FileInfoList<Fm.FileInfo>? file_info_list = job.file_infos;
            Fm.FileInfo? file_info = file_info_list.peek_head ();
            //Fm.FileInfo file_info = new Fm.FileInfo.for_path (new Fm.Path.for_str (filename));
            Fm.launch_file ((Gtk.Window) this, null, file_info, null);
        }
        
        public new static GLib.Type register_type () {return typeof (FmSearchView);}
    }
}




