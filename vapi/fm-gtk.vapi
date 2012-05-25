/***********************************************************************************************************************
 * fm-gtk.vapi
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * Purpose: Binding file for Gtk Views.
 * 
 * Version: 0.2
 * 
 * 
 **********************************************************************************************************************/
namespace Fm {
	
    
    [CCode (cheader_filename = "Desktop/background.h", cprefix = "FM_WP_")]
    public enum WallpaperMode {
        COLOR,
        STRETCH,
        FIT,
        CENTER,
        TILE
    }
    
    
    /*************************************************************************************
     * Pixbuf Renderer...
     * 
     * 
     ************************************************************************************/
	[CCode (cheader_filename = "gtk/fm-cell-renderer-pixbuf.h")]
	public class CellRendererPixbuf : Gtk.CellRendererPixbuf {
		
        [CCode (has_construct_function = false, type = "GtkCellRenderer*")]
		public CellRendererPixbuf ();
		
        public void set_fixed_size (int w, int h);
		
        [NoAccessorMethod]
		public void *info { get; set; }
	}


    /*************************************************************************************
     * Fm.PathEntry
     * 
     * 
     ************************************************************************************/
	[CCode (cheader_filename = "gtk/fm-path-entry.h")]
	public class PathEntry : Gtk.Entry, Atk.Implementor, Gtk.Buildable, Gtk.Editable, Gtk.CellEditable {
		
        [CCode (has_construct_function = false, type = "GtkWidget*")]
		public PathEntry ();
		
        public unowned Fm.Path get_path ();
		public void set_path (Fm.Path path);
		
        [NoAccessorMethod]
		public bool highlight_completion_match { get; set; }
	}


    /*************************************************************************************
     * Fm.DirTreeView
     * 
     * 
     ************************************************************************************/
	[CCode (cheader_filename = "gtk/fm-dir-tree-model.h")]
	public class DirTreeModel : GLib.Object, Gtk.TreeModel {
		
        [CCode (has_construct_function = false)]
		public DirTreeModel ();
		
        public void add_root (Fm.FileInfo root, Gtk.TreeIter? it, bool expand = true);
		
        public void collapse_row (Gtk.TreeIter it, Gtk.TreePath tp);
		public void expand_row (Gtk.TreeIter it, Gtk.TreePath tp);
		
        public void set_show_hidden (bool show_hidden);
		public bool get_show_hidden ();
		
        public void set_icon_size (uint icon_size);
	}
	
    [CCode (cheader_filename = "gtk/fm-dir-tree-view.h")]
	public class DirTreeView : Gtk.TreeView, Atk.Implementor, Gtk.Buildable {
		
        [CCode (has_construct_function = false, type = "GObject*")]
		public DirTreeView ();
		
        public void chdir (Fm.Path path);
		public unowned Fm.Path get_cwd ();
        
		public virtual signal void directory_changed (uint button, Fm.Path path);
	}
    
    
    /*************************************************************************************
     * Fm.FolderView
     * 
     * 
     ************************************************************************************/
    [CCode (cheader_filename = "gtk/fm-folder-view.h", cprefix = "FM_FV_")]
    public enum FolderViewMode {
        ICON_VIEW,
        COMPACT_VIEW,
        THUMBNAIL_VIEW,
        LIST_VIEW
    }
    
    [CCode (cheader_filename = "gtk/fm-folder-view.h", cprefix = "FM_FV_")]
    public enum FolderViewClickType {
        CLICK_NONE,
        ACTIVATED,      /*** This can be triggered by both
                             left single or double click depending on
                             whether single-click activation is used or not. ***/
        MIDDLE_CLICK,
        CONTEXT_MENU
    }

	[CCode (cheader_filename = "gtk/fm-folder-view.h")]
	public class FolderView : Gtk.ScrolledWindow, Atk.Implementor, Gtk.Buildable {

		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public FolderView (int mode);
		
        public void set_mode (int mode);
		public int get_mode ();
		
        public bool chdir (Fm.Path path);
		public bool chdir_by_name (string path_str);
		
        public unowned Fm.Path get_cwd ();
		public unowned Fm.FileInfo get_cwd_info ();
		public unowned Fm.Folder get_folder ();
		
        public bool get_is_loaded ();
		public unowned Fm.FolderModel get_model ();
		
        public void set_selection_mode (Gtk.SelectionMode mode);
		public Gtk.SelectionMode get_selection_mode ();
		
		public void set_show_hidden (bool show);
        public bool get_show_hidden ();
		
        public int get_sort_by ();
		public Gtk.SortType get_sort_type ();
		public void sort (Gtk.SortType type, int by);
		
        public void select_all ();
		public void select_invert ();
		public void custom_select (GLib.Func filter);
		
        public void select_file_path (Fm.Path path);
		public void select_file_paths (Fm.PathList paths);
		public unowned Fm.PathList get_selected_file_paths ();
		public unowned Fm.FileInfoList get_selected_files ();
		
        [NoWrapper]
		public virtual void status (string msg);
		public virtual signal void directory_changed (Fm.Path dir_path);
		public virtual signal void clicked (Fm.FolderViewClickType type, Fm.FileInfo file);
		public virtual signal void loaded (Fm.Path path);
		public virtual signal void sel_changed (Fm.FileInfoList files);
		public virtual signal void sort_changed ();
	}
}


