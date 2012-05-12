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
    
    /**
    private const string global_folder_menu_xml = """
        <popup>
        
          <placeholder name='ph1'>
            
            <menuitem action='NewWin'/>
            
          </placeholder>
        
        </popup>
    """;
    **/
    
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
            {"Location2", null, null, "<Ctrl>L", null,                              _on_location}
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
            {"NewWin", Gtk.Stock.NEW, N_("Open in New Window"), null, null,         _on_open_in_new_win},
            {"Search", Gtk.Stock.FIND, null, null, null, null}
        };


        private void _on_new_win (Gtk.Action act) {

            /*** Duplicated Code with the function bellow... create a new function ***
            
            win = new ();
            gtk_window_set_default_size (GTK_WINDOW (win), 640, 480);
            chdir (win, fm_path_get_home ());
            gtk_window_present (GTK_WINDOW (win));
            ***/
        }

        /*********************************************************************************
         * Edit Menu...
         * 
         * 
         ********************************************************************************/
        private void _on_cut (Gtk.Action act) {

            /*** What's the purpose of this ??? ***
            Gtk.Widget focus = this.get_focus ();
            
            if (GTK_IS_EDITABLE (focus)
            && focus.get_selection_bounds (null, null)) {
                focus.cut_clipboard ();
            
            } else {
            ***/
                
                unowned Fm.PathList? files = _folder_view.get_selected_file_paths ();
                if (files != null) {
                    Fm.Clipboard.cut_files (this, files);
                }
                
            /***
            }
            ***/
        }

        private void _on_copy (Gtk.Action act) {

            /*** What's the purpose of this ??? ***
            Gtk.Widget focus = this.get_focus ();
            
            if (GTK_IS_EDITABLE (focus)
            && focus.get_selection_bounds (null, null)) {
                focus.cut_clipboard ();
            
            } else {
            ***/
                
                unowned Fm.PathList? files = _folder_view.get_selected_file_paths ();
                if (files != null) {
                    Fm.Clipboard.copy_files (this, files);
                }
                
            /***
            }
            ***/
        }

        private void _on_paste (Gtk.Action act) {

            /***
            
            Gtk.Widget focus = this.get_focus ();
            if (GTK_IS_EDITABLE (focus)) {
                focus.paste_clipboard ();
            } else {
            
            ***/
            
                Fm.Path path = _folder_view.get_cwd ();
                Fm.Clipboard.paste_files (_folder_view, path);
            
            /***
            }
            ***/
        }

        private void _on_del (Gtk.Action act) {

            unowned Fm.PathList files = _folder_view.get_selected_file_paths ();
            Fm.trash_or_delete_files (this, files);
        }

        private void _on_rename (Gtk.Action act) {

            /*Fm.PathList files = _folder_view.get_selected_file_paths ();
            if (!files.is_empty ()) {
                
                // Rename the first selected file...
                Fm.rename_file (this, ((Queue) files).head);
                
            }*/
        }
        
        private void _on_move_to (Gtk.Action act) {

            unowned Fm.PathList? files = _folder_view.get_selected_file_paths ();
            if (files != null) {
                Fm.move_files_to (this, files);
            }
        }
        
        private void _on_copy_to (Gtk.Action act) {

            unowned Fm.PathList? files = _folder_view.get_selected_file_paths ();
            if (files != null) {
                Fm.copy_files_to (this, files);
            }
        }

        private void _on_select_all (Gtk.Action act) {

            _folder_view.select_all ();
        }

        private void _on_invert_select (Gtk.Action act) {

            _folder_view.select_invert ();
        }


        /*********************************************************************************
         * Go Menu... Prev/Next/Up Toolbar buttons...
         * 
         * 
         ********************************************************************************/
        private void _on_go_back (Gtk.Action act) {

            /*** Not Implemented ***/
        }

        private void _on_go_forward (Gtk.Action act) {

            /*** Not Implemented ***/
        }

        private void _on_go_home (Gtk.Action act) {

            /***
            chdir_by_name ( win, g_get_home_dir ());
            ***/
        }

        private void _on_go_desktop (Gtk.Action act) {

            /***
            chdir_by_name ( win, g_get_user_special_dir (G_USER_DIRECTORY_DESKTOP));
            ***/
        }

        private void _on_go_computer (Gtk.Action act) {

            /***
            chdir_by_name ( win, "computer:///");
            ***/
        }
        private void _on_go_trash (Gtk.Action act) {

            /***
            chdir_by_name ( win, "trash:///");
            ***/
        }

        private void _on_go_network (Gtk.Action act) {

            /***
            chdir_by_name ( win, "network:///");
            ***/
        }

        private void _on_go_apps (Gtk.Action act) {

            /***
            chdir (win, fm_path_get_apps_menu ());
            ***/
        }
        private void _on_go (Gtk.Action act) {

            /***
            chdir_by_name ( win, gtk_entry_get_text (GTK_ENTRY (win->_path_entry)));
            ***/
        }








        /*********************************************************************************
         * File Menu...
         * 
         * 
         ********************************************************************************/
        private void _on_open_in_new_win (Gtk.Action act) {

            /*** From Popup Menu ***
            Fm.PathList sels = _folder_view.get_selected_file_paths ();
            GList l;
            for ( l = fm_list_peek_head_link (sels); l; l=l->next )
            {
                Fm.Path path =  (Fm.Path)l->data;
                
                // *** Duplicated Code ***
                win = new ();
                gtk_window_set_default_size (GTK_WINDOW (win), 640, 480);
                chdir (win, path);
                gtk_window_present (GTK_WINDOW (win));
                 
                
            }
            fm_list_unref (sels);
            ***/
        }
        
       /*********************************************************************************
         * View Menu...
         * 
         * 
         ********************************************************************************/
        private void _on_sort_type (Gtk.Action act, Gtk.Action cur) {
            /*
            int val = cur.get_current_value ();
            _folder_view.sort (val, -1);*/
        }
        
        private void _on_sort_by (Gtk.Action act, Gtk.Action cur) {

            /*int val = cur.get_current_value ();
            _folder_view.sort (-1, val);*/
        }

        private void _on_change_mode (Gtk.Action act, Gtk.Action cur) {

            /*int mode = cur.get_current_value ();
            _folder_view.set_mode (mode);*/
        }

        private void _on_show_hidden (Gtk.Action act) {
            
            /*bool active = cur.get_current_value ();
            _folder_view.set_show_hidden (active);
            this._update_statusbar ();*/
        }
        
        











        /*********************************************************************************
         * Popup Menu...
         * 
         * 
         ********************************************************************************/
        /*private void _on_properties (Gtk.Action action) {
            
            
            Fm.FileInfo fi = _folder_view.model.dir.dir_fi;
            
            Fm.FileInfoList files = new Fm.FileInfoList ();
            
            files.push_tail (fi);
            
            Fm.show_file_properties (files);
        }*/






