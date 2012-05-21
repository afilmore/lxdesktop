
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
      
      <menu action='ViewMenu'>
        <menuitem action='ShowHidden'/>
        <separator/>
        <menuitem action='IconView'/>
        <menuitem action='CompactView'/>
        <menuitem action='ThumbnailView'/>
        <menuitem action='ListView'/>
        <separator/>
        <menu action='Sort'>
          <menuitem action='Desc'/>
          <menuitem action='Asc'/>
          <separator/>
          <menuitem action='ByName'/>
          <menuitem action='ByMTime'/>
        </menu>
      </menu>
      
      <menu action='HelpMenu'>
        <menuitem action='About'/>
      </menu>
      
    </menubar>
    
    <toolbar>
        <toolitem action='New'/>
        <toolitem action='Prev'/>
        <toolitem action='Up'/>
        <toolitem action='Home'/>
        <toolitem action='Go'/>
    </toolbar>
    
    <popup>
      <menu action='CreateNew'>
        <menuitem action='NewFolder'/>
        <menuitem action='NewBlank'/>
      </menu>
      
      <separator/>
      
      <menuitem action='Paste'/>
      
      <menu action='Sort'>
        <menuitem action='Desc'/>
        <menuitem action='Asc'/>
        <separator/>
        <menuitem action='ByName'/>
        <menuitem action='ByMTime'/>
      </menu>
      
      <menuitem action='ShowHidden'/>
      
      <separator/>
      
      <menuitem action='Properties'/>
      
    </popup>
    
    <accelerator action='Location'/>
    <accelerator action='Location2'/>
""";


       
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
         * Folder View Signal and File Popup...
         * 
         * 
         ********************************************************************************/

        private void _folder_view_on_file_clicked (Fm.FolderViewClickType type, Fm.FileInfo? fi) {

            switch (type) {
                
                // Double click on an item in the Folder View...
                case Fm.FolderViewClickType.ACTIVATED: {
                    
                    if (fi == null)
                        return;
                    
                    string? target = fi.get_target ();
                    
                    // A directory...
                    if (fi.is_dir ()) {
                        
                        // FIXME_axl: doesn't work with DirChangeCaller.FOLDER_VIEW...
                        this._change_directory (fi.get_path (), DirChangeCaller.NONE);
                             
                    } else if (fi.is_mountable ()) {
                        
                        if (target == null) {
                        
                            stdout.printf ("mountable = null !!!!\n");
                            
                            Desktop.global_volume_monitor.test (this, fi);
                            
                            /*
                            GFile* gf;
                            Mount mnt = Volume.get_mount (item->vol);
                            if(!mnt)
                            {
                                GtkWindow* parent = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
                                if(!fm_mount_volume(parent, item->vol, TRUE))
                                    return;
                                mnt = g_volume_get_mount(item->vol);
                                if(!mnt)
                                {
                                    g_debug("GMount is invalid after successful g_volume_mount().\nThis is quite possibly a gvfs bug.\nSee https://bugzilla.gnome.org/show_bug.cgi?id=552168");
                                    return;
                                }
                            }
                            gf = g_mount_get_root(mnt);
                            g_object_unref(mnt);
                            if(gf)
                            {
                                path = fm_path_new_for_gfile(gf);
                                g_object_unref(gf);
                            }
                            else
                                path = NULL;
                            */

                        } else {
                        
                            //stdout.printf ("target = %s\n", target);
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
                        
                        /**Fm.FileInfoList files = _folder_view.get_selected_files ();
                        _file_menu = new Fm.FileMenu.for_files (this, files, _folder_view.get_cwd (), false);

                         Merge Specific Folder Menu Items...
                        if (_file_menu.is_single_file_type () && fi.is_dir ()) {
                            Gtk.UIManager ui = _file_menu.get_ui ();
                            Gtk.ActionGroup action_group = _file_menu.get_action_group ();
                            action_group.add_actions (_folder_menu_actions, null);
                            try {
                                ui.add_ui_from_string (global_folder_menu_xml, -1);
                            } catch (Error e) {
                            }
                        }

                        _files_popup = _file_menu.get_menu ();
                        _files_popup.popup (null, null, null, 3, Gtk.get_current_event_time ());
                        **/
                    
                    
                    
                        if (_file_popup == null)
                            _file_popup = new Desktop.FilePopup ();
                        
                        Fm.FileInfoList<Fm.FileInfo>? files = _current_folder_view.get_selected_files ();
                        if (files == null)
                            return;
                        
                        Gtk.Menu menu = _file_popup.get_menu ((Gtk.Widget) this, _current_folder_view.get_cwd (), files, null);
                        
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
         * File Popup...
         * 
         * 
         ********************************************************************************/
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
                unowned Fm.FileInfo? file_info;
                global_dir_tree_model.get (it, 2, out file_info, -1);
                if (file_info == null)
                    return true;
                    
                /** stdout.printf ("%s\n", fi.get_disp_name ());
                
                _file_menu = new Fm.FileMenu.for_file (this, fi, _tree_view.get_cwd (), false);

                 Merge Specific Folder Menu Items...
                if (_file_menu.is_single_file_type () && fi.is_dir ()) {
                    Gtk.UIManager ui = _file_menu.get_ui ();
                    Gtk.ActionGroup action_group = _file_menu.get_action_group ();
                    action_group.add_actions (_folder_menu_actions, null);
                    try {
                        ui.add_ui_from_string (global_folder_menu_xml, -1);
                    } catch (Error e) {
                    }
                }

                _files_popup = _file_menu.get_menu ();
                _files_popup.popup (null, null, null, 3, Gtk.get_current_event_time ());
                
                **/
                
                if (_file_popup == null)
                    _file_popup = new Desktop.FilePopup ();
                
                Fm.FileInfoList<Fm.FileInfo> files = new Fm.FileInfoList<Fm.FileInfo> ();
                
                files.push_tail (file_info);
                
                Gtk.Menu menu = _file_popup.get_menu ((Gtk.Widget) this, _current_folder_view.get_cwd (), files, null);
                
                if (menu != null)
                    menu.popup (null, null, null, 3, Gtk.get_current_event_time ());
            }
            return true;
        }
















/***
 * 
 * These are currently not translated to Vala, commented or simply unused functions. Most of these are empty
 * and useless but this file is included in the program and built with it. Some of these will never be used, but some
 * may be translated, adapted and moved into the application's classes.
 * 
 * 
 ***/

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

    private void _folder_view_on_view_loaded (Fm.Path path) {

        /***const FmNavHistoryItem item;
         =  (FmMainWin)user_data;
        Fm.PathEntry entry = FM_PATH_ENTRY (win->location);

        fm_path_entry_set_path ( entry, path );

        // scroll to recorded position 
        item = fm_nav_history_get_cur (win->nav_history);
        gtk_adjustment_set_value ( gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (view)), item->scroll_pos);

        // update status bar 
        this._update_statusbar ();***/
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
    

