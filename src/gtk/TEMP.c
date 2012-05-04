fm-dir-tree-model.c
//static GtkTreePath *fm_dir_tree_model_get_path (GtkTreeModel *tree_model, GtkTreeIter *iter);

// unused...
#if 0
static void item_show_hidden_children (FmDirTreeModel* model, GList* item_l, gboolean show_hidden)
{
    FmDirTreeItem* item = (FmDirTreeItem*)item_l->data;
//    GList* child_l;
    /* TODO: show hidden items */
    if (show_hidden)
    {
        while (item->hidden_children)
        {

        }
    }
    else
    {
        while (item->children)
        {

        }
    }
}
#endif


#if 0

/* TODO: check if dirs contain sub dir in another thread and make
 * the tree nodes expandable when needed.
 *
 * NOTE: Doing this can improve usability, but due to limitation of UNIX-
 * like systems, this can result in great waste of system resources.
 * This requires continuous monitoring of every dir listed in the tree.
 * With Linux, inotify supports this well, and GFileMonitor uses inotify.
 * However, in other UNIX-like systems, monitoring a file uses a file
 * descriptor. So the max number of files which can be monitored is limited
 * by number available file descriptors. This may potentially use up
 * all available file descriptors in the process when there are many
 * directories expanded in the dir tree.
 * So, after considering and experimenting with this, we decided not to
 * support this feature.
 **/

static gboolean subdir_check_finish (FmDirTreeModel* model)
{
    model->current_subdir_check = NULL;
    if (g_queue_is_empty (&model->subdir_checks))
    {
        model->job_running = FALSE;
        g_debug ("all subdir checks are finished!");
        return FALSE;
    }
    else /* still has queued items */
    {
        if (g_cancellable_is_cancelled (model->subdir_cancellable))
            g_cancellable_reset (model->subdir_cancellable);
    }
    return TRUE;
}

static gboolean subdir_check_finish_has_subdir (FmDirTreeModel* model)
{
    GList* item_l = model->current_subdir_check;
    if (!g_cancellable_is_cancelled (model->subdir_cancellable) && item_l)
    {
        GtkTreeIter it;
        FmDirTreeItem* item = (FmDirTreeItem*)item_l->data;
        GtkTreePath* tp = item_to_tree_path (model, item_l);
        add_place_holder_child_item (model, item_l, tp, TRUE);
        gtk_tree_path_free (tp);
        g_debug ("finished for item with subdir: %s", fm_file_info_get_disp_name (item->fi));
    }
    return subdir_check_finish (model);
}

static gboolean subdir_check_finish_no_subdir (FmDirTreeModel* model)
{
    GList* item_l = model->current_subdir_check;
    if (!g_cancellable_is_cancelled (model->subdir_cancellable) && item_l)
    {
        GtkTreeIter it;
        FmDirTreeItem* item = (FmDirTreeItem*)item_l->data;
        if (item->children) /* remove existing subdirs or place holder item if needed. */
        {
            GtkTreePath* tp = item_to_tree_path (model, item_l);
            remove_all_children (model, item_l, tp);
            gtk_tree_path_free (tp);
            g_debug ("finished for item with no subdir: %s", fm_file_info_get_disp_name (item->fi));
        }
    }
    return subdir_check_finish (model);
}

static gboolean subdir_check_job (GIOSchedulerJob *job, GCancellable* cancellable, gpointer user_data)
{
    FmDirTreeModel* model = FM_DIR_TREE_MODEL (user_data);
    GList* item_l;
    FmDirTreeItem* item;
    GFile* gf;
    GFileEnumerator* enu;
    gboolean has_subdir = FALSE;

    g_mutex_lock (model->subdir_checks_mutex);
    item_l = (GList*)g_queue_pop_head (&model->subdir_checks);
    item = (FmDirTreeItem*)item_l->data;
    model->current_subdir_check = item_l;
    /* check if this item has subdir */
    gf = fm_path_to_gfile (item->fi->path);
    g_mutex_unlock (model->subdir_checks_mutex);
    g_debug ("check subdir for: %s", g_file_get_parse_name (gf));
    enu = g_file_enumerate_children (gf,
                            G_FILE_ATTRIBUTE_STANDARD_NAME","
                            G_FILE_ATTRIBUTE_STANDARD_TYPE","
                            G_FILE_ATTRIBUTE_STANDARD_IS_HIDDEN,
                            0, cancellable, NULL);
    if (enu)
    {
        while (!g_cancellable_is_cancelled (cancellable))
        {
            GFileInfo* fi = g_file_enumerator_next_file (enu, cancellable, NULL);
            if (G_LIKELY (fi))
            {
                GFileType type = g_file_info_get_file_type (fi);
                gboolean is_hidden = g_file_info_get_is_hidden (fi);
                g_object_unref (fi);

                if (type == G_FILE_TYPE_DIRECTORY)
                {
                    if (model->show_hidden || !is_hidden)
                    {
                        has_subdir = TRUE;
                        break;
                    }
                }
            }
            else
                break;
        }
        g_file_enumerator_close (enu, cancellable, cancellable);
        g_object_unref (enu);
    }
    g_debug ("check result - %s has_dir: %d", g_file_get_parse_name (gf), has_subdir);
    g_object_unref (gf);
    if (has_subdir)
        return g_io_scheduler_job_send_to_mainloop (job,
                        (GSourceFunc)subdir_check_finish_has_subdir,
                        model, NULL);

    return g_io_scheduler_job_send_to_mainloop (job,
                        (GSourceFunc)subdir_check_finish_no_subdir,
                        model, NULL);

}

static void item_queue_subdir_check (FmDirTreeModel* model, GList* item_l)
{
    FmDirTreeItem* item = (FmDirTreeItem*)item_l->data;
    g_return_if_fail (item->fi != NULL);

    g_mutex_lock (model->subdir_checks_mutex);
    g_queue_push_tail (&model->subdir_checks, item_l);
    g_debug ("queue subdir check for %s", fm_file_info_get_disp_name (item->fi));
    if (!model->job_running)
    {
        model->job_running = TRUE;
        model->current_subdir_check = (GList*)g_queue_peek_head (&model->subdir_checks);
        g_cancellable_reset (model->subdir_cancellable);
        g_io_scheduler_push_job (subdir_check_job,
                                g_object_ref (model),
                                (GDestroyNotify)g_object_unref,
                                G_PRIORITY_DEFAULT,
                                model->subdir_cancellable);
        g_debug ("push job");
    }
    g_mutex_unlock (model->subdir_checks_mutex);
}

#endif





