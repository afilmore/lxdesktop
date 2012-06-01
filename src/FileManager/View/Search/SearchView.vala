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

    enum SearchColumn {
        GICON = 0,
        ICON,
        NAME,
        LOCATION,
        SIZE,
        DESC,
        PERM,
        OWNER,
        MTIME,
        INFO,
        N_COLUMNS
    }
        

    public class SearchView : Gtk.ScrolledWindow, BaseView {
        
        protected Gtk.TreeView          _tree_view;
        protected Gtk.ListStore         _model;
        
        private string                  _directory;
        private string                  _expression;
        
        Fm.FileInfoList<Fm.FileInfo>?   _file_info_list;
        
        
        public SearchView (Gtk.Notebook parent, string directory, string expression) {
            
            Object (hadjustment: null, vadjustment: null);
            
            _file_info_list = new Fm.FileInfoList<Fm.FileInfo> ();
            
            _directory = directory;
            _expression = expression;
            
            
            /*******************************************************************
             * Create the search results widget...
             * 
             * 
             ******************************************************************/
            this._tree_view = new Gtk.TreeView ();
            this._model = new Gtk.ListStore (SearchColumn.N_COLUMNS,
                                             typeof (Icon),
                                             typeof (Gdk.Pixbuf),
                                             typeof (string),
                                             typeof (string),
                                             typeof (string),
                                             typeof (string),
                                             typeof (string),
                                             typeof (string),
                                             typeof (string),
                                             typeof (void*));
            
            _tree_view.set_model (_model);
            _tree_view.set_rules_hint (true);
            
            
            // Create the first column with a file icon...
            Gtk.CellRenderer renderer = new Gtk.CellRendererPixbuf ();
            Gtk.TreeViewColumn new_column = new Gtk.TreeViewColumn ();
            
            new_column.set_title ("Name");
            new_column.pack_start (renderer, false);
            new_column.set_attributes (renderer, "pixbuf", SearchColumn.ICON);
            
            renderer = new Gtk.CellRendererText ();
            /** renderer.set ("ellipsize", PANGO_ELLIPSIZE_END, null); **/
            
            new_column.pack_start (renderer, true);
            new_column.set_attributes (renderer, "text", SearchColumn.NAME);
            new_column.set_sort_column_id (SearchColumn.NAME);
            new_column.set_expand (true);
            new_column.set_resizable (true);
            /** new_column.set_sizing (GTK_TREE_VIEW_COLUMN_FIXED); **/
            new_column.set_fixed_width (200);
            
            _tree_view.append_column (new_column);
            
            // Location Column...
            new_column = new Gtk.TreeViewColumn.with_attributes ("Location",
                                                                 new Gtk.CellRendererText (),
                                                                 "text",
                                                                 SearchColumn.LOCATION);
            new_column.set_resizable (true);
            new_column.set_sort_column_id (SearchColumn.LOCATION);
            _tree_view.append_column (new_column);

            // Description Column...
            new_column = new Gtk.TreeViewColumn.with_attributes ("Description",
                                                                 new Gtk.CellRendererText (),
                                                                 "text",
                                                                 SearchColumn.DESC);
            new_column.set_resizable (true);
            new_column.set_sort_column_id (SearchColumn.DESC);
            _tree_view.append_column (new_column);

            // Size Column...
            new_column = new Gtk.TreeViewColumn.with_attributes ("Size",
                                                                 new Gtk.CellRendererText (),
                                                                 "text",
                                                                 SearchColumn.SIZE);
            new_column.set_resizable (true);
            new_column.set_sort_column_id (SearchColumn.SIZE);
            _tree_view.append_column (new_column);

            // Modified Column...
            new_column = new Gtk.TreeViewColumn.with_attributes ("Modified",
                                                                 new Gtk.CellRendererText (),
                                                                 "text",
                                                                 SearchColumn.MTIME);
            new_column.set_resizable (true);
            new_column.set_sort_column_id (SearchColumn.MTIME);
            _tree_view.append_column (new_column);


            _tree_view.set_search_column (SearchColumn.NAME);
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
             * Connect The Close Signal...
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
            
            Pid         pid;
            int         output_fd;
            IOChannel   output_channel;
            bool        ret = false;
            
            stdout.printf ("START\n");
            
            try {
                ret = Process.spawn_async_with_pipes ("/",
                                                      {"find", _directory, "-name", _expression},
                                                      {},
                                                      SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                                      null,
                                                      out pid,
                                                      null,
                                                      out output_fd,
                                                      null);
            } catch (Error e) {
                stdout.printf ("errors\n");
                //errors = e.message;
            }
            
            if (!ret)
                return;
            
            
            /**
             * Add watch function to catch termination of the process.
             * This function will clean any remnants of process.
             **/
            ChildWatch.add (pid, this._cb_child_watch);
            
            // Create channels that will be used to read data from pipes.
            output_channel = new IOChannel.unix_new (output_fd);

            // Add watches to channels
            output_channel.add_watch (IOCondition.IN | IOCondition.HUP, this._cb_out_watch);

            // Install timeout fnction that will move the progress bar
            //data->timeout_id = g_timeout_add( 100, (GSourceFunc)cb_timeout, data );
        }
        
        
        private bool _cb_out_watch (IOChannel channel, IOCondition cond) {
            
            stdout.printf ("ENTER\n");
            
            if (cond == IOCondition.HUP) {
                stdout.printf ("HUP\n");
                return false;
            }

            
            string  line_string;
            size_t  line_size;

            channel.read_line (out line_string, out line_size, null);
            
            string[] line = line_string.split ("\n");
            
            stdout.printf ("LINE: %s\n", line [0]);
            
            if (line [0] == "")
                return true;
            
            while (Gtk.events_pending ())
                Gtk.main_iteration ();
            
            // TODO_axl: need to find a better way to get a FileInfo, that's way complicated...
            //~ Fm.FileInfoJob job = new Fm.FileInfoJob (null, 0);
            //~ job.add (new Fm.Path.for_str (line_string));
            //~ job.run_sync ();
            //~ 
            //~ Fm.FileInfoList<Fm.FileInfo>? file_info_list = job.file_infos;
            //~ 
            //~ Fm.FileInfo? file_info = file_info_list.pop_head ();
            //~ _file_info_list.push_head (file_info);
            
            Gtk.TreeIter iter;
            _model.append (out iter);
            
            //string location = file_info.get_path ().to_str ();
            
            //~ _model.set (iter,
            //~             SearchColumn.INFO, file_info,
            //~             SearchColumn.ICON, file_info.get_fm_icon ().get_pixbuf (16),
            //~             SearchColumn.NAME, file_info.get_disp_name (),
            //~             SearchColumn.LOCATION, location,
            //~             SearchColumn.DESC, file_info.get_desc ()
            //~             );
            //~ 
            _model.set (iter,
                        SearchColumn.NAME, line [0]
                        );
            
            while (Gtk.events_pending ())
                Gtk.main_iteration ();
            
            stdout.printf ("LEAVE\n");
            return true;
        }

        private void _cb_child_watch (Pid pid, int status) {
            
            Process.close_pid (pid);
            
            stdout.printf ("END\n");
        }

        
        public void on_tree_clicked (Gtk.TreeView widget, Gtk.TreePath path, Gtk.TreeViewColumn column) {
            
            Gtk.TreeIter iter;
            _model.get_iter (out iter, path);
            
            Value gvalue;
            _model.get_value (iter, SearchColumn.INFO, out gvalue);
            
            Fm.FileInfo? file_info = (Fm.FileInfo) gvalue.get_pointer ();
            
            return_if_fail (file_info != null);
            
            Fm.launch_file ((Gtk.Window) this, null, file_info, null);
        }
        
        public new static GLib.Type register_type () {return typeof (SearchView);}
    }
}




