/***********************************************************************************************************************
 * DesktopSettingsDialog.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This software is an experimental fork of PcManFm originally written by Hong Jen Yee aka PCMan for LXDE project.
 * 
 * Purpose: 
 * 
 * 
 **********************************************************************************************************************/

#define INIT_BOOL(b, st, name, changed_notify)  init_bool(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_COMBO(b, st, name, changed_notify) init_combo(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_ICON_SIZES(b, name) init_icon_sizes(b, #name, G_STRUCT_OFFSET(FmConfig, name))
#define INIT_COLOR(b, st, name, changed_notify)  init_color(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_SPIN(b, st, name, changed_notify)  init_spin(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)
#define INIT_ENTRY(b, st, name, changed_notify)  init_entry(b, #name, G_STRUCT_OFFSET(st, name), changed_notify)

static GtkWidget* pref_dlg = NULL;
static GtkWidget* notebook = NULL;
/*
static GtkWidget* icon_size_combo[3] = {0};
static GtkWidget* bookmark_combo = NULL
static GtkWidget* use_trash;
*/

static GtkWidget* desktop_pref_dlg = NULL;




Gtk.Widget item;
Gtk.Widget img_preview;
item = gtk_builder_get_object (builder, "wallpaper");

g_signal_connect (item, "file-set", G_CALLBACK(on_wallpaper_set), null);

img_preview = gtk_image_new ();

gtk_misc_set_alignment (GTK_MISC(img_preview), 0.5, 0.0);

gtk_widget_set_size_request ( img_preview, 128, 128 );

gtk_file_chooser_set_preview_widget ( (Gtk.FileChooser*)item, img_preview );

g_signal_connect ( item, "update-preview", G_CALLBACK(on_update_img_preview), img_preview );

if (app_config->wallpaper)
    gtk_file_chooser_set_filename (GTK_FILE_CHOOSER(item), app_config->wallpaper);

INIT_COMBO (builder, FmAppConfig, wallpaper_mode, "wallpaper");
INIT_COLOR (builder, FmAppConfig, desktop_bg, "wallpaper");

INIT_COLOR (builder, FmAppConfig, desktop_fg, "desktop_text");
INIT_COLOR (builder, FmAppConfig, desktop_shadow, "desktop_text");

INIT_BOOL (builder, FmAppConfig, show_wm_menu, null);

item = gtk_builder_get_object (builder, "desktop_font");
if (app_config->desktop_font)
    gtk_font_button_set_font_name (GTK_FONT_BUTTON(item), app_config->desktop_font);

g_signal_connect (item, "font-set", G_CALLBACK(on_desktop_font_set), null);

g_signal_connect (desktop_pref_dlg, "response", G_CALLBACK(on_response), &desktop_pref_dlg);
g_object_unref (builder);

pcmanfm_ref ();
g_signal_connect (desktop_pref_dlg, "destroy", G_CALLBACK(pcmanfm_unref), null);







g_signal_connect (item, "file-set",             G_CALLBACK(on_wallpaper_set), null);
g_signal_connect ( item, "update-preview",      G_CALLBACK(on_update_img_preview), img_preview );
g_signal_connect (item, "font-set",             G_CALLBACK(on_desktop_font_set), null);

g_signal_connect (desktop_pref_dlg, "response", G_CALLBACK(on_response), &desktop_pref_dlg);
g_signal_connect (desktop_pref_dlg, "destroy",  G_CALLBACK(pcmanfm_unref), null);



static void on_update_img_preview( GtkFileChooser *chooser, GtkImage* img )
{
    char* file = gtk_file_chooser_get_preview_filename( chooser );
    GdkPixbuf* pix = NULL;
    if( file )
    {
        pix = gdk_pixbuf_new_from_file_at_scale( file, 128, 128, TRUE, NULL );
        g_free( file );
    }
    if( pix )
    {
        gtk_file_chooser_set_preview_widget_active(chooser, TRUE);
        gtk_image_set_from_pixbuf( img, pix );
        g_object_unref( pix );
    }
    else
    {
        gtk_image_clear( img );
        gtk_file_chooser_set_preview_widget_active(chooser, FALSE);
    }
}

static void on_desktop_font_set(GtkFontButton* btn, gpointer user_data)
{
    const char* font = gtk_font_button_get_font_name(btn);
    if(font)
    {
        g_free(app_config->desktop_font);
        app_config->desktop_font = g_strdup(font);
        fm_config_emit_changed(fm_config, "desktop_font");
    }
}

static void on_response(GtkDialog* dlg, int res, GtkWidget** pdlg)
{
    gtk_widget_destroy(GTK_WIDGET(dlg));
    *pdlg = NULL;
    pcmanfm_save_config(TRUE);
}








