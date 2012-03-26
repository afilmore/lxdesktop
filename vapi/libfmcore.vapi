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
    
	[CCode (cprefix = "fm_", cheader_filename = "fmcore.h")]
	public static bool init ();
	
    [CCode (cprefix = "fm_", cheader_filename = "fmcore.h")]
	public static void finalize ();
	
    /*******************************************************************************************************************
     * LibFm Core objects.
     * 
     ******************************************************************************************************************/
	[CCode (ref_function = "fm_path_ref", unref_function = "fm_path_unref", cname = "FmPath", cprefix = "fm_path_", cheader_filename = "fm-path.h")]
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
		public static void finalize ();
		public unowned string get_desc ();
		public static unowned Fm.MimeType get_for_file_name (string ufile_name);
		public static unowned Fm.MimeType get_for_native_file (string file_path, string base_name, void* pstat);
		public static unowned Fm.MimeType get_for_type (string type);
		public unowned Fm.Icon get_icon ();
		public static void init ();
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
    
	[CCode (cheader_filename = "fm-file-info.h")]
	[Compact]
	public class FileInfoList {
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

