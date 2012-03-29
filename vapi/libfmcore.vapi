/***********************************************************************************************************************
 * libfmcore.vapi
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * Purpose: Binding file for lbfmcore.
 * 
 * 
 **********************************************************************************************************************/
namespace Fm {
    
    [CCode (cheader_filename = "fmcore.h", cprefix = "FM_WP_")]
    public enum WallpaperMode {
        COLOR,
        STRETCH,
        FIT,
        CENTER,
        TILE
    }

	[CCode (cheader_filename = "fmcore.h", cprefix = "fm_")]
	public static bool init ();
	
	[CCode (cheader_filename = "fmcore.h", cprefix = "fm_")]
	public static void finalize ();
	
    
	[CCode (cheader_filename = "fm-list.h", cprefix = "fm_", ref_function = "fm_list_ref", unref_function = "fm_list_unref")]
	[Compact]
	public class List {
		
        public weak Fm.ListFuncs funcs;
		public weak GLib.Queue list;
		public int n_ref;
		
        [CCode (has_construct_function = false)]
		public List (Fm.ListFuncs funcs);
		public static void clear (void* list);
		public static void delete_link (void* list, void* l_);
		public bool is_file_info_list ();
		public bool is_path_list ();
		public static void remove (void* list, void* data);
		public static void remove_all (void* list, void* data);
	}
	
    [CCode (cheader_filename = "fm-list.h")]
	[Compact]
	public class ListFuncs {
		public weak GLib.Callback item_ref;
		public weak GLib.Callback item_unref;
	}
	
    /*
    #define fm_drag_context_has_target(ctx, target) \
        (g_list_find(ctx->targets, target) != NULL)
    */
	[CCode (cheader_filename = "fm-dnd-dest.h", cprefix = "fm_")]
    public inline bool drag_context_has_target (Gdk.DragContext drag_context, Gdk.Atom target);

	[CCode (cheader_filename = "fm-dnd-dest.h", cprefix = "fm_")]
    extern Gtk.TargetEntry default_dnd_dest_targets[];

    /*
    #define fm_drag_context_has_target_name(ctx, name)  \
        fm_drag_context_has_target(ctx, gdk_atom_intern_static_string(name))
    */

    /* default droppable targets */
    //~ enum
    //~ {
    //~     FM_DND_DEST_TARGET_FM_LIST, /* direct pointer of FmList */
    //~     FM_DND_DEST_TARGET_URI_LIST, /* text/uri-list */
    //~     FM_DND_DEST_TARGET_XDS, /* X direct save */
    //~     N_FM_DND_DEST_DEFAULT_TARGETS
    //~ };

    [CCode (cheader_filename = "fm-dnd-dest.h", cprefix = "FM_DND_DEST_TARGET_")]
    public enum DndDestTarget {
        FM_LIST,
        URI_LIST,
        TARGET_XDS,
        [CCode (cheader_filename = "fm-dnd-dest.h", cname = "N_FM_DND_DEST_DEFAULT_TARGETS", cprefix = "")]
        DEFAULT
    }
    
    [CCode (cheader_filename = "fm-dnd-dest.h", cprefix = "fm_dnd_dest_", cname = "FmDndDest")]
	public class DndDest : GLib.Object {
		
        [CCode (has_construct_function = false)]
		public DndDest (Gtk.Widget w);
		
        public bool drag_data_received (Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData sel_data, uint info, uint time);
		public bool drag_drop (Gdk.DragContext drag_context, Gdk.Atom target, int x, int y, uint time);
		public void drag_leave (Gdk.DragContext drag_context, uint time);
		public Gdk.Atom find_target (Gdk.DragContext drag_context);
		public Gdk.DragAction get_default_action (Gdk.DragContext drag_context, Gdk.Atom target);
		public unowned Fm.FileInfo get_dest_file ();
		public unowned Fm.Path get_dest_path ();
		public unowned Fm.List get_src_files ();
		public bool is_target_supported (Gdk.Atom target);
		public void set_dest_file (Fm.FileInfo? dest_file);
		public void set_widget (Gtk.Widget w);
		public virtual signal bool files_dropped (int x, int y, uint action, uint info_type, void* files);
	}
	
    [CCode (cheader_filename = "fm-dnd-src.h", cprefix = "fm_dnd_src_", cname = "FmDndSrc")]
	public class DndSrc : GLib.Object {
		
        [CCode (has_construct_function = false)]
		public DndSrc (Gtk.Widget w);
		
        public unowned Fm.FileInfoList get_files ();
		public void set_file (Fm.FileInfo file);
		public void set_files (Fm.FileInfoList files);
		public void set_widget (Gtk.Widget w);
		public virtual signal void data_get ();
	}