static void on_icon_size_changed(GtkComboBox* combo, gpointer _off)
{
    GtkTreeIter it;
    if(gtk_combo_box_get_active_iter(combo, &it))
    {
        gsize off = GPOINTER_TO_SIZE(_off);
        int* val = (int*)G_STRUCT_MEMBER_P(fm_config, off);
        int size;
        GtkTreeModel* model = gtk_combo_box_get_model(combo);
        gtk_tree_model_get(model, &it, 1, &size, -1);
        if(size != *val)
        {
            const char* name = gtk_buildable_get_name((GtkBuildable*)combo);
            *val = size;
            fm_config_emit_changed(fm_config, name);
        }
    }
}

static void init_icon_sizes(GtkBuilder* builder, const char* name, gsize off)
{
    GtkComboBox* combo = (GtkComboBox*)gtk_builder_get_object(builder, name);
    GtkTreeModel* model = gtk_combo_box_get_model(combo);
    GtkTreeIter it;
    int* val = (int*)G_STRUCT_MEMBER_P(fm_config, off);
    gtk_tree_model_get_iter_first(model, &it);
    gtk_combo_box_set_active_iter(combo, &it);
    do{
        int size;
        gtk_tree_model_get(model, &it, 1, &size, -1);
        if(size == *val)
        {
            gtk_combo_box_set_active_iter(combo, &it);
            break;
        }
    }while(gtk_tree_model_iter_next(model, &it));
    g_signal_connect(combo, "changed", G_CALLBACK(on_icon_size_changed), GSIZE_TO_POINTER(off));
}

static void on_combo_changed(GtkComboBox* combo, gpointer _off)
{
    gsize off = GPOINTER_TO_SIZE(_off);
    int* val = (int*)G_STRUCT_MEMBER_P(fm_config, off);
    int sel = gtk_combo_box_get_active(combo);
    if(sel != *val)
    {
        const char* name = g_object_get_data((GObject*)combo, "changed");
        if(!name)
            name = gtk_buildable_get_name((GtkBuildable*)combo);
        *val = sel;
        fm_config_emit_changed(fm_config, name);
    }
}

static void init_combo(GtkBuilder* builder, const char* name, gsize off, const char* changed_notify)
{
    GtkComboBox* combo = (GtkComboBox*)gtk_builder_get_object(builder, name);
    int* val = (int*)G_STRUCT_MEMBER_P(fm_config, off);
    if(changed_notify)
        g_object_set_data_full(G_OBJECT(combo), "changed", g_strdup(changed_notify), g_free);
    gtk_combo_box_set_active(combo, *val);
    g_signal_connect(combo, "changed", G_CALLBACK(on_combo_changed), GSIZE_TO_POINTER(off));
}

static void on_archiver_combo_changed(GtkComboBox* combo, gpointer user_data)
{
    GtkTreeModel* model = gtk_combo_box_get_model(combo);
    GtkTreeIter it;
    if(gtk_combo_box_get_active_iter(combo, &it))
    {
        FmArchiver* archiver;
        gtk_tree_model_get(model, &it, 1, &archiver, -1);
        if(archiver)
        {
            g_free(fm_config->archiver);
            fm_config->archiver = g_strdup(archiver->program);
            fm_archiver_set_default(archiver);
            fm_config_emit_changed(fm_config, "archiver");
        }
    }
}

/* archiver integration */
static void init_archiver_combo(GtkBuilder* builder)
{
    GtkListStore* model = gtk_list_store_new(2, G_TYPE_STRING, G_TYPE_POINTER);
    GtkComboBox* combo = (GtkComboBox*)gtk_builder_get_object(builder, "archiver");
    GtkTreeIter it;
    GList* archivers = fm_archiver_get_all();
    FmArchiver* default_archiver = fm_archiver_get_default();
    GList* l;

    gtk_combo_box_set_model(combo, GTK_TREE_MODEL(model));

    for(l = archivers; l; l=l->next)
    {
        FmArchiver* archiver = (FmArchiver*)l->data;
        gtk_list_store_insert_with_values(model, &it, -1,
                        0, archiver->program,
                        1, archiver, -1);
        if(archiver == default_archiver)
            gtk_combo_box_set_active_iter(combo, &it);
    }
    g_object_unref(model);
    g_signal_connect(combo, "changed", G_CALLBACK(on_archiver_combo_changed), NULL);
}

static void on_toggled(GtkToggleButton* btn, gpointer _off)
{
    gsize off = GPOINTER_TO_SIZE(_off);
    gboolean* val = (gboolean*)G_STRUCT_MEMBER_P(fm_config, off);
    gboolean new_val = gtk_toggle_button_get_active(btn);
    if(*val != new_val)
    {
        const char* name = g_object_get_data((GObject*)btn, "changed");
        if(!name)
            name = gtk_buildable_get_name((GtkBuildable*)btn);
        *val = new_val;
        fm_config_emit_changed(fm_config, name);
    }
}

