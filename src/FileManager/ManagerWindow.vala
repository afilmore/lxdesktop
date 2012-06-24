/***********************************************************************************************************************
 * 
 *      ManagerWindow.vala
 *
 *      An experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 *
 *      Adapted from LibFm Demo from LXDE (http://lxde.org/)
 *      Copyright 2009 PCMan <pcman.tw@gmail.com>
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 *      
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License Version 2.
 *      This program is distributed without any warranty,
 *      See the GNU General Public License for more details.
 *      http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 *      Purpose: The File Manager Window.
 * 
 *      Creates a Manager Window with all UI Widgets, a location bar, a left ScrolledWindow with a Fm.DirTreeView,
 *      a ViewContainer which is the GtkNotebook Widget, a folder view and a Terminal View. :-P
 *      
 *      The folder view only supports a detailled list view, the ExoIconView Widget needs to be ported to Gtk3.
 * 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {
    
    
    /*** is it a good idea to use a global model ?
    private Fm.DirTreeModel?    global_dir_tree_model = null;
    ***/
    
    
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
        
        
        // try to use an instance TreeModel instead of a global one...
        // since there's a few bugs in the tree model, that may be better...
        private Fm.DirTreeModel?    global_dir_tree_model = null;
        
        
        private const Gtk.ActionEntry _main_win_actions[] = {
            
            // Application Menu...
            {"FileMenu", null, N_("_File"), null, null, null},

            {"Close", Gtk.Stock.CLOSE, N_("_Close Window"), "<Ctrl>W", null,    _action_close_window},
            
            {"GoMenu", null, N_("_Go"), null, null, null},

            {"Up", Gtk.Stock.GO_UP, N_("Parent Folder"), "<Alt>Up", 
                                    N_("Go to parent Folder"),                  _action_go_up},
            
            {"HelpMenu", null, N_("_Help"), null, null, null},

            {"About", Gtk.Stock.ABOUT, null, null, null,                        _action_about},
            
            // Grabs focus to the location bar...
            {"Location", null, null, "<Alt>d", null,                            _action_location},
            {"Location2", null, null, "<Ctrl>L", null,                          _action_location}
        };
        
        
        private Fm.Path                 _current_dir;
        
        
        /** Add these later...
             
            TODO_axl: study and possibly rework the history navigation...
            
            The folder is used to display informations in the status bar...

            Bookmarks are not really needed currently, add these in year 2050...
        
        private Fm.Folder               _folder;
        
        private Gtk.Widget              _history_menu;
        private Fm.NavHistory           _nav_history;
        
        private Gtk.Widget              _bookmarks_menu;
        private Fm.Bookmarks            _bookmarks;
        
        **/

        
        // UI widgets...
        private Gtk.UIManager           _ui_manager;
        private Gtk.Toolbar             _toolbar;
        private Fm.PathEntry            _path_entry;
        private Gtk.Entry               _search_entry;
        private Gtk.HPaned              _hpaned;
        private Fm.DirTreeView          _tree_view;
        
        private Manager.ViewContainer   _container_view;
        
        private Gtk.Statusbar           _statusbar;
        private Gtk.Frame               _vol_status;
        private uint                    _statusbar_ctx;
        private uint                    _statusbar_ctx2;
        
        private bool                    _block_folder_view_change_dir = false;
        // File Popup...
        // TODO_axl: do this a better way...
        private Desktop.FilePopup?      _file_popup;        
        
        // Global Popup...
        // TODO_axl: do this a better way...
        private Desktop.Popup?          _desktop_popup_class;
        private Gtk.Menu                _default_popup;
        
        
        public Window (bool debug = false) {
            
            _debug_mode = debug;
            

            this.destroy.connect ( () => {
                
                // TODO_axl: save last directory on exit... :-P
                
                /***
                if (win->folder)
                {
                    g_signal_handlers_disconnect_by_func (win->folder, _on_folder_fs_info, win);
                    g_object_unref (win->folder);
                }
                ***/

                global_num_windows--;
                if (global_num_windows < 1)
                    Gtk.main_quit ();
            
            });
        }
        
        
        public Manager.ViewContainer get_view () {
            return _container_view;
        }
        
        
        /*********************************************************************************
         * Widget Creation...
         * 
         * 
         ********************************************************************************/
        public bool create (Manager.ViewType view_type, string[] files) {
            
            
            // TODO_axl: save and restore window geometry...
            this.set_default_size ((screen.get_width() / 4) * 3, (screen.get_height() / 4) * 3);
            this.set_position (Gtk.WindowPosition.CENTER);

            
            // TODO_axl: save last directory on exit and reload it here... :-P
            _current_dir = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DESKTOP));
            
            
            /*****************************************************************************
             * Main Window Container...
             * 
             * 
             ****************************************************************************/
            // TODO_axl: use a Gtk.Box instead...
            Gtk.VBox main_vbox = new Gtk.VBox (false, 0);


            /*****************************************************************************
             * Create The Menubar and Toolbar...
             * 
             * 
             ****************************************************************************/
            _ui_manager = new Gtk.UIManager ();
            Gtk.ActionGroup action_group = new Gtk.ActionGroup ("Main");
            action_group.add_actions (_main_win_actions, this);
            
            
            /*** Add these actions later
            action_group.add_toggle_actions (_main_win_toggle_actions, null);
            action_group.add_radio_actions  (_main_win_mode_actions, Fm.FolderViewMode.ICON_VIEW, _on_change_mode);
            action_group.add_radio_actions  (_main_win_sort_type_actions, Gtk.SortType.ASCENDING, _on_sort_type);
            action_group.add_radio_actions  (_main_win_sort_by_actions, 0, _on_sort_by);
            ***/
            
            
            Gtk.AccelGroup accel_group = _ui_manager.get_accel_group ();
            this.add_accel_group (accel_group);
            
            _ui_manager.insert_action_group (action_group, 0);
            try {
                _ui_manager.add_ui_from_string (global_main_menu_xml, -1);
            } catch (Error e) {
            }
            
            Gtk.MenuBar menubar = _ui_manager.get_widget ("/menubar") as Gtk.MenuBar;
            main_vbox.pack_start (menubar, false, true, 0);

            _toolbar = _ui_manager.get_widget ("/toolbar") as Gtk.Toolbar;
            
            _toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
            _toolbar.set_style (Gtk.ToolbarStyle.ICONS);
            main_vbox.pack_start (_toolbar, false, true, 0);

            
            /*****************************************************************************
             * Create the location bar, add it to the Toobar...
             * 
             * 
             ****************************************************************************/
            _path_entry = new Fm.PathEntry ();
            _path_entry.activate.connect (_on_entry_activate);
            
            Gtk.ToolItem toolitem = new Gtk.ToolItem ();
            toolitem.add (_path_entry);
            toolitem.set_expand (true);
            
            
            //_toolbar.insert (toolitem, _toolbar.get_n_items () - 1);
            _toolbar.insert (toolitem, -1);
            
            
            
            _search_entry = new Gtk.Entry ();
            _search_entry.set_placeholder_text("Search for ...");
            toolitem = new Gtk.ToolItem ();
            toolitem.add (_search_entry);
            toolitem.set_expand (false);
            
            //_toolbar.insert (toolitem, _toolbar.get_n_items () - 1);
            _toolbar.insert (toolitem, -1);

            
            
            

            /*****************************************************************************
             * Create The Paned Container...
             * 
             * 
             ****************************************************************************/
            // TODO_axl: use a Gtk.Paned instead...
            _hpaned = new Gtk.HPaned ();
            _hpaned.set_position (200);
            main_vbox.pack_start (_hpaned, true, true, 0);
            
            
            /*****************************************************************************
             * Create The Left Side ScrolledWindow....
             * 
             * 
             ****************************************************************************/
            // TODO_axl: use a Gtk.Box instead...
            Gtk.VBox side_pane_vbox = new Gtk.VBox (false, 0);
            _hpaned.add1 (side_pane_vbox);
            
            Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            side_pane_vbox.pack_start (scrolled_window, true, true, 0);
            
            
            /*****************************************************************************
             * Create the DirTreeView add it to the ScrolledWindow...
             * 
             * 
             ****************************************************************************/
            _tree_view = new Fm.DirTreeView ();
            scrolled_window.add (_tree_view);
            
            // Fill The TreeView Model...
            if (global_dir_tree_model == null) {

                global_dir_tree_model = new Fm.DirTreeModel ();
                global_dir_tree_model.set_show_hidden (true);
                
                Fm.FileInfoJob job = new Fm.FileInfoJob (null, Fm.FileInfoJobFlags.NONE);
                
                unowned List<Fm.FileInfo>? l;
                
                
                /*************************************************************************
                 * Add TreeView Root Items....
                 * 
                 * 
                 ************************************************************************/
                // Desktop...
                job.add (Fm.Path.get_desktop ());
                
                // Computer...
                Fm.Path path = new Fm.Path.for_uri ("computer:///");
                job.add (path);
                
                // Documents...
                path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DOCUMENTS));
                job.add (path);
                
                // Trash Can...
                job.add (Fm.Path.get_trash ());
                
                /**
                 *  The user's Downloads directory:     G_USER_DIRECTORY_DOWNLOAD
                 *  The user's Music directory:         G_USER_DIRECTORY_MUSIC
                 *  The user's Pictures directory:      G_USER_DIRECTORY_PICTURES
                 *  The user's shared directory:        G_USER_DIRECTORY_PUBLIC_SHARE
                 *  The user's Templates directory:     G_USER_DIRECTORY_TEMPLATES
                 *  The user's Movies directory:        G_USER_DIRECTORY_VIDEOS
                 **/
                
                // Documents...
                path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DOWNLOAD));
                job.add (path);
                
                // Documents...
                path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.MUSIC));
                job.add (path);
                
                // Documents...
                path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.PICTURES));
                job.add (path);
                
                // Documents...
                path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.VIDEOS));
                job.add (path);
                
                // Root FileSystem...
                job.add (Fm.Path.get_root ());
                
                // Administration Programs...
                job.add (new Fm.Path.for_uri ("menu://applications/system/Administration"));
                
                job.run_sync_with_mainloop ();

                Fm.FileInfoList file_infos = job.get_list ();
                
                unowned List<Fm.FileInfo>? list = (List<Fm.FileInfo>) ((Queue) file_infos).head;
                
                for (l = list; l != null; l = l.next) {
                    
                    Fm.FileInfo? fi = (Fm.FileInfo) l.data;
                    
                    //bool expand = (fi.get_path ().is_virtual () == false);
                    bool expand = true;
                    if (fi.get_path ().is_virtual ()) {
                        if (fi.get_path ().is_computer ())
                            expand = true;
                        else
                            expand = false;
                    }
                    
                    global_dir_tree_model.add_root (fi, null, expand);
                }
            }
            
            
            // The model is loaded, attach a view to it and connect signals...
            _tree_view.set_model (global_dir_tree_model);
            _tree_view.directory_changed.connect (_tree_view_on_change_directory);
            _tree_view.button_release_event.connect (_tree_view_on_button_release);
            
            

            _search_entry.activate.connect( () => {
                
                Desktop.global_app.search (_tree_view.get_current_directory ().to_str (), _search_entry.get_text ());
            });
        





            /*****************************************************************************
             * Create the ViewContainer Notebook, connect the signals and add it to
             * the Gtk.Paned...
             * 
             * 
             ****************************************************************************/
            _container_view = new Manager.ViewContainer ();
            
            _container_view.page_removed.connect (() => {
                if (_container_view.get_n_pages () == 0)
                    this.destroy ();
            });

            _hpaned.add2 (_container_view);
            
            
            
            
            
            // TODO_axl: get last directory here... :-P
            Fm.Path path;
            if (files[0] != "")
                path = new Fm.Path.for_str (files[0]);
            else
                path = Fm.Path.get_desktop ();
            
            
            
            
            
            /*****************************************************************************
             * Create Folder/Terminal View...
             * 
             * 
             ****************************************************************************/
            Gtk.Widget view = null;
            if (view_type == Manager.ViewType.FOLDER) {
            
                // Create The Folder View...
                view = _container_view.new_tab (ViewType.FOLDER, files[0]);
                Manager.FolderView? folder_view = (Manager.FolderView) view;
                folder_view.clicked.connect (_folder_view_on_file_clicked);
                
                //folder_view.loaded.connect         (_folder_view_on_view_loaded);
                //folder_view.sel_changed.connect    (_folder_view_on_sel_changed);
                
            } else if (view_type == Manager.ViewType.TERMINAL) {
            
                // Create A Terminal View...
                view = _container_view.new_tab (ViewType.TERMINAL, files[0]);
            
            }
            
            
            /*****************************************************************************
             * Create The Statusbar...
             * 
             * 
             ****************************************************************************/
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

            
            /*****************************************************************************
             * Add The Container To The Main Window...
             * 
             * 
             ****************************************************************************/
            this.add (main_vbox);
            
            view.grab_focus ();
            
            
            
            
            this._change_directory (path);
            _container_view.switch_page.connect (_on_switch_page);

            
            this.show_all ();

            global_num_windows++;
            
            return true;
        }
        
        
        /*********************************************************************************
         * File Menu...
         * 
         * 
         ********************************************************************************/
        private void _action_close_window (Gtk.Action act) {
            /*** gtk_widget_destroy (GTK_WIDGET (win)); ***/
        }


        private void _action_go_up (Gtk.Action act) {

            Fm.Path parent = _container_view.get_current_directory ().get_parent ();
            
            if (parent != null)
                this._change_directory (parent);
        }


        /*********************************************************************************
         * Help Menu...
         * 
         * 
         ********************************************************************************/
        private void _action_about (Gtk.Action act) {
            
            // TODO_axl: Add all authors...
            // const string authors[] = {"Axel FILMORE <axel.filmore@gmail.com>", null};
            
            Gtk.AboutDialog about_dialog = new Gtk.AboutDialog ();
            about_dialog.set_program_name ("lxdesktop");
            
            // TODO_axl: Add all authors...
            // about_dialog.set_authors (authors);
            
            about_dialog.set_comments ("A Simple File Manager");
            about_dialog.set_website ("https://github.com/afilmore/lxdesktop");
            about_dialog.run ();
            about_dialog.destroy ();
        }


        /*********************************************************************************
         * 
         * 
         * 
         ********************************************************************************/
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
            
            if (caller != DirChangeCaller.DIR_TREEVIEW)
                _tree_view.set_current_directory (path);
            
            if (caller != DirChangeCaller.FOLDER_VIEW) {
                
                if (!_block_folder_view_change_dir) {
                    Manager.FolderView? folder_view = _container_view.get_folder_view ();
                
                    if (folder_view != null)
                        folder_view.chdir (path);
                }
            }
            
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

        private void _action_location (Gtk.Action act) {

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
            if (!global_dir_tree_model.get_iter (out it, sels.data))
                return true;
            
            // Get The Selected File...
            unowned Fm.FileInfo? file_info;
            global_dir_tree_model.get (it, 2, out file_info, -1);
            if (file_info == null)
                return true;
                
            // TODO_axl: do this a better way...
            if (_file_popup == null)
                _file_popup = new Desktop.FilePopup ();
            
            // Create A FileInfoList Containing The Selected File...
            Fm.FileInfoList<Fm.FileInfo> files = new Fm.FileInfoList<Fm.FileInfo> ();
            files.push_tail (file_info);
            
            Gtk.Menu menu = _file_popup.get_menu ((Gtk.Widget) this, _tree_view.get_current_directory (), files);
            
            if (menu != null)
                menu.popup (null, null, null, 3, Gtk.get_current_event_time ());
            
            return true;
        }

        
        /*********************************************************************************
         * Notebook Signal Handlers...
         * 
         * 
         ********************************************************************************/
        private void _on_switch_page (Gtk.Widget page, uint n) {
            
            stdout.printf ("ManagerWindow: _on_switch_page page = %u current_page = %u\n", n, _container_view.get_current_page ());
            
            //Gtk.Widget? current = this.get_nth_page (this.page);
            Gtk.Widget? current = _container_view.get_nth_page ((int) n);
            
            if (current == null)
                return;
                
            string object_type = current.get_type ().name ();
            
            if (object_type != "ManagerFolderView")
                return;
            
            Manager.FolderView? folder_view = current as Manager.FolderView;
            
            //_container_view.page = (int) n;
            
            _block_folder_view_change_dir = true;
            _tree_view.set_current_directory (folder_view.get_cwd ());
            _block_folder_view_change_dir = false;
            
            //_container_view.set_current_directory (_tree_view.get_current_directory ());
            
            //~ current_tab_label = notebook.get_tab_label (page) as TerminalTab;
            //~ current_tab = notebook.get_nth_page ((int) n);
            //~ current_terminal = ((Grid) page).get_child_at (0, 0) as TerminalWidget;
            //~ title = current_terminal.window_title;
            //~ page.grab_focus ();
        
        }

        /**
        public void remove_page (int page) {
            notebook.remove_page (page);
            if (notebook.get_n_pages () == 0) destroy ();
        }

        public bool on_scroll_event (EventScroll event) {
            if (event.direction == ScrollDirection.UP || event.direction == ScrollDirection.LEFT) {
                if (notebook.get_current_page() != 0) {
                    notebook.set_current_page (notebook.get_current_page() - 1);
                }
            } else if (event.direction == ScrollDirection.DOWN || event.direction == ScrollDirection.RIGHT) {
                if (notebook.get_current_page() != notebook.get_n_pages ()) {
                    notebook.set_current_page (notebook.get_current_page() + 1);
                }
            }
            return false;
        }**/

        
        /*********************************************************************************
         * Folder View Signal Handlers...
         * 
         * I hate that function...
         * 
         * 
         ********************************************************************************/
        private void _folder_view_on_file_clicked (Fm.FolderViewClickType type, Fm.FileInfo? fi) {

            switch (type) {
                
                // Double click on an item in the Folder View...
                case Fm.FolderViewClickType.ACTIVATED: {
                    
                    if (fi == null || fi.get_path ().is_trash ())
                        return;
                    
                    string? target = fi.get_target ();
                    
                    // TODO_axl: create a global_app.launchfile () ???
                    
                    // A directory...
                    if (fi.is_dir ()) {
                        
                        // FIXME_axl: doesn't work with DirChangeCaller.FOLDER_VIEW...
                        this._change_directory (fi.get_path (), DirChangeCaller.NONE);
                             
                    } else if (fi.is_mountable ()) {
                        
                        if (target == null) {
                        
                            stdout.printf ("mountable = null !!!!\n");
                            
                            //Desktop.global_volume_monitor.test (this, fi);
                            
                        } else {
                        
                            Fm.Path path = new Fm.Path.for_str (target);
                            this._change_directory (path, DirChangeCaller.NONE);
                        }
                    
                    } else {
                        
                        Fm.launch_file (this, null, fi, null);
                    }
                }
                break;
                
                case Fm.FolderViewClickType.CONTEXT_MENU: {
                    
                    // File/Folder Contextual Menu...
                    if (fi != null) {
                        
                        // TODO_axl: do this a better way...
                        if (_file_popup == null)
                            _file_popup = new Desktop.FilePopup ();
                        
                        
                        Manager.FolderView? folder_view = _container_view.get_folder_view ();
                        
                        if (folder_view == null)
                            return;
                        
                        Fm.FileInfoList<Fm.FileInfo>? files = folder_view.get_selected_files ();
                        if (files == null)
                            return;
            
                        Gtk.Menu menu = _file_popup.get_menu ((Gtk.Widget) this, folder_view.get_cwd (), files);
                        
                        if (menu != null)
                            menu.popup (null, null, null, 3, Gtk.get_current_event_time ());
            
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
        private void _update_statusbar () {
        }
    }
}



