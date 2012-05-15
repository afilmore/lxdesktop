

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

private const string global_folder_menu_xml = """
    <popup>
    
      <placeholder name='ph1'>
        
        /* <menuitem action='NewTab'/> */
        <menuitem action='NewWin'/>
        /* <menuitem action='Search'/> */
        
      </placeholder>
    
    </popup>
""";