    /*******************************************************************************************************************
     * LibFm Core Base Objects to handle paths, icons, mime types and file info.
     * 
     ******************************************************************************************************************/
	[CCode (cheader_filename = "fm-path.h", cname = "FmPath", cprefix = "fm_path_", ref_function = "fm_path_ref", unref_function = "fm_path_unref")]
	[Compact]
	public class Path {
		
        [CCode (has_construct_function = false)]
		public Path ();
		
        public Path.for_path (string path_name);
		public static unowned Fm.Path get_desktop ();
        
        public Path.child (Fm.Path parent, string basename);
		
        [CCode (has_construct_function = false)]
		public Path.child_len (Fm.Path parent, string basename, int name_len);
		public int depth ();
		
        public unowned string display_basename ();
		public unowned string display_name (bool human_readable);
		public bool equal (Fm.Path p2);
		public bool equal_str (string str, int n);
		
        [CCode (has_construct_function = false)]
		public Path.for_commandline_arg (string arg);
		
        [CCode (has_construct_function = false)]
		public Path.for_display_name (string path_name);
		
        [CCode (has_construct_function = false)]
		public Path.for_gfile (GLib.File gf);
		
        [CCode (has_construct_function = false)]
		public Path.for_str (string path_str);
		
        [CCode (has_construct_function = false)]
		public Path.for_uri (string uri);
		
        public static unowned Fm.Path get_apps_menu ();
		public unowned string get_basename ();
		public int get_flags ();
		public static unowned Fm.Path get_home ();
		public unowned Fm.Path get_parent ();
		public static unowned Fm.Path get_root ();
		public static unowned Fm.Path get_trash ();
		public bool has_prefix (Fm.Path prefix);
		public uint hash ();
		
        [CCode (has_construct_function = false)]
		public Path.relative (Fm.Path parent, string relative_path);
		public unowned GLib.File to_gfile ();
		public unowned string to_str ();
		public unowned string to_uri ();
	}

	[CCode (cheader_filename = "fm-icon.h", ref_function = "fm_icon_ref", unref_function = "fm_icon_unref")]
	[Compact]
	public class Icon {
		public static unowned Fm.Icon from_gicon (GLib.Icon gicon);
		public static unowned Fm.Icon from_name (string name);
		public unowned Gdk.Pixbuf get_pixbuf (int size);
		public void* get_user_data ();
		public void set_user_data (void* user_data);
		public static void set_user_data_destroy (GLib.DestroyNotify func);
		public static void unload_cache ();
		public static void unload_user_data_cache ();
	}

	[CCode (cheader_filename = "fm-mime-type.h", ref_function = "fm_mime_type_ref", unref_function = "fm_mime_type_unref")]
	[Compact]
	public class MimeType {
		
        [CCode (has_construct_function = false)]
		public MimeType (string type_name);
		
		public static void init ();
        public static void finalize ();
		
        public unowned string get_desc ();
		public static unowned Fm.MimeType get_for_file_name (string ufile_name);
		public static unowned Fm.MimeType get_for_native_file (string file_path, string base_name, void* pstat);
		public static unowned Fm.MimeType get_for_type (string type);
		public unowned Fm.Icon get_icon ();
	}

    [CCode (cheader_filename = "fm-file-info.h", ref_function = "fm_file_info_ref", unref_function = "fm_file_info_unref")]
	[Compact]
	public class FileInfo {
		
        [CCode (has_construct_function = false)]
		public FileInfo ();
		
        public bool can_thumbnail ();
		public void copy (Fm.FileInfo src);
		
        [CCode (has_construct_function = false)]
		public FileInfo.from_gfileinfo (Fm.Path path, GLib.FileInfo inf);
		
