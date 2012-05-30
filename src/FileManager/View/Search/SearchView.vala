/***********************************************************************************************************************
 *      
 *      SearchView.vala
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
        
        protected Gtk.TreeView  _tree_view;
        protected Gtk.ListStore _model;
        private string          _directory;
        private string          _expression;
        
        Fm.FileInfoList<Fm.FileInfo>? _file_info_list;
        
        public SearchView (Gtk.Notebook parent, string directory, string expression) {
            
            Object (hadjustment: null, vadjustment: null);
            
            _file_info_list = new Fm.FileInfoList<Fm.FileInfo> ();
            
            _directory = directory;
            _expression = expression;
            
            this._tree_view = new Gtk.TreeView ();
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
                                                typeof (void*)
                                            );
            
            _tree_view.set_model (_model);

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

                        // TODO_axl: need to find a better way to get a FileInfo, that's way complicated...
                        Fm.FileInfoJob job = new Fm.FileInfoJob (null, 0);
                        job.add (new Fm.Path.for_str (row));
                        job.run_sync ();
                        
                        Fm.FileInfoList<Fm.FileInfo>? file_info_list = job.file_infos;
                        
                        Fm.FileInfo? file_info = file_info_list.pop_head ();
                        _file_info_list.push_head (file_info);
                        _model.append (out iter);
                        
                        
                        _model.set (iter,
                                    Column.COL_FILE_INFO, file_info,
                                    Column.COL_FILE_NAME, file_info.get_disp_name (),
                                    Column.COL_FILE_DESC, file_info.get_desc ()
                                    );
                        
                        //iter.user_data = file_info;
                    }
                }
            }
            stdout.printf ("exit\n");
            
        }
        
        public void on_tree_clicked (Gtk.TreeView widget, Gtk.TreePath path, Gtk.TreeViewColumn column) {
            
            Gtk.TreeIter iter;
            _model.get_iter (out iter, path);
            
            Value gvalue;
            _model.get_value (iter, Column.COL_FILE_INFO, out gvalue);
            
//~             Fm.FileInfo? file_info = (Fm.FileInfo) iter.user_data;
            Fm.FileInfo? file_info = (Fm.FileInfo) gvalue.get_pointer ();
//~             Fm.FileInfo? file_info = (Fm.FileInfo) gvalue.peek_pointer ();
//~             Fm.FileInfo? file_info = (Fm.FileInfo) gvalue.get_object ();
//~             Fm.FileInfo? file_info = (Fm.FileInfo) gvalue.get_boxed ();
            
            if (file_info == null)
                stdout.printf ("FileInfo is null !!!\n");
            else
                stdout.printf ("FileInfo = %s\n", file_info.get_path ().to_str ());
            
            
            // TODO_axl: need to find a better way to get a FileInfo, that's way complicated...
            //~ Fm.FileInfoJob job = new Fm.FileInfoJob (null, 0);
            //~ job.add (new Fm.Path.for_str (filename));
            //~ job.run_sync ();
            //~ 
            //~ Fm.FileInfoList<Fm.FileInfo>? file_info_list = job.file_infos;
            //~ Fm.FileInfo? file_info = file_info_list.peek_head ();
            
            Fm.launch_file ((Gtk.Window) this, null, file_info, null);
        }
        
        public new static GLib.Type register_type () {return typeof (SearchView);}
    }
}