static void init_bool(GtkBuilder* b, const char* name, gsize off, const char* changed_notify)
{
    GtkToggleButton* btn = GTK_TOGGLE_BUTTON(gtk_builder_get_object(b, name));
    gboolean* val = (gboolean*)G_STRUCT_MEMBER_P(fm_config, off);
    if(changed_notify)
        g_object_set_data_full(G_OBJECT(btn), "changed", g_strdup(changed_notify), g_free);
    gtk_toggle_button_set_active(btn, *val);
    g_signal_connect(btn, "toggled", G_CALLBACK(on_toggled), GSIZE_TO_POINTER(off));
}

static void on_color_set(GtkColorButton* btn, gpointer _off)
{
    gsize off = GPOINTER_TO_SIZE(_off);
    GdkColor* val = (GdkColor*)G_STRUCT_MEMBER_P(fm_config, off);
    GdkColor new_val;
    gtk_color_button_get_color(btn, &new_val);
    if( !gdk_color_equal(val, &new_val) )
    {
        const char* name = g_object_get_data((GObject*)btn, "changed");
        if(!name)
            name = gtk_buildable_get_name((GtkBuildable*)btn);
        *val = new_val;
        fm_config_emit_changed(fm_config, name);
    }
}

static void init_color(GtkBuilder* b, const char* name, gsize off, const char* changed_notify)
{
    GtkFontButton* btn = GTK_FONT_BUTTON(gtk_builder_get_object(b, name));
    GdkColor* val = (GdkColor*)G_STRUCT_MEMBER_P(fm_config, off);
    if(changed_notify)
        g_object_set_data_full(G_OBJECT(btn), "changed", g_strdup(changed_notify), g_free);
    gtk_color_button_set_color(GTK_COLOR_BUTTON(btn), val);
    g_signal_connect(btn, "color-set", G_CALLBACK(on_color_set), GSIZE_TO_POINTER(off));
}

static void on_spin_changed(GtkSpinButton* btn, gpointer _off)
{
    gsize off = GPOINTER_TO_SIZE(_off);
    guint* val = (guint*)G_STRUCT_MEMBER_P(fm_config, off);
    gboolean new_val = gtk_spin_button_get_value(btn);
    if(*val != new_val)
    {
        const char* name = g_object_get_data((GObject*)btn, "changed");
        if(!name)
            name = gtk_buildable_get_name((GtkBuildable*)btn);
        *val = new_val;
        fm_config_emit_changed(fm_config, name);
    }
}

static void init_spin(GtkBuilder* b, const char* name, gsize off, const char* changed_notify)
{
    GtkSpinButton* btn = GTK_SPIN_BUTTON(gtk_builder_get_object(b, name));
    guint* val = (guint*)G_STRUCT_MEMBER_P(fm_config, off);
    if(changed_notify)
        g_object_set_data_full(G_OBJECT(btn), "changed", g_strdup(changed_notify), g_free);
    gtk_spin_button_set_value(btn, *val);
    g_signal_connect(btn, "value-changed", G_CALLBACK(on_spin_changed), GSIZE_TO_POINTER(off));
}

static void on_entry_changed(GtkEntry* entry, gpointer _off)
{
    gsize off = GPOINTER_TO_SIZE(_off);
    gchar** val = (guint*)G_STRUCT_MEMBER_P(fm_config, off);
    const char* new_val = gtk_entry_get_text(entry);
    if(g_strcmp0(*val, new_val))
    {
        const char* name = g_object_get_data((GObject*)entry, "changed");
        if(!name)
            name = gtk_buildable_get_name((GtkBuildable*)entry);
        g_free(*val);
        *val = *new_val ? g_strdup(new_val) : NULL;
        fm_config_emit_changed(fm_config, name);
    }
}

static void init_entry(GtkBuilder* b, const char* name, gsize off, const char* changed_notify)
{
    GtkSpinButton* btn = GTK_SPIN_BUTTON(gtk_builder_get_object(b, name));
    gchar** val = (guint*)G_STRUCT_MEMBER_P(fm_config, off);
    if(changed_notify)
        g_object_set_data_full(G_OBJECT(btn), "changed", g_strdup(changed_notify), g_free);
    if(*val)
        gtk_entry_set_text(GTK_ENTRY(btn), *val);
    g_signal_connect(btn, "changed", G_CALLBACK(on_entry_changed), GSIZE_TO_POINTER(off));
}