        public ulong get_atime ();
		public int64 get_blocks ();
		public unowned string get_collate_key ();
		public unowned string get_desc ();
		public unowned string get_disp_mtime ();
		public unowned string get_disp_name ();
		public unowned string get_disp_size ();
		public unowned Fm.MimeType get_mime_type ();
		public uint get_mode ();
		public ulong get_mtime ();
		public unowned string get_name ();
		public unowned Fm.Path get_path ();
		public int64 get_size ();
		public unowned string get_target ();
		public bool is_desktop_entry ();
		public bool is_dir ();
		public bool is_executable_type ();
		public bool is_hidden ();
		public bool is_image ();
		public bool is_mountable ();
		public bool is_shortcut ();
		public bool is_symlink ();
		public bool is_text ();
		public bool is_unknown_type ();
		public void set_disp_name (string name);
		public void set_from_gfileinfo (GLib.FileInfo inf);
		public void set_path (Fm.Path path);
	}
    
    
    /*******************************************************************************************************************
     * File Launcher functions.
     * 
     ******************************************************************************************************************/
	[CCode (cheader_filename = "fm-file-launcher.h", has_target = false)]
	public delegate bool LaunchFolderFunc (GLib.AppLaunchContext ctx, GLib.List folder_infos, void* user_data) throws GLib.Error;

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_file_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, Fm.FileInfo file_info, Fm.LaunchFolderFunc func, void* user_data);

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_files_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, GLib.List file_infos, Fm.LaunchFolderFunc func);

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_path_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, Fm.Path path, Fm.LaunchFolderFunc func);

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_paths_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, GLib.List paths, Fm.LaunchFolderFunc func);

	/*
    [CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_desktop_entry (GLib.AppLaunchContext ctx, string file_or_id, GLib.List uris, Fm.FileLauncher launcher);

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_files (GLib.AppLaunchContext ctx, GLib.List file_infos, Fm.FileLauncher launcher);

	[CCode (cprefix = "fm_", cheader_filename = "fm-gtk-file-launcher.h")]
	public static bool launch_paths (GLib.AppLaunchContext ctx, GLib.List paths, Fm.FileLauncher launcher);
    */
    

    
	[CCode (cheader_filename = "fm-file-info.h", cname = "FmFileInfoList", cprefix = "fm_file_info_list_")]
	[Compact]
	public class FileInfoList : Fm.List {
		[CCode (has_construct_function = false)]
		public FileInfoList ();
		[CCode (has_construct_function = false)]
		public FileInfoList.from_glist ();
		public bool is_same_fs ();
		public bool is_same_type ();
	}

    // Columns of folder view
    [CCode (cheader_filename = "fm-folder.h", cprefix = "COL_FILE_")]
    public enum FileColumn {
        GICON = 0,
        ICON,
        NAME,
        SIZE,
        DESC,
        PERM,
        OWNER,
        MTIME,
        INFO,
        [CCode (cheader_filename = "fm-folder.h", cprefix = "")]
        N_FOLDER_MODEL_COLS
    }

	[CCode (cheader_filename = "fm-folder.h")]
	public class Folder : GLib.Object {
		
		public weak Fm.FileInfo dir_fi;

        [CCode (has_construct_function = false)]
		protected Folder ();
		
        public static unowned Fm.Folder @get (Fm.Path path);
		public unowned Fm.FileInfo get_file_by_name (string name);
		public unowned Fm.FileInfoList get_files ();
		public bool get_filesystem_info (uint64 total_size, uint64 free_size);
		public static unowned Fm.Folder get_for_gfile (GLib.File gf);
		
        [CCode (has_construct_function = false)]
		public static unowned Fm.Folder get_for_path_name (string path);
		public static unowned Fm.Folder get_for_uri (string uri);
		
        public bool get_is_loaded ();
		public void query_filesystem_info ();
		public void reload ();
		public virtual signal void changed ();
		public virtual signal void content_changed ();
		public virtual signal int error (void* err, int severity);
		public virtual signal void files_added (void* files);
		public virtual signal void files_changed (void* files);
		public virtual signal void files_removed (void* files);
		public virtual signal void fs_info ();
		public virtual signal void loaded ();
		public virtual signal void removed ();
		public virtual signal void unmount ();
	}
    
    
    /*******************************************************************************************************************
     * LibFm Gtk Objects.
     * 
     ******************************************************************************************************************/
    [CCode (cheader_filename = "fm-folder-model.h")]
	public class FolderModel : GLib.Object, Gtk.TreeModel, Gtk.TreeSortable, Gtk.TreeDragSource, Gtk.TreeDragDest {

		public weak Fm.Folder dir;

		[CCode (has_construct_function = false)]
		public FolderModel (Fm.Folder dir, bool show_hidden);
		
        public void file_changed (Fm.FileInfo file);
		public void file_created (Fm.FileInfo file);
		public void file_deleted (Fm.FileInfo file);
		
        public bool find_iter_by_filename (Gtk.TreeIter it, string name);
		
        public void get_common_suffix_for_prefix (string prefix, GLib.Callback file_info_predicate, string common_suffix);
		
        public uint get_icon_size ();
		public bool get_is_loaded ();
		public bool get_show_hidden ();
		
        public void set_folder (Fm.Folder dir);
		public void set_icon_size (uint icon_size);
		public void set_show_hidden (bool show_hidden);
		
        public virtual signal void loaded ();
	}
}

