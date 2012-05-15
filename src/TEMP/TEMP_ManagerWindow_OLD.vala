// An old copy of the manager Window...
// Created when merging the file manager:
// https://github.com/afilmore/lxdesktop/tree/573edbb9b3e156a72e8656c1d16f0af4c0b8f59f

// Maybe useless now...


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
            <menuitem action='New'/>
            <menuitem action='Close'/>
          </menu>
          
          <menu action='EditMenu'>
            <menuitem action='Cut'/>
            <menuitem action='Copy'/>
            <menuitem action='Paste'/>
            <menuitem action='Del'/>
            <separator/>
            <menuitem action='Rename'/>
            <menuitem action='Link'/>
            <menuitem action='MoveTo'/>
            <menuitem action='CopyTo'/>
            <separator/>
            <menuitem action='SelAll'/>
            <menuitem action='InvSel'/>
            <separator/>
            <menuitem action='Pref'/>
          </menu>
          
          <menu action='GoMenu'>
            <menuitem action='Prev'/>
            <menuitem action='Next'/>
            <menuitem action='Up'/>
            <separator/>
            <menuitem action='Home'/>
            <menuitem action='Desktop'/>
            <menuitem action='Computer'/>
            <menuitem action='Trash'/>
            <menuitem action='Network'/>
            <menuitem action='Apps'/>
          </menu>
          
          <menu action='BookmarksMenu'>
            <menuitem action='AddBookmark'/>
          </menu>
          
          <menu action='HelpMenu'>
            <menuitem action='About'/>
          </menu>
          
        </menubar>
        
        <toolbar>
            <toolitem action='New'/>
            <toolitem action='Prev'/>
            <toolitem action='Next'/>
            <toolitem action='Up'/>
            <toolitem action='Home'/>
            <toolitem action='Go'/>
        </toolbar>
        
        
        <accelerator action='Location'/>
        <accelerator action='Location2'/>
    """;
    
    private const string global_folder_menu_xml = """
        <popup>
        
          <placeholder name='ph1'>
            
            /* <menuitem action='NewTab'/> */
            <menuitem action='NewWin'/>
            /* <menuitem action='Search'/> */
            
          </placeholder>
        
        </popup>
    """;

    public class Window : Gtk.Window {
        
        private bool _debug_mode = false;
        
        private const Gtk.ActionEntry _main_win_actions[] = {
            
            {"FileMenu", null, N_("_File"), null, null, null},
                {"New", Gtk.Stock.NEW, N_("_New Window"), "<Ctrl>N", null,          _on_new_win},
                {"Close", Gtk.Stock.CLOSE, N_("_Close Window"), "<Ctrl>W", null,    _on_close_win},
            
            {"EditMenu", null, N_("_Edit"), null, null, null},
                {"Cut", Gtk.Stock.CUT, null, null, null,                            _on_cut},
                {"Copy", Gtk.Stock.COPY, null, null, null,                          _on_copy},
                {"Paste", Gtk.Stock.PASTE, null, null, null,                        _on_paste},
                {"Del", Gtk.Stock.DELETE, null, null, null,                         _on_del},
                {"Rename", null, N_("Rename"), "F2", null,                          _on_rename},
                {"Link", null, N_("Create Symlink"), null, null, null},
                {"MoveTo", null, N_("Move To..."), null, null,                      _on_move_to},
                {"CopyTo", null, N_("Copy To..."), null, null,                      _on_copy_to},
                {"SelAll", Gtk.Stock.SELECT_ALL, null, null, null,                  _on_select_all},
                {"InvSel", null, N_("Invert Selection"), null, null,                _on_invert_select},
                {"Pref", Gtk.Stock.PREFERENCES, null, null, null, null},
            
            {"GoMenu", null, N_("_Go"), null, null, null},
                {"Prev", Gtk.Stock.GO_BACK, N_("Previous Folder"), "<Alt>Left",
                                            N_("Previous Folder"),                  _on_go_back},
                {"Next", Gtk.Stock.GO_FORWARD, N_("Next Folder"), "<Alt>Right",
                                            N_("Next Folder"),                      _on_go_forward},
                {"Up", Gtk.Stock.GO_UP, N_("Parent Folder"), "<Alt>Up", 
                                        N_("Go to parent Folder"),                  _on_go_up},
                {"Home", "user-home", N_("Home Folder"), "<Alt>Home",
                                      N_("Home Folder"),                            _on_go_home},
                {"Desktop", "user-desktop", N_("Desktop"), null,
                                            N_("Desktop Folder"),                   _on_go_desktop},
                {"Computer", "computer", N_("My Computer"), null, null,             _on_go_computer},
                {"Trash", "user-trash", N_("Trash Can"), null, null,                _on_go_trash},
                {"Network", Gtk.Stock.NETWORK, N_("Network Drives"), null, null,    _on_go_network},
                {"Apps", "system-software-install", N_("Applications"), null, 
                                                    N_("Installed Applications"),   _on_go_apps},
                {"Go", Gtk.Stock.JUMP_TO, null, null, null,                         _on_go},
            
            {"BookmarksMenu", null, N_("_Bookmarks"), null, null, null},
                {"AddBookmark", Gtk.Stock.ADD, N_("Add To Bookmarks"), null, 
                                               N_("Add To Bookmarks"), null},
            
            {"ViewMenu", null, N_("_View"), null, null, null},
                {"Sort", null, N_("_Sort Files"), null, null, null},
            
            {"HelpMenu", null, N_("_Help"), null, null, null},
                {"About", Gtk.Stock.ABOUT, null, null, null,                        _on_about},
            
            /*** For accelerators ***/
            {"Location", null, null, "<Alt>d", null,                                _on_location},
            {"Location2", null, null, "<Ctrl>L", null,                              _on_location},
            
            /*** For The Popup Menu ***/
            {"CreateNew", Gtk.Stock.NEW, null, null, null, null},
/*            {"NewFolder", "folder", N_("Folder"), null, null,                     _on_create_new},
            {"NewBlank", "text-x-generic", N_("Blank FIle"), null, null,            _on_create_new},*/
            {"Prop", Gtk.Stock.PROPERTIES, null, null, null,                        _on_prop}
        };

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

        /*** Action entries for popup menus ***/
        private const Gtk.ActionEntry _folder_menu_actions[] = {
        /***{"NewTab", Gtk.Stock.NEW, N_("Open in New Tab"), null, null,            _on_open_in_new_tab},***/
            {"NewWin", Gtk.Stock.NEW, N_("Open in New Window"), null, null,         _on_open_in_new_win},
            {"Search", Gtk.Stock.FIND, null, null, null, null}
        };

        private Fm.Path         _current_dir;
        
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
        
        //private Gtk.Menu        _popup;
        /***
        private Fm.Folder       _folder;
        private Gtk.Widget      _bookmarks_menu;
        private Gtk.Widget      _history_menu;

        private Fm.NavHistory   _nav_history;
        private Fm.Bookmarks    _bookmarks;
        ***/

        public Window () {
            
            this.destroy.connect ( () => {
                Gtk.main_quit ();
            });
            
            global_num_windows++;

        }
        
        ~Window () {
            
            global_num_windows--;

            /***
            if (win->folder)
            {
                g_signal_handlers_disconnect_by_func (win->folder, _on_folder_fs_info, win);
                g_object_unref (win->folder);
            }

            if (n_wins == 0)
                gtk_main_quit ();***/
            
        }

        
        /*********************************************************************************
         * Widget Creation...
         * 
         * 
         ********************************************************************************/
        public bool create (string config_file, bool debug = false) {
            
            _debug_mode = debug;
            
            this.set_default_size ((screen.get_width() / 4) * 3, (screen.get_height() / 4) * 3);
            this.set_position (Gtk.WindowPosition.CENTER);


            /***
            Gtk.ActionGroup act_grp;
            Gtk.Action act;
            
            
            Gtk.Widget next_btn;
            Gtk.Widget scroll;
            ***/
            
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
            action_group.add_toggle_actions (_main_win_toggle_actions, null);
            action_group.add_radio_actions  (_main_win_mode_actions, Fm.FolderViewMode.ICON_VIEW, _on_change_mode);
            action_group.add_radio_actions  (_main_win_sort_type_actions, Gtk.SortType.ASCENDING, _on_sort_type);
            action_group.add_radio_actions  (_main_win_sort_by_actions, 0, _on_sort_by);

            Gtk.AccelGroup accel_group = _ui.get_accel_group ();
            this.add_accel_group (accel_group);
            
            _ui.insert_action_group (action_group, 0);
            _ui.add_ui_from_string (global_main_menu_xml, -1);
            
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
            
            // Add The HPaned Container...
            _hpaned = new Gtk.HPaned ();
            _hpaned.set_position (150);
            main_vbox.pack_start (_hpaned, true, true, 0);
            
            // Add The Left Side Pane...
            Gtk.VBox side_pane_vbox = new Gtk.VBox (false, 0);
            _hpaned.add1 (side_pane_vbox);
            Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            side_pane_vbox.pack_start (scrolled_window, true, true, 0);
            
            // Add The TreeView...
            _tree_view = new Fm.DirTreeView();
            scrolled_window.add (_tree_view);
            
            // Fill The TreeView Model...
            if (global_dir_tree_model == null) {

                Fm.FileInfoJob job = new Fm.FileInfoJob (null, Fm.FileInfoJobFlags.NONE);
                
                unowned List<Fm.FileInfo>? l;
                
                /**
                 * query FmFileInfo for home dir and root dir, and then,
                 * add them to dir tree model **/
                
                job.add (Fm.Path.get_desktop ());
                Fm.Path path = new Fm.Path.for_str (Environment.get_user_special_dir (UserDirectory.DOCUMENTS));
                job.add (path);
                path = new Fm.Path.for_uri ("computer:///");
                job.add (path);
                job.add (Fm.Path.get_trash ());
                job.add (Fm.Path.get_root ());
                
                //job.add (Fm.Path.get_home ());
                //job.add (Fm.Path.get_apps_menu ());
                
                /**
                 * FIXME_pcm: maybe it's cleaner to use run_async here ?
                 * 
                 **/
                
                job.run_sync_with_mainloop ();

                global_dir_tree_model = new Fm.DirTreeModel ();
                
                Fm.FileInfoList file_infos = job.file_infos;
                
                unowned List<Fm.FileInfo>? list = (List<Fm.FileInfo>) ( (Queue) file_infos).head;
                
                for (l = list; l != null; l = l.next) {
                    
                    Fm.FileInfo? fi = (Fm.FileInfo) l.data;
                    
                    global_dir_tree_model.add_root (fi, null);
                }

                //g_object_add_weak_pointer (global_dir_tree_model, &global_dir_tree_model);
            }
            
            _tree_view.set_model (global_dir_tree_model);
            _tree_view.directory_changed.connect (_on_tree_change_directory);
            
            _tree_view.chdir (_current_dir);

            // Create The Folder View...
            _folder_view = new Fm.FolderView (Fm.FolderViewMode.LIST_VIEW);
            
            _folder_view.set_show_hidden (false);
            _folder_view.sort (Gtk.SortType.ASCENDING, Fm.FileColumn.NAME);
            _folder_view.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
            
            _folder_view.clicked.connect        (_on_file_clicked);
            _folder_view.loaded.connect         (_on_view_loaded);
            _folder_view.sel_changed.connect    (_on_sel_changed);

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
            //this.change_directory (Fm.Path.get_home ());
            this.change_directory (Fm.Path.get_desktop ());
            
            /*** link places view with folder view. 
            g_signal_connect (_left_pane, "chdir", G_CALLBACK (_on_side_pane_chdir), win);***/

            //_popup = _ui.get_widget ("/popup") as Gtk.Menu;
            //_popup.attach_to_widget (this, null);

            this.show_all ();

            return true;
        }
        
        private void change_directory (Fm.Path path, DirChangeCaller caller = DirChangeCaller.NONE, bool save_history = false) {

            /*** Save Navigation History...
            if (save_history) {
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (
                                                           GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_chdir (win->nav_history, path, scroll_pos);
            }
            ***/
            
//~             if (win->folder)
//~             {
//~                 g_signal_handlers_disconnect_by_func (win->folder, _on_folder_fs_info, win);
//~                 g_object_unref (win->folder);
//~             }

            if (caller != DirChangeCaller.PATH_ENTRY)
                _path_entry.set_path (path);
            
            if (caller != DirChangeCaller.DIR_TREEVIEW)
                _tree_view.chdir (path);
            
            if (caller != DirChangeCaller.FOLDER_VIEW)
                _folder_view.chdir (path);
            
            //fm_side_pane_chdir (FM_SIDE_PANE (win->left_pane), path);

//~             win->folder = fm_folder_view_get_folder (fv);
//~             g_object_ref (win->folder);
//~             g_signal_connect (win->folder, "fs-info", G_CALLBACK (_on_folder_fs_info), win);

            this._update_statusbar ();
            // commented in original code fm_nav_history_set_cur (); 
        }
        


        private void chdir_by_name (string path_str) {

//~             Fm.Path path;
//~             string tmp;
//~             path = fm_path_new_for_str (path_str);

//~             chdir_without_history (win, path);

//~             tmp = fm_path_display_name (path, FALSE);
//~             gtk_entry_set_text (GTK_ENTRY (win->location), tmp);
//~             g_free (tmp);
//~             fm_path_unref (path);
        }
        
        private void update_statusbar () {

//~             string msg;
//~             Fm.FolderModel model = fm_folder_view_get_model (win->folder_view);
//~             Fm.Folder folder = fm_folder_view_get_folder (win->folder_view);
//~             if (model && folder)
//~             {
//~                 int total_files = fm_list_get_length (folder->files);
//~                 int shown_files = gtk_tree_model_iter_n_children (GTK_TREE_MODEL (model), null);
//~ 
//~                 // FIXME_pcm: do not access data members. 
//~                 msg = g_strdup_printf ("%d files are listed  (%d hidden).", shown_files,  (total_files - shown_files) );
//~                 gtk_statusbar_pop (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx);
//~                 gtk_statusbar_push (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx, msg);
//~                 g_free (msg);
//~ 
//~                 fm_folder_query_filesystem_info (folder);
//~             }
        }

        private void _on_tree_change_directory (uint button, Fm.Path path) {
        
            /*** Commented in original code...
            g_signal_handlers_block_by_func(win->places_view, on_places_chdir, win);
            fm_main_win_chdir(win, path);
            g_signal_handlers_unblock_by_func(win->places_view, on_places_chdir, win);
            ***/
            
            /*if(sp->cwd)
                fm_path_unref(sp->cwd);
            sp->cwd = fm_path_ref(path);
            g_signal_emit(sp, signals[CHDIR], 0, button, path);
            */
            
            stdout.printf ("_on_tree_change_directory: %u, %s\n", button, path.to_str ());
            //_folder_view.chdir (path);
            this.change_directory (path, DirChangeCaller.DIR_TREEVIEW, false);
        }

        private void _on_entry_activate (Gtk.Entry entry) {

//~             Fm.Path path = fm_path_entry_get_path (FM_PATH_ENTRY (entry));
//~             chdir_without_history (win, path);
        }

        private void _on_view_loaded (Fm.Path path) {

//~             const FmNavHistoryItem item;
//~              =  (FmMainWin)user_data;
//~             Fm.PathEntry entry = FM_PATH_ENTRY (win->location);
//~ 
//~             fm_path_entry_set_path ( entry, path );
//~ 
//~             // scroll to recorded position 
//~             item = fm_nav_history_get_cur (win->nav_history);
//~             gtk_adjustment_set_value ( gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (view)), item->scroll_pos);
//~ 
//~             // update status bar 
//~             update_statusbar (win);
        }

        private bool open_folder_func (AppLaunchContext ctx, List folder_infos, void * user_data, Error err) {

//~              = FM_MAIN_WIN (user_data);
//~             GList l = folder_infos;
//~             Fm.FileInfo fi =  (Fm.FileInfo)l->data;
//~             chdir (win, fi->path);
//~             l=l->next;
//~             for (; l; l=l->next)
//~             {
//~                 Fm.FileInfo fi =  (Fm.FileInfo)l->data;
//~                 // FIXME_pcm: open in new window 
//~             }
            return true;
        }

        private void _on_file_clicked (Fm.FolderViewClickType type, Fm.FileInfo? fi) {

            string fpath;
            string uri;
            
            AppLaunchContext ctx;
            
            switch (type) {
                
                case Fm.FolderViewClickType.ACTIVATED: {
                    
                    if (fi == null)
                        return;
                    
                    if (fi.is_dir ()) {
                        this.change_directory (fi.get_path (), DirChangeCaller.NONE);
                    
                    /*** FIXME_axl: use accessor functions. 
                    } else if (fi->target) {
                    
                        // FIXME_axl: use Fm.Path here. 
                        //chdir_by_name (fi->target);
                        this.chdir_by_name (fi.get_path ().to_str ());
                    
                    ***/
                    
                    } else {
                        // Fm.launch_file (null, fi, open_folder_func, win);
                        Fm.launch_file (this, null, fi, null);
                    }
                }
                break;
                
                case Fm.FolderViewClickType.CONTEXT_MENU: {
                    if (fi != null) {
                        /***
                        FmFileMenu menu;
                        Gtk.Menu popup;
                        Fm.FileInfoList files = fm_folder_view_get_selected_files (fv);
                        menu = fm_file_menu_new_for_files (GTK_WINDOW (win), files, fm_folder_view_get_cwd (fv), true);
                        fm_file_menu_set_folder_func (menu, open_folder_func, win);
                        fm_list_unref (files);

                        // merge some specific menu items for folders 
                        if (fm_file_menu_is_single_file_type (menu) && fm_file_info_is_dir (fi))
                        {
                        Gtk.UIManager ui = fm_file_menu_get_ui (menu);
                        Gtk.ActionGroup act_grp = fm_file_menu_get_action_group (menu);
                        gtk_action_group_add_actions (act_grp, folder_menu_actions, G_N_ELEMENTS (folder_menu_actions), win);
                        gtk_ui_manager_add_ui_from_string (ui, folder_menu_xml, -1, null);
                        }

                        popup = fm_file_menu_get_menu (menu);
                        gtk_menu_popup (popup, null, null, null, fi, 3, gtk_get_current_event_time ());
                        ***/
                    // no files are selected. Show context menu of current folder.
                    } else {
                        /***
                        gtk_menu_popup (GTK_MENU (win->popup), null, null, null, null, 3, gtk_get_current_event_time ());
                        ***/
                    }
                }
                break;
                
                case Fm.FolderViewClickType.MIDDLE_CLICK: {
                    debug ("middle click!");
                }
                break;
            }
        }

        private void _on_sel_changed (Fm.FileInfoList? files) {
            
            if (files == null)
                return;
                
//~             // popup previous message if there is any 
//~             gtk_statusbar_pop (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx2);
//~             if (files)
//~             {
//~                 string msg;
//~                 // FIXME_pcm: display total size of all selected files. 
//~                 if (fm_list_get_length (files) == 1) // only one file is selected 
//~                 {
//~                     Fm.FileInfo fi = fm_list_peek_head (files);
//~                     const string size_str = fm_file_info_get_disp_size (fi);
//~                     if (size_str)
//~                     {
//~                         msg = g_strdup_printf ("\"%s\"  (%s) %s",
//~                                     fm_file_info_get_disp_name (fi),
//~                                     size_str ? size_str : "",
//~                                     fm_file_info_get_desc (fi));
//~                     }
//~                     else
//~                     {
//~                         msg = g_strdup_printf ("\"%s\" %s",
//~                                     fm_file_info_get_disp_name (fi),
//~                                     fm_file_info_get_desc (fi));
//~                     }
//~                 }
//~                 else
//~                     msg = g_strdup_printf ("%d items selected", fm_list_get_length (files));
//~                 gtk_statusbar_push (GTK_STATUSBAR (win->statusbar), win->statusbar_ctx2, msg);
//~                 g_free (msg);
//~             }
//~         }

//~         private void _on_side_pane_chdir (Fm.SidePane sp, guint button, Fm.Path path) {

                    // commented in original code g_signal_handlers_block_by_func (win->dirtree_view, _on_dirtree_chdir, win);
//~             chdir (win, path);
                    // commented in original code g_signal_handlers_unblock_by_func (win->dirtree_view, _on_dirtree_chdir, win);
        }


        private void _on_folder_fs_info (Fm.Folder folder) {

//~             guint64 free, total;
//~             if (fm_folder_get_filesystem_info (folder, &total, &free))
//~             {
//~                 char total_str[ 64 ];
//~                 char free_str[ 64 ];
//~                 char buf[128];
//~ 
//~                 fm_file_size_to_str (free_str, free, true);
//~                 fm_file_size_to_str (total_str, total, true);
//~                 g_snprintf ( buf, G_N_ELEMENTS (buf),
//~                             "Free space: %s  (Total: %s)", free_str, total_str );
//~                 gtk_label_set_text (GTK_LABEL (gtk_bin_get_child (GTK_BIN (win->vol_status))), buf);
//~                 gtk_widget_show (win->vol_status);
//~             }
//~             else
//~             {
//~                 gtk_widget_hide (win->vol_status);
//~             }
        }




        private void _on_new_win (Gtk.Action act) {

//~             win = new ();
//~             gtk_window_set_default_size (GTK_WINDOW (win), 640, 480);
//~             chdir (win, fm_path_get_home ());
//~             gtk_window_present (GTK_WINDOW (win));
        }

        private void _on_close_win (Gtk.Action act) {

//~             gtk_widget_destroy (GTK_WIDGET (win));
        }



        private void _on_cut (Gtk.Action act) {

//~             Gtk.Widget focus = gtk_window_get_focus ( (Gtk.Window)win);
//~             if (GTK_IS_EDITABLE (focus) &&
//~                gtk_editable_get_selection_bounds ( (Gtk.Editable)focus, null, null) )
//~             {
//~                 gtk_editable_cut_clipboard ( (Gtk.Editable)focus);
//~             }
//~             else
//~             {
//~                 Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~                 if (files)
//~                 {
//~                     fm_clipboard_cut_files (win, files);
//~                     fm_list_unref (files);
//~                 }
//~             }
        }

        private void _on_copy (Gtk.Action act) {

//~             Gtk.Widget focus = gtk_window_get_focus ( (Gtk.Window)win);
//~             if (GTK_IS_EDITABLE (focus) &&
//~                gtk_editable_get_selection_bounds ( (Gtk.Editable)focus, null, null) )
//~             {
//~                 gtk_editable_copy_clipboard ( (Gtk.Editable)focus);
//~             }
//~             else
//~             {
//~                 Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~                 if (files)
//~                 {
//~                     fm_clipboard_copy_files (win, files);
//~                     fm_list_unref (files);
//~                 }
//~             }
        }

        private void _on_paste (Gtk.Action act) {

//~             Gtk.Widget focus = gtk_window_get_focus ( (Gtk.Window)win);
//~             if (GTK_IS_EDITABLE (focus) )
//~             {
//~                 gtk_editable_paste_clipboard ( (Gtk.Editable)focus);
//~             }
//~             else
//~             {
//~                 Fm.Path path = fm_folder_view_get_cwd (FM_FOLDER_VIEW (win->folder_view));
//~                 fm_clipboard_paste_files (win->folder_view, path);
//~             }
        }

        private void _on_del (Gtk.Action act) {

//~             Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~             fm_trash_or_delete_files (GTK_WINDOW (win), files);
//~             fm_list_unref (files);
        }

        private void _on_rename (Gtk.Action act) {

//~             Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~             if ( !fm_list_is_empty (files) )
//~             {
//~                 fm_rename_file (GTK_WINDOW (win), fm_list_peek_head (files));
//~                 // FIXME_pcm: is it ok to only rename the first selected file here. 
//~             }
//~             fm_list_unref (files);
        }
        
        private void _on_move_to (Gtk.Action act) {

//~             Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~             if (files)
//~             {
//~                 fm_move_files_to (win, files);
//~                 fm_list_unref (files);
//~             }
        }
        
        private void _on_copy_to (Gtk.Action act) {

//~             Fm.PathList files = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~             if (files)
//~             {
//~                 fm_copy_files_to (win, files);
//~                 fm_list_unref (files);
//~             }
        }

        private void _on_select_all (Gtk.Action act) {

//~             fm_folder_view_select_all (FM_FOLDER_VIEW (win->folder_view));
        }

        private void _on_invert_select (Gtk.Action act) {

//~             fm_folder_view_select_invert (FM_FOLDER_VIEW (win->folder_view));
        }




        private void _on_go_back (Gtk.Action act) {

            /*if (fm_nav_history_get_can_back (win->nav_history))
            {
                FmNavHistoryItem* item;
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_back (win->nav_history, scroll_pos);
                item = fm_nav_history_get_cur (win->nav_history);
                
                // FIXME_pcm: should this be driven by a signal emitted on FmNavHistory? 
                chdir_without_history (win, item->path);
            }*/
        }

        private void _on_go_forward (Gtk.Action act) {

            /*if (fm_nav_history_get_can_forward (win->nav_history))
            {
                FmNavHistoryItem* item;
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_forward (win->nav_history, scroll_pos);
                // FIXME_pcm: should this be driven by a signal emitted on FmNavHistory? 
                item = fm_nav_history_get_cur (win->nav_history);
                
                // FIXME_pcm: should this be driven by a signal emitted on FmNavHistory? 
                chdir_without_history (win, item->path);
            }*/
        }




        private void _on_go_up (Gtk.Action act) {

//~             Fm.Path parent = fm_path_get_parent (fm_folder_view_get_cwd (FM_FOLDER_VIEW (win->folder_view)));
//~             if (parent)
//~                 chdir ( win, parent);
        }

        private void _on_go_home (Gtk.Action act) {

//~             chdir_by_name ( win, g_get_home_dir ());
        }

        private void _on_go_desktop (Gtk.Action act) {

//~             chdir_by_name ( win, g_get_user_special_dir (G_USER_DIRECTORY_DESKTOP));
        }

        private void _on_go_computer (Gtk.Action act) {

//~             chdir_by_name ( win, "computer:///");
        }
        private void _on_go_trash (Gtk.Action act) {

//~             chdir_by_name ( win, "trash:///");
        }


        private void _on_go_network (Gtk.Action act) {

//~             chdir_by_name ( win, "network:///");
        }

        private void _on_go_apps (Gtk.Action act) {

//~             chdir (win, fm_path_get_apps_menu ());
        }
        private void _on_go (Gtk.Action act) {

//~             chdir_by_name ( win, gtk_entry_get_text (GTK_ENTRY (win->location)));
        }

        private void _on_about (Gtk.Action act) {

//~             const string authors[]={"Axel FILMORE <axel.filmore@gmail.com>", null};
//~             Gtk.Widget dlg = gtk_about_dialog_new ();
//~             gtk_about_dialog_set_program_name (GTK_ABOUT_DIALOG (dlg), "lxmanager");
//~             gtk_about_dialog_set_authors (GTK_ABOUT_DIALOG (dlg), authors);
//~             gtk_about_dialog_set_comments (GTK_ABOUT_DIALOG (dlg), "A Simple File Manager");
//~             gtk_about_dialog_set_website (GTK_ABOUT_DIALOG (dlg), "https://github.com/afilmore/lxmanager");
//~             gtk_dialog_run (GTK_DIALOG (dlg));
//~             gtk_widget_destroy (dlg);
        }


        private void _on_location (Gtk.Action act) {

//~             gtk_widget_grab_focus (win->location);
        }

        private void _on_prop (Gtk.Action action) {

//~             Fm.FolderView fv = FM_FOLDER_VIEW (win->folder_view);
//~             // FIXME_pcm: should prevent directly accessing data members 
//~             Fm.FileInfo fi = FM_FOLDER_MODEL (fv->model)->dir->dir_fi;
//~             Fm.FileInfoList files = fm_file_info_list_new ();
//~             fm_list_push_tail (files, fi);
//~             fm_show_file_properties (GTK_WINDOW (win), files);
//~             fm_list_unref (files);
        }





        private void _on_show_hidden (Gtk.Action act) {

//~             bool active = gtk_toggle_action_get_active (act);
//~             fm_folder_view_set_show_hidden ( FM_FOLDER_VIEW (win->folder_view), active );
//~             update_statusbar (win);
        }

        private void _on_change_mode (Gtk.Action act, Gtk.Action cur) {

//~             int mode = gtk_radio_action_get_current_value (cur);
//~             fm_folder_view_set_mode ( FM_FOLDER_VIEW (win->folder_view), mode );
        }

        private void _on_sort_by (Gtk.Action act, Gtk.Action cur) {

//~             int val = gtk_radio_action_get_current_value (cur);
//~             fm_folder_view_sort (FM_FOLDER_VIEW (win->folder_view), -1, val);
        }

        private void _on_sort_type (Gtk.Action act, Gtk.Action cur) {

//~             int val = gtk_radio_action_get_current_value (cur);
//~             fm_folder_view_sort (FM_FOLDER_VIEW (win->folder_view), val, -1);
        }




        private void _on_open_in_new_win (Gtk.Action act) {

//~             Fm.PathList sels = fm_folder_view_get_selected_file_paths (FM_FOLDER_VIEW (win->folder_view));
//~             GList l;
//~             for ( l = fm_list_peek_head_link (sels); l; l=l->next )
//~             {
//~                 Fm.Path path =  (Fm.Path)l->data;
//~                 win = new ();
//~                 gtk_window_set_default_size (GTK_WINDOW (win), 640, 480);
//~                 chdir (win, path);
//~                 gtk_window_present (GTK_WINDOW (win));
//~             }
//~             fm_list_unref (sels);
        }


    }
}


