/***********************************************************************************************************************
 *      
 *      SearchResults.vala
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

    enum Column {
      COL_FILE_GICON = 0,
      COL_FILE_ICON,
      COL_FILE_NAME,
      COL_FILE_SIZE,
      COL_FILE_DESC,
      COL_FILE_PERM,
      COL_FILE_OWNER,
      COL_FILE_MTIME,
      COL_FILE_INFO,
      N_FOLDER_MODEL_COLS
    }
        

    public class SearchView : Gtk.ScrolledWindow, BaseView {
        
        protected Gtk.TreeView  _view;
        protected Gtk.ListStore _model;
        
        public SearchView () {
            
            Object (hadjustment: null, vadjustment: null);
            
            this._view = new Gtk.TreeView ();
            this._model = new Gtk.ListStore (
                                                Column.N_FOLDER_MODEL_COLS,
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string),
                                                typeof (string)
                                            );
            
            _view.set_model (_model);

            _view.set_rules_hint(true);
            
            Gtk.TreeViewColumn col = new Gtk.TreeViewColumn.with_attributes ("Name", new Gtk.CellRendererText (), "text", Column.COL_FILE_NAME);
            col.set_sort_column_id (Column.COL_FILE_NAME);
            col.set_expand (true);
            col.set_resizable (true);
            col.set_sizing (Gtk.TreeViewColumnSizing.FIXED);
            col.set_fixed_width (200);
            _view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Description", new Gtk.CellRendererText (), "text", Column.COL_FILE_DESC);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_DESC);
            _view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Size", new Gtk.CellRendererText (), "text", Column.COL_FILE_SIZE);
            col.set_sort_column_id (Column.COL_FILE_SIZE);
            col.set_resizable (true);
            _view.append_column (col);

            col = new Gtk.TreeViewColumn.with_attributes ("Modified", new Gtk.CellRendererText (), "text", Column.COL_FILE_MTIME);
            col.set_resizable (true);
            col.set_sort_column_id (Column.COL_FILE_MTIME);
            _view.append_column (col);

            _view.set_search_column (Column.COL_FILE_NAME);

            _view.set_rubber_banding (true);

            this.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            this.add (this._view);
            this.show_all ();

            _view.row_activated.connect(on_tree_clicked);
        }
        
        public bool create () {
            return true;
        }
        
        public void search (string directory, string expression) {
            
            stdout.printf ("search\n");
            
            string root_dir = "/home/hotnuma";
            
            // create the output view
            Gtk.TreeIter iter;
            
            string output;
            string errors;
            int exit;
            
            try {
                stdout.printf ("run\n");
                Process.spawn_sync("/", {"find", root_dir, "-name", expression}, {}, SpawnFlags.SEARCH_PATH, null, out output, out errors, out exit);
            } catch (Error e) {
                stdout.printf ("errors\n");
                exit = 1;
                errors = e.message;
            }
            
            stdout.printf ("%s\n", output);
            
            if (exit == 0) {
                foreach (string row in output.split("\n")) {
                    if (row != "") {
                        _model.append(out iter);
                        _model.set(iter, Column.COL_FILE_NAME, row);
                    }
                }
            }
            stdout.printf ("exit\n");
            
        }
        
        public void on_tree_clicked (Gtk.TreeView widget, Gtk.TreePath path, Gtk.TreeViewColumn column) {
            
            Value val;
            Gtk.TreeIter iter;
            _model.get_iter(out iter, path);
            _model.get_value(iter, Column.COL_FILE_NAME, out val);
            string filename = val.get_string();
            
            stdout.printf ("%s\n", filename);
            
            AppInfo app = AppInfo.create_from_commandline(@"xdg-open '$filename'", null, 0);
            app.launch(null, null);
            
        }
        
        public new static GLib.Type register_type () {return typeof (SearchView);}

    }
}




