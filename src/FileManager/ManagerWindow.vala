/***********************************************************************************************************************
 * ManagerWindow.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is a simple file manager originally based on LibFm Demo :
 * http://pcmanfm.git.sourceforge.net/git/gitweb.cgi?p=pcmanfm/libfm;a=blob;f=src/demo/main-win.c
 * 
 * Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {
    
    
    private Fm.DirTreeModel? global_dir_tree_model = null;
    
    private enum DirChangeCaller {
        NONE,
        PATH_ENTRY,
        DIR_TREEVIEW,
        FOLDER_VIEW
    }
    
    private const string global_main_menu_xml = """
        <menubar>
          <menu action='FileMenu'>
            <menuitem action='Close'/>
          </menu>
          
          <menu action='HelpMenu'>
            <menuitem action='About'/>
          </menu>
        </menubar>
        
        <toolbar>
            <toolitem action='Up'/>
        </toolbar>
        
        <accelerator action='Location'/>
        <accelerator action='Location2'/>
    """;
    
    
    public class Window : Gtk.Window {
        
        private bool _debug_mode = false;
        
        private const Gtk.ActionEntry _main_win_actions[] = {
            
            {"FileMenu", null, N_("_File"), null, null, null},

                {"Close", Gtk.Stock.CLOSE, N_("_Close Window"), "<Ctrl>W", null,    _on_close_win},
            
            {"GoMenu", null, N_("_Go"), null, null, null},

                {"Up", Gtk.Stock.GO_UP, N_("Parent Folder"), "<Alt>Up", 
                                        N_("Go to parent Folder"),                  _on_go_up},
            
            {"HelpMenu", null, N_("_Help"), null, null, null},

                {"About", Gtk.Stock.ABOUT, null, null, null,                        _on_about},
            
            /*** For accelerators ***/
            {"Location", null, null, "<Alt>d", null,                                _on_location},
            {"Location2", null, null, "<Ctrl>L", null,                              _on_location}
        };
        
        
        /*** Add all these actions later...
        private const Gtk.ToggleActionEntry _main_win_toggle_actions[] = {
            {"ShowHidden", null, N_("Show _Hidden"), "<Ctrl>H", null,               _on_show_hidden, false}
        };

        private const Gtk.RadioActionEntry _main_win_mode_actions[] = {
            {"IconView", null, N_("_Icon View"), null, null,                        Fm.FolderViewMode.ICON_VIEW},
            {"CompactView", null, N_("_Compact View"), null, null,                  Fm.FolderViewMode.COMPACT_VIEW},
            {"ThumbnailView", null, N_("Thumbnail View"), null, null,               Fm.FolderViewMode.THUMBNAIL_VIEW},
            {"ListView", null, N_("Detailed _List View"), null, null,               Fm.FolderViewMode.LIST_VIEW}
        };

        private const Gtk.RadioActionEntry _main_win_sort_type_actions[] = {
            {"Asc", Gtk.Stock.SORT_ASCENDING, null, null, null,                     Gtk.SortType.ASCENDING},
            {"Desc", Gtk.Stock.SORT_DESCENDING, null, null, null,                   Gtk.SortType.DESCENDING}
        };

        private const Gtk.RadioActionEntry _main_win_sort_by_actions[] = {
            {"ByName", null, N_("By _Name"), null, null,                            Fm.FileColumn.NAME},
            {"ByMTime", null, N_("By _Modification Time"), null, null,              Fm.FileColumn.MTIME}
        };
        **/
        
        
        
        
        /*** Single Directory Popup Actions
        private const Gtk.ActionEntry _folder_menu_actions[] = {
            {"NewWin", Gtk.Stock.NEW, N_("Open in New Window"), null, null,         _on_open_in_new_win},
            {"Search", Gtk.Stock.FIND, null, null, null, null}
        };
        ***/
        
        
        private Fm.Path         _current_dir;
        
        
        /***
        
        private Fm.Folder       _folder;
        
        ***/

        private Gtk.UIManager   _ui;
        private Gtk.Toolbar     _toolbar;
        private Fm.PathEntry    _path_entry;
        private Gtk.HPaned      _hpaned;
        private Fm.DirTreeView  _tree_view;
        private Fm.FolderView   _folder_view;
        private Gtk.Statusbar   _statusbar;
        private Gtk.Frame       _vol_status;
        private uint            _statusbar_ctx;
        private uint            _statusbar_ctx2;
        
        private Fm.FileMenu     _file_menu;
        private Gtk.Menu?       _files_popup;
        
        private Desktop.Popup?  _desktop_popup_class;
        private Gtk.Menu        _default_popup;
        
        
        /*** Add these later, rework the navigation history...
        
        private Gtk.Widget      _history_menu;
        private Fm.NavHistory   _nav_history;
        
        private Gtk.Widget      _bookmarks_menu;
        private Fm.Bookmarks    _bookmarks;
        
        ***/

        public Window () {
            
            this.destroy.connect ( () => {
                global_num_windows--;
                if (global_num_windows < 1)
                    Gtk.main_quit ();
            });
            

        }
        
        ~Window () {
            
            //~ global_num_windows--;

            /***
            if (win->folder)
            {
                g_signal_handlers_disconnect_by_func (win->folder, _on_folder_fs_info, win);
                g_object_unref (win->folder);
            }
            ***/

            /***
            
            if (n_wins == 0)
                gtk_main_quit ();
            
            ***/
            
        }

        
        /*********************************************************************************
         * Widget Creation...
         * 
         * 
         ********************************************************************************/
        public bool create (string[] files, string config_file, bool debug = false) {
            
            _debug_mode = debug;
            
            this.set_default_size ((screen.get_width() / 4) * 3, (screen.get_height() / 4) * 3);
            this.set_position (Gtk.WindowPosition.CENTER);

            
            // TODO_axl: save last directory on exit and reload it here... :-P
            _current_dir = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DESKTOP));
            
            
            /*****************************************************************************
             * Create Main Window UI
             * 
             * 
             ****************************************************************************/
            // Main Window Container...
            Gtk.VBox main_vbox = new Gtk.VBox (false, 0);

            // Create The Menubar and Toolbar...
            _ui = new Gtk.UIManager ();
            Gtk.ActionGroup action_group = new Gtk.ActionGroup ("Main");
            action_group.add_actions (_main_win_actions, this);
            
            /*** Add these actions later
            action_group.add_toggle_actions (_main_win_toggle_actions, null);
            action_group.add_radio_actions  (_main_win_mode_actions, Fm.FolderViewMode.ICON_VIEW, _on_change_mode);
            action_group.add_radio_actions  (_main_win_sort_type_actions, Gtk.SortType.ASCENDING, _on_sort_type);
            action_group.add_radio_actions  (_main_win_sort_by_actions, 0, _on_sort_by);
            ***/
            
            Gtk.AccelGroup accel_group = _ui.get_accel_group ();
            this.add_accel_group (accel_group);
            
            _ui.insert_action_group (action_group, 0);
            try {
                _ui.add_ui_from_string (global_main_menu_xml, -1);
            } catch (Error e) {
            }
            
            Gtk.MenuBar menubar = _ui.get_widget ("/menubar") as Gtk.MenuBar;
            main_vbox.pack_start (menubar, false, true, 0);

            _toolbar = _ui.get_widget ("/toolbar") as Gtk.Toolbar;
            
            _toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
            _toolbar.set_style (Gtk.ToolbarStyle.ICONS);
            main_vbox.pack_start (_toolbar, false, true, 0);

            // Add The Location Bar... 
            _path_entry = new Fm.PathEntry ();
            _path_entry.activate.connect (_on_entry_activate);
            Gtk.ToolItem toolitem = new Gtk.ToolItem ();
            toolitem.add (_path_entry);
            toolitem.set_expand (true);
            _toolbar.insert (toolitem, _toolbar.get_n_items () - 1);
            //_toolbar.insert (toolitem, 1);
            
            // Add The HPaned Container...
            _hpaned = new Gtk.HPaned ();
            _hpaned.set_position (200);
            main_vbox.pack_start (_hpaned, true, true, 0);
            
            // Add The Left Side Pane...
            Gtk.VBox side_pane_vbox = new Gtk.VBox (false, 0);
            _hpaned.add1 (side_pane_vbox);
            Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            side_pane_vbox.pack_start (scrolled_window, true, true, 0);
            
            // Add The TreeView...
            _tree_view = new Fm.DirTreeView ();
            scrolled_window.add (_tree_view);
            
            // Fill The TreeView Model...
            if (global_dir_tree_model == null) {

                Fm.FileInfoJob job = new Fm.FileInfoJob (null, Fm.FileInfoJobFlags.NONE);
                
                unowned List<Fm.FileInfo>? l;
                
                
                /*************************************************************************
                 * Create TreeView Root Items....
                 * 
                 * 
                 ************************************************************************/
                // Desktop...
                job.add (Fm.Path.get_desktop ());
                
                // Documents...
                Fm.Path path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DOCUMENTS));
                job.add (path);
                
                // Computer...
                path = new Fm.Path.for_uri ("computer:///");
                job.add (path);
                
                // Trash Can...
                job.add (Fm.Path.get_trash ());
                
                // Root FileSystem...
                job.add (Fm.Path.get_root ());
                
                // Administration Programs...
                job.add (new Fm.Path.for_uri ("menu://applications/system/Administration"));
                
                job.run_sync_with_mainloop ();

                global_dir_tree_model = new Fm.DirTreeModel ();
                global_dir_tree_model.set_show_hidden (true);
                
                Fm.FileInfoList file_infos = job.file_infos;
                
                unowned List<Fm.FileInfo>? list = (List<Fm.FileInfo>) ((Queue) file_infos).head;
                
                for (l = list; l != null; l = l.next) {
                    
                    Fm.FileInfo? fi = (Fm.FileInfo) l.data;
                    
                    //bool expand = (fi.get_path ().is_virtual () == false);
                    bool expand = true;
                    if (fi.get_path ().is_virtual ()) {
                        expand = false;
                    }
                    
                    
                    
                    
                    global_dir_tree_model.add_root (fi, null, expand);
                }
            }
            
            _tree_view.set_model (global_dir_tree_model);
            _tree_view.directory_changed.connect (_tree_view_on_change_directory);
            _tree_view.button_release_event.connect (_tree_view_on_button_release);
            
            // Create The Folder View...
            _folder_view = new Fm.FolderView (Fm.FolderViewMode.LIST_VIEW);
            
            _folder_view.set_show_hidden (true);
            _folder_view.sort (Gtk.SortType.ASCENDING, Fm.FileColumn.NAME);
            _folder_view.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
            
            _folder_view.clicked.connect        (_folder_view_on_file_clicked);
            _folder_view.loaded.connect         (_folder_view_on_view_loaded);
            _folder_view.sel_changed.connect    (_folder_view_on_sel_changed);

            _hpaned.add2 (_folder_view);

            // Create The Statusbar...
            _statusbar = new Gtk.Statusbar ();
            
            // Create Statusbar columns showing volume free space... 
            Gtk.ShadowType shadow_type = Gtk.ShadowType.NONE;
            _statusbar.style_get ("shadow-type", &shadow_type, null);
            
            _vol_status = new Gtk.Frame (null);
            _vol_status.set_shadow_type (shadow_type);
            _statusbar.pack_start (_vol_status, false, true, 0);
            _vol_status.add (new Gtk.Label (null));

            main_vbox.pack_start (_statusbar, false, true, 0);
            
            _statusbar_ctx = _statusbar.get_context_id ("status");
            _statusbar_ctx2 = _statusbar.get_context_id ("status2");

            // Add The Container To The Main Window...
            this.add (main_vbox);
            
            _folder_view.grab_focus ();

            
            
            // TODO_axl: save last directory on exit and reload it here... :-P
            Fm.Path path;
            if (files[0] != "")
                path = new Fm.Path.for_str (files[0]);
            else
                path = Fm.Path.get_desktop ();
            
            
            
            this._change_directory (path);
            
            this.show_all ();

            global_num_windows++;
            
            return true;
        }
        
        private void _change_directory (Fm.Path path, 
                                        DirChangeCaller caller = DirChangeCaller.NONE,
                                        bool save_history = false) {

            if (save_history) {
                
                /*** Save Navigation History...
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (
                                                           GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_chdir (win->nav_history, path, scroll_pos);
                ***/
            }
            
            /***
            
            if (win->folder)
            {
                g_signal_handlers_disconnect_by_func (win->folder, _on_folder_fs_info, win);
                g_object_unref (win->folder);
            }
            
            ***/

            if (caller != DirChangeCaller.PATH_ENTRY)
                _path_entry.set_path (path);
            
            if (caller != DirChangeCaller.DIR_TREEVIEW) {
                
                _tree_view.chdir (path);
                
                /***
                 * Switching the Folder View to /usr/bin for example maybe slow,
                 * so we may ensures that the TreeView Location is graphically updated...
                 * 
                 ***/
                //~ while (Gtk.events_pending ()) {
                //~   Gtk.main_iteration ();
                //~ }
            }
            
            if (caller != DirChangeCaller.FOLDER_VIEW)
                _folder_view.chdir (path);
            
            /***
            
            win->folder = _folder_view.get_folder (_folder_view);
            g_object_ref (win->folder);
            g_signal_connect (win->folder, "fs-info", G_CALLBACK (_on_folder_fs_info), win);
            
            ***/
            
            this._update_statusbar ();
        }
        
        
        /*********************************************************************************
         * Path Entry Signal Handlers...
         * 
         * 
         ********************************************************************************/
        private void _on_entry_activate (Gtk.Entry entry) {
            
            Fm.Path path = _path_entry.get_path ();
            this._change_directory (path, DirChangeCaller.PATH_ENTRY, false);
        }

        private void _on_location (Gtk.Action act) {

            /*** Path Entry Accelerators... (Alt+D / Ctrl+L) ***/
            
            _path_entry.grab_focus ();
        }

        
        /*********************************************************************************
         * TreeView Signal Handlers...
         * 
         * 
         ********************************************************************************/
        private void _tree_view_on_change_directory (uint button, Fm.Path path) {
        
            /*** stdout.printf ("_tree_view_on_change_directory: %u, %s\n", button, path.to_str ()); ***/
            
            this._change_directory (path, DirChangeCaller.DIR_TREEVIEW, false);
        }

        private bool _tree_view_on_button_release (Gdk.EventButton event) {
        
            /*** stdout.printf ("_tree_view_on_button_release\n"); ***/ 
            
            if (event.button != 3)
                return false;
            
            Gtk.TreePath path;
            
            
            if (!_tree_view.get_path_at_pos ((int) event.x, (int) event.y, out path, null, null, null))
                return true;
            
            
            //~ select = gtk_tree_view_get_selection (GTK_TREE_VIEW (view));
            //~ gtk_tree_selection_unselect_all (select);
            //~ gtk_tree_selection_select_path (select, path);
            //~ gtk_tree_path_free (path);
            
            
            Gtk.TreeSelection sel = _tree_view.get_selection ();
            List<Gtk.TreePath>? sels = sel.get_selected_rows (null);
            if (sels == null)
                return true;
                
            Gtk.TreeIter it;
            if (global_dir_tree_model.get_iter (out it, sels.data))
            {
                unowned Fm.FileInfo? fi;
                global_dir_tree_model.get (it, 2, out fi, -1);
                if (fi != null) {
                    
                    stdout.printf ("%s\n", fi.get_disp_name ());
                    
                    _file_menu = new Fm.FileMenu.for_file (this, fi, _tree_view.get_cwd (), false);

                    /** Merge Specific Folder Menu Items...
                    if (_file_menu.is_single_file_type () && fi.is_dir ()) {
                        Gtk.UIManager ui = _file_menu.get_ui ();
                        Gtk.ActionGroup action_group = _file_menu.get_action_group ();
                        action_group.add_actions (_folder_menu_actions, null);
                        try {
                            ui.add_ui_from_string (global_folder_menu_xml, -1);
                        } catch (Error e) {
                        }
                    }**/

                    _files_popup = _file_menu.get_menu ();
                    _files_popup.popup (null, null, null, 3, Gtk.get_current_event_time ());
                }
            }
            return true;
        }

        
        /*********************************************************************************
         * Folder View Signal Handlers...
         * 
         * 
         ********************************************************************************/
        private void _folder_view_on_view_loaded (Fm.Path path) {

            /*** The original code sets the location bar text, scrolls to the navigation history and updates
             * the statusbar... ***/
            
            stdout.printf ("_folder_view_on_view_loaded: %s\n", path.to_str ());
        }

        private void _folder_view_on_file_clicked (Fm.FolderViewClickType type, Fm.FileInfo? fi) {

            switch (type) {
                
                // Double click on an item in the Folder View...
                case Fm.FolderViewClickType.ACTIVATED: {
                    
                    //string target = fi.get_target ();
                    
                    if (fi == null)
                        return;
                    
                    // A directory...
                    if (fi.is_dir ()) {
                        
                        this._change_directory (fi.get_path (), DirChangeCaller.NONE);
                    
                    /*** For Symlinks or Mount Points ???
                         Doesn't work... conflics with opening regular files...
                         
                    } else if (target != "") {
                    
                        Fm.Path path = new Fm.Path.for_str (target);
                        this._change_directory (path, DirChangeCaller.NONE);
                    ***/
                    
                    } else {
                        
                        Fm.launch_file (this, null, fi, null);
                    }
                }
                break;
                
                case Fm.FolderViewClickType.CONTEXT_MENU: {
                    
                    // File/Folder Contextual Menu...
                    if (fi != null) {
                        
                        Fm.FileInfoList files = _folder_view.get_selected_files ();
                        _file_menu = new Fm.FileMenu.for_files (this, files, _folder_view.get_cwd (), false);

                        /** Merge Specific Folder Menu Items...
                        if (_file_menu.is_single_file_type () && fi.is_dir ()) {
                            Gtk.UIManager ui = _file_menu.get_ui ();
                            Gtk.ActionGroup action_group = _file_menu.get_action_group ();
                            action_group.add_actions (_folder_menu_actions, null);
                            try {
                                ui.add_ui_from_string (global_folder_menu_xml, -1);
                            } catch (Error e) {
                            }
                        }**/

                        _files_popup = _file_menu.get_menu ();
                        _files_popup.popup (null, null, null, 3, Gtk.get_current_event_time ());
                    
                    // Default Contextual Menu...
                    } else {
                        
                        // TODO_axl: do this a better way...
                        
                        if (_desktop_popup_class == null)
                            _desktop_popup_class = new Desktop.Popup (this);
                        
                        _default_popup = _desktop_popup_class.create_desktop_popup (_path_entry.get_path ());
                        
                        _default_popup.popup (null, null, null, 3, Gtk.get_current_event_time ());
                    }
                }
                break;
            }
        }
        

        /*********************************************************************************
         * Statusbar Informations...
         * 
         * 
         ********************************************************************************/
        private void _folder_view_on_sel_changed (Fm.FileInfoList? files) {
            
            if (files == null)
                return;
            
            /*** stdout.printf ("_folder_view_on_sel_changed\n"); ***/
            
            /*** Show Informations In The Statusbar ***
            // popup previous message if there is any 
            gtk_statusbar_pop (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx2);
            if (files)
            {
                string msg;
                // FIXME_pcm: display total size of all selected files. 
                if (fm_list_get_length (files) == 1) // only one file is selected 
                {
                    Fm.FileInfo fi = fm_list_peek_head (files);
                    const string size_str = fm_file_info_get_disp_size (fi);
                    if (size_str)
                    {
                        msg = g_strdup_printf ("\"%s\"  (%s) %s",
                                    fm_file_info_get_disp_name (fi),
                                    size_str ? size_str : "",
                                    fm_file_info_get_desc (fi));
                    }
                    else
                    {
                        msg = g_strdup_printf ("\"%s\" %s",
                                    fm_file_info_get_disp_name (fi),
                                    fm_file_info_get_desc (fi));
                    }
                }
                else
                    msg = g_strdup_printf ("%d items selected", fm_list_get_length (files));
                gtk_statusbar_push (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx2, msg);
                g_free (msg);
            }
            ***/
        }

        private void _update_statusbar () {

            /***
            string msg;
            Fm.FolderModel model = _folder_view.get_model (win->folder_view);
            Fm.Folder folder = _folder_view.get_folder (win->folder_view);
            if (model && folder)
            {
                int total_files = fm_list_get_length (folder->files);
                int shown_files = gtk_tree_model_iter_n_children (GTK_TREE_MODEL (model), null);

                // FIXME_pcm: do not access data members. 
                msg = g_strdup_printf ("%d files are listed  (%d hidden).", shown_files,  (total_files - shown_files) );
                gtk_statusbar_pop (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx);
                gtk_statusbar_push (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx, msg);
                g_free (msg);

                fm_folder_query_filesystem_info (folder);
            }
            ***/
        }

        /*** Querie file system informations to display in the Statusbar ***
        private void _on_folder_fs_info (Fm.Folder folder) {

             
            guint64 free, total;
            if (fm_folder_get_filesystem_info (folder, &total, &free))
            {
                char total_str[ 64 ];
                char free_str[ 64 ];
                char buf[128];

                fm_file_size_to_str (free_str, free, true);
                fm_file_size_to_str (total_str, total, true);
                g_snprintf ( buf, G_N_ELEMENTS (buf),
                            "Free space: %s  (Total: %s)", free_str, total_str );
                gtk_label_set_text (GTK_LABEL (gtk_bin_get_child (GTK_BIN (win->vol_status))), buf);
                gtk_widget_show (win->vol_status);
            }
            else
            {
                gtk_widget_hide (win->vol_status);
            }
        }
        ***/
        
        
        /*********************************************************************************
         * File Menu...
         * 
         * 
         ********************************************************************************/
        private void _on_close_win (Gtk.Action act) {

            /*** gtk_widget_destroy (GTK_WIDGET (win)); ***/
        }





        private void _on_go_up (Gtk.Action act) {

            Fm.Path parent = _folder_view.get_cwd ().get_parent ();
            
            if (parent != null)
                this._change_directory (parent);
            
            
        }



        /*********************************************************************************
         * Help Menu...
         * 
         * 
         ********************************************************************************/
        private void _on_about (Gtk.Action act) {
            
            //const string authors[] = {"Axel FILMORE <axel.filmore@gmail.com>", null};
            
            Gtk.AboutDialog about_dialog = new Gtk.AboutDialog ();
            about_dialog.set_program_name ("lxdesktop");
            
            // Add all authors...
            // about_dialog.set_authors (authors);
            
            about_dialog.set_comments ("A Simple File Manager");
            about_dialog.set_website ("https://github.com/afilmore/lxdesktop");
            about_dialog.run ();
            about_dialog.destroy ();
        }
    }
}



