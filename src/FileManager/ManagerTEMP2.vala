/***********************************************************************************************************************
 * TEMP.vala
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
 * Purpose: These are currently not translated to Vala, commented or simply unused functions. Most of these are empty
 * and useless but this file is included in the program and built with it. Some of these will never be used, but some
 * may be translated, adapted and moved into the application's classes.
 * 
 * 
 **********************************************************************************************************************/

        private void _on_go_back (Gtk.Action act) {

            /*if (fm_nav_history_get_can_back (win->nav_history))
            {
                FmNavHistoryItem* item;
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_back (win->nav_history, scroll_pos);
                item = fm_nav_history_get_cur (win->nav_history);
                
                // FIXME: should this be driven by a signal emitted on FmNavHistory? 
                chdir_without_history (win, item->path);
            }*/
        }

        private void _on_go_forward (Gtk.Action act) {

            /*if (fm_nav_history_get_can_forward (win->nav_history))
            {
                FmNavHistoryItem* item;
                int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (win->folder_view)));
                fm_nav_history_forward (win->nav_history, scroll_pos);
                // FIXME: should this be driven by a signal emitted on FmNavHistory? 
                item = fm_nav_history_get_cur (win->nav_history);
                
                // FIXME: should this be driven by a signal emitted on FmNavHistory? 
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


/***********************************************************************************************************************

    Not A source File, Just Studying LibFM's SidePane Widget :)


***********************************************************************************************************************/
struct _FmSidePane
{
    GtkVBox parent;
    FmPath* cwd;
    GtkWidget* scroll;
    GtkWidget* view;
};

FmPath* fm_side_pane_get_cwd(FmSidePane* sp);
void fm_side_pane_chdir(FmSidePane* sp, FmPath* path);

/**********************************************************************************************************************/
enum
{
    CHDIR,
    MODE_CHANGED,
    N_SIGNALS
};
static guint signals[N_SIGNALS];
static FmDirTreeModel* global_dir_tree_model = NULL;

static void fm_side_pane_init(FmSidePane *sp)
{
    //~ GtkActionGroup* act_grp = gtk_action_group_new("SidePane");
    //~ GtkWidget* hbox;
//~ 
    //~ gtk_action_group_set_translation_domain(act_grp, GETTEXT_PACKAGE);
    //~ sp->title_bar = gtk_hbox_new(FALSE, 0);
    //~ sp->menu_label = gtk_label_new("");
    //~ gtk_misc_set_alignment(GTK_MISC(sp->menu_label), 0.0, 0.5);
    //~ sp->menu_btn = gtk_button_new();
    //~ hbox = gtk_hbox_new(FALSE, 0);
    //~ gtk_box_pack_start(GTK_BOX(hbox), sp->menu_label, TRUE, TRUE, 0);
    //~ gtk_box_pack_start(GTK_BOX(hbox), gtk_arrow_new(GTK_ARROW_DOWN, GTK_SHADOW_NONE),
                       //~ FALSE, TRUE, 0);
    //~ gtk_container_add(GTK_CONTAINER(sp->menu_btn), hbox);
    //~ // gtk_widget_set_tooltip_text(sp->menu_btn, _(""));

    //~ g_signal_connect(sp->menu_btn, "clicked", G_CALLBACK(on_menu_btn_clicked), sp);
    //~ gtk_button_set_relief(GTK_BUTTON(sp->menu_btn), GTK_RELIEF_NONE);
    //~ gtk_box_pack_start(GTK_BOX(sp->title_bar), sp->menu_btn, TRUE, TRUE, 0);

    /* the drop down menu */
    //~ sp->ui = gtk_ui_manager_new();
    //~ gtk_ui_manager_add_ui_from_string(sp->ui, menu_xml, -1, NULL);
    //~ gtk_action_group_add_radio_actions(act_grp, menu_actions, G_N_ELEMENTS(menu_actions),
                                       //~ -1, G_CALLBACK(on_mode_changed), sp);
    //~ gtk_ui_manager_insert_action_group(sp->ui, act_grp, -1);
    //~ g_object_unref(act_grp);
    //~ sp->menu = gtk_ui_manager_get_widget(sp->ui, "/popup");





FmPath* fm_side_pane_get_cwd(FmSidePane* sp)
{
    return sp->cwd;
}

void fm_side_pane_chdir(FmSidePane* sp, FmPath* path)
{
    if(sp->cwd)
        fm_path_unref(sp->cwd);
    sp->cwd = fm_path_ref(path);

    fm_dir_tree_view_chdir(FM_DIR_TREE_VIEW(tree_view), path);
}


/**********************************************************************************************************************/

/* Adopted from gtk/gtkmenutoolbutton.c
 * Copyright (C) 2003 Ricardo Fernandez Pascual
 * Copyright (C) 2004 Paolo Borelli
 */
static void menu_position_func(GtkMenu *menu, int *x, int *y, gboolean *push_in, GtkButton *button)
{
    GtkWidget *widget = GTK_WIDGET(button);
    GtkRequisition req;
    GtkRequisition menu_req;
    GtkTextDirection direction;
    GdkRectangle monitor;
    gint monitor_num;
    GdkScreen *screen;

    gtk_widget_size_request (GTK_WIDGET (menu), &menu_req);
    direction = gtk_widget_get_direction (widget);

    /* make the menu as wide as the button when needed */
    if(menu_req.width < GTK_WIDGET(button)->allocation.width)
    {
        menu_req.width = GTK_WIDGET(button)->allocation.width;
        gtk_widget_set_size_request(GTK_WIDGET(menu), menu_req.width, -1);
    }

    screen = gtk_widget_get_screen (GTK_WIDGET (menu));
    monitor_num = gdk_screen_get_monitor_at_window (screen, widget->window);
    if (monitor_num < 0)
        monitor_num = 0;
    gdk_screen_get_monitor_geometry (screen, monitor_num, &monitor);

    gdk_window_get_origin (widget->window, x, y);
    *x += widget->allocation.x;
    *y += widget->allocation.y;
/*
    if (direction == GTK_TEXT_DIR_LTR)
        *x += MAX (widget->allocation.width - menu_req.width, 0);
    else if (menu_req.width > widget->allocation.width)
        *x -= menu_req.width - widget->allocation.width;
*/
    if ((*y + widget->allocation.height + menu_req.height) <= monitor.y + monitor.height)
        *y += widget->allocation.height;
    else if ((*y - menu_req.height) >= monitor.y)
        *y -= menu_req.height;
    else if (monitor.y + monitor.height - (*y + widget->allocation.height) > *y)
        *y += widget->allocation.height;
    else
        *y -= menu_req.height;
    *push_in = FALSE;
}
/**********************************************************************************************************************/


int main(int argc, char** argv)
{
	GtkWidget* w;
	gtk_init(&argc, &argv);

	fm_gtk_init(NULL);

    /* for debugging RTL */
    /* gtk_widget_set_default_direction(GTK_TEXT_DIR_RTL); */

	w = fm_main_win_new();
	gtk_window_set_default_size(GTK_WINDOW(w), 640, 480);
	gtk_widget_show(w);

    if(argc > 1)
    {
        FmPath* path = fm_path_new_for_str(argv[1]);
        fm_main_win_chdir(FM_MAIN_WIN(w), path);
        fm_path_unref(path);
    }

	gtk_main();

    fm_finalize();

	return 0;
}

/* ********************************************************************************************************************/
private void on_bookmark (GtkMenuItem* mi) {

    FmPath* path =  (FmPath*)g_object_get_data (G_OBJECT (mi), "path");
    chdir (win, path);
}

private void create_bookmarks_menu () {

    GList* l;
    int i = 0;
    // FIXME: direct access to data member is not allowed 
    for (l=win->bookmarks->items;l;l=l->next)
    {
        FmBookmarkItem* item =  (FmBookmarkItem*)l->data;
        GtkWidget* mi = gtk_image_menu_item_new_with_label (item->name);
        gtk_widget_show (mi);
        // gtk_image_menu_item_set_image (); // FIXME: set icons for menu items
        g_object_set_qdata_full (G_OBJECT (mi), fm_qdata_id, fm_path_ref (item->path),  (GDestroyNotify)fm_path_unref);
        g_signal_connect (mi, "activate", G_CALLBACK (on_bookmark), win);
        gtk_menu_shell_insert (GTK_MENU_SHELL (win->bookmarks_menu), mi, i);
        ++i;
    }
    if (i > 0)
        gtk_menu_shell_insert (GTK_MENU_SHELL (win->bookmarks_menu), gtk_separator_menu_item_new (), i);
}

private void on_bookmarks_changed (FmBookmarks* bm) {

    // delete old items first. 
    GList* mis = gtk_container_get_children (GTK_CONTAINER (win->bookmarks_menu));
    GList* l;
    for (l = mis;l;l=l->next)
    {
        GtkWidget* item =  (GtkWidget*)l->data;
        if ( GTK_IS_SEPARATOR_MENU_ITEM (item) )
            break;
        gtk_widget_destroy (item);
    }
    g_list_free (mis);

    create_bookmarks_menu (win);
}

private void load_bookmarks (, GtkUIManager* ui) {

    GtkWidget* mi = gtk_ui_manager_get_widget (ui, "/menubar/BookmarksMenu");
    win->bookmarks_menu = gtk_menu_item_get_submenu (GTK_MENU_ITEM (mi));
    win->bookmarks = fm_bookmarks_get ();
    g_signal_connect (win->bookmarks, "changed", G_CALLBACK (on_bookmarks_changed), win);

    create_bookmarks_menu (win);
}

private void on_history_item (GtkMenuItem* mi) {

    GList* l = g_object_get_qdata (G_OBJECT (mi), fm_qdata_id);
    const FmNavHistoryItem* item =  (FmNavHistoryItem*)l->data;
    int scroll_pos = gtk_adjustment_get_value (gtk_scrolled_window_get_vadjustment (GTK_SCROLLED_WINDOW (win->folder_view)));
    fm_nav_history_jump (win->nav_history, l, scroll_pos);
    item = fm_nav_history_get_cur (win->nav_history);
    
    // FIXME: should this be driven by a signal emitted on FmNavHistory? 
    chdir_without_history (win, item->path);
}

private void on_show_history_menu (GtkMenuToolButton* btn) {

    GtkMenuShell* menu =  (GtkMenuShell*)gtk_menu_tool_button_get_menu (btn);
    GList* l;
    GList* cur = fm_nav_history_get_cur_link (win->nav_history);

    // delete old items 
    gtk_container_foreach (GTK_CONTAINER (menu),  (GtkCallback)gtk_widget_destroy, NULL);

    for (l = fm_nav_history_list (win->nav_history); l; l=l->next)
    {
        const FmNavHistoryItem* item =  (FmNavHistoryItem*)l->data;
        FmPath* path = item->path;
        string str = fm_path_display_name (path, true);
        GtkMenuItem* mi;
        if ( l == cur )
        {
            mi = gtk_check_menu_item_new_with_label (str);
            gtk_check_menu_item_set_draw_as_radio (GTK_CHECK_MENU_ITEM (mi), true);
            gtk_check_menu_item_set_active (GTK_CHECK_MENU_ITEM (mi), true);
        }
        else
            mi = gtk_menu_item_new_with_label (str);
        g_free (str);

        g_object_set_qdata_full (G_OBJECT (mi), fm_qdata_id, l, NULL);
        g_signal_connect (mi, "activate", G_CALLBACK (on_history_item), win);
        gtk_menu_shell_append (menu, mi);
    }
    gtk_widget_show_all ( GTK_WIDGET (menu) );
}

void on_create_new (GtkAction* action) {

    FmFolderView* fv = FM_FOLDER_VIEW (win->folder_view);
    const string name = gtk_action_get_name (action);
    GError* err = NULL;
    FmPath* cwd = fm_folder_view_get_cwd (fv);
    FmPath* dest;
    string basename;
_retry:
    basename = fm_get_user_input (GTK_WINDOW (win), _ ("Create New..."), _ ("Enter a name for the newly created file:"), _ ("New"));
    if (!basename)
        return;

    dest = fm_path_new_child (cwd, basename);
    g_free (basename);

    if ( strcmp (name, "NewFolder") == 0 )
    {
        GFile* gf = fm_path_to_gfile (dest);
        if (!g_file_make_directory (gf, NULL, &err))
        {
            if (err->domain = G_IO_ERROR && err->code == G_IO_ERROR_EXISTS)
            {
                fm_path_unref (dest);
                g_error_free (err);
                g_object_unref (gf);
                err = NULL;
                goto _retry;
            }
            fm_show_error (GTK_WINDOW (win), NULL, err->message);
            g_error_free (err);
        }

        if (!err) // select the newly created file 
        {
            //FIXME: this doesn't work since the newly created file will
            // only be shown after file-created event was fired on its
            //folder's monitor and after FmFolder handles it in idle
            //handler. So, we cannot select it since it's not yet in
            //the folder model now. 
            // fm_folder_view_select_file_path (fv, dest); 
        }
        g_object_unref (gf);
    }
    else if ( strcmp (name, "NewBlank") == 0 )
    {
        GFile* gf = fm_path_to_gfile (dest);
        GFileOutputStream* f = g_file_create (gf, G_FILE_CREATE_NONE, NULL, &err);
        if (f)
        {
            g_output_stream_close (G_OUTPUT_STREAM (f), NULL, NULL);
            g_object_unref (f);
        }
        else
        {
            if (err->domain = G_IO_ERROR && err->code == G_IO_ERROR_EXISTS)
            {
                fm_path_unref (dest);
                g_error_free (err);
                g_object_unref (gf);
                err = NULL;
                goto _retry;
            }
            fm_show_error (GTK_WINDOW (win), NULL, err->message);
            g_error_free (err);
        }

        if (!err) // select the newly created file 
        {
            //FIXME: this doesn't work since the newly created file will
             // only be shown after file-created event was fired on its
             // folder's monitor and after FmFolder handles it in idle
             // handler. So, we cannot select it since it's not yet in
             // the folder model now. 
            // fm_folder_view_select_file_path (fv, dest); 
        }
        g_object_unref (gf);
    }
    else // templates 
    {

    }
    fm_path_unref (dest);
}



