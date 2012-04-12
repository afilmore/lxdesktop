/* fmcore.vapi generated by vapigen, do not modify. */

namespace Fm {
	[CCode (cheader_filename = "libfmcore.h")]
	public class CellRendererPixbuf : Gtk.CellRendererPixbuf {
		public weak Fm.FileInfo fi;
		public int fixed_h;
		public int fixed_w;
		[CCode (has_construct_function = false, type = "GtkCellRenderer*")]
		public CellRendererPixbuf ();
		public void set_fixed_size (int w, int h);
		[NoAccessorMethod]
		public void* info { get; set; }
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class Config : GLib.Object {
		public weak string archiver;
		public uint big_icon_size;
		public bool confirm_del;
		public uint pane_icon_size;
		public bool show_internal_volumes;
		public bool show_thumbnail;
		public bool si_unit;
		public bool single_click;
		public uint small_icon_size;
		public weak string terminal;
		public bool thumbnail_local;
		public uint thumbnail_max;
		public uint thumbnail_size;
		public bool use_trash;
		[CCode (has_construct_function = false)]
		public Config ();
		[NoWrapper]
		public virtual void changed ();
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class DeepCountJob : Fm.Job {
		public uint count;
		public int dest_dev;
		public weak string dest_fs_id;
		public int flags;
		public weak Fm.PathList paths;
		public int64 total_block_size;
		public int64 total_size;
		[CCode (has_construct_function = false, type = "FmJob*")]
		public DeepCountJob (Fm.PathList paths, int flags);
		public void set_dest (int dev, string fs_id);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class DirListJob : Fm.Job {
		public weak Fm.FileInfo dir_fi;
		public bool dir_only;
		public weak Fm.Path dir_path;
		public weak Fm.FileInfoList files;
		[CCode (has_construct_function = false, type = "FmJob*")]
		public DirListJob (Fm.Path path, bool dir_only);
		[CCode (has_construct_function = false, type = "FmJob*")]
		public DirListJob.for_gfile (GLib.File gf);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class DndDest : GLib.Object {
		[CCode (has_construct_function = false)]
		public DndDest (Gtk.Widget w);
		public bool drag_data_received (Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData sel_data, uint info, uint time);
		public bool drag_drop (Gdk.DragContext drag_context, Gdk.Atom target, int x, int y, uint time);
		public void drag_leave (Gdk.DragContext drag_context, uint time);
		public Gdk.Atom find_target (Gdk.DragContext drag_context);
		public Gdk.DragAction get_default_action (Gdk.DragContext drag_context, int target);
		public unowned Fm.FileInfo get_dest_file ();
		public unowned Fm.Path get_dest_path ();
		public unowned Fm.List get_src_files ();
		public bool is_target_supported (Gdk.Atom target);
		public void set_dest_file (Fm.FileInfo dest_file);
		public void set_widget (Gtk.Widget w);
		public virtual signal bool files_dropped (int x, int y, uint action, uint info_type, void* files);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class DndSrc : GLib.Object {
		public weak Fm.FileInfoList files;
		public weak Gtk.Widget widget;
		[CCode (has_construct_function = false)]
		public DndSrc (Gtk.Widget w);
		public unowned Fm.FileInfoList get_files ();
		public void set_file (Fm.FileInfo file);
		public void set_files (Fm.FileInfoList files);
		public void set_widget (Gtk.Widget w);
		public virtual signal void data_get ();
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class DummyMonitor : GLib.FileMonitor {
		[CCode (has_construct_function = false, type = "GFileMonitor*")]
		public DummyMonitor ();
	}
	[CCode (cheader_filename = "libfmcore.h", ref_function = "fm_file_info_ref", unref_function = "fm_file_info_unref")]
	[Compact]
	public class FileInfo {
		public void* (null);
		public ulong atime;
		public ulong blksize;
		public int64 blocks;
		public weak string collate_key;
		public weak string disp_mtime;
		public weak string disp_name;
		public weak string disp_size;
		public int gid;
		public weak Fm.Icon icon;
		public uint mode;
		public ulong mtime;
		public int n_ref;
		public weak Fm.Path path;
		public int64 size;
		public weak string target;
		public weak Fm.MimeType type;
		public int uid;
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
	[CCode (cheader_filename = "libfmcore.h")]
	public class FileInfoJob : Fm.Job {
		public weak Fm.Path current;
		public weak Fm.FileInfoList file_infos;
		public int flags;
		[CCode (has_construct_function = false, type = "FmJob*")]
		public FileInfoJob (Fm.PathList files_to_query, int flags);
		public void add (Fm.Path path);
		public void add_gfile (GLib.File gf);
		public unowned Fm.Path get_current ();
	}
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class FileInfoList {
		[CCode (has_construct_function = false)]
		public FileInfoList ();
		[CCode (has_construct_function = false)]
		public FileInfoList.from_glist ();
		public bool is_same_fs ();
		public bool is_same_type ();
	}
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class FileLauncher {
		public weak GLib.Callback ask;
		public weak GLib.Callback error;
		public weak GLib.Callback exec_file;
		public weak GLib.Callback get_app;
		public weak GLib.Callback open_folder;
	}
	[CCode (cheader_filename = "libfmcore.h", free_function = "fm_file_menu_destroy")]
	[Compact]
	public class FileMenu {
		public weak Gtk.ActionGroup act_grp;
		public bool all_trash;
		public bool all_virtual;
		public bool auto_destroy;
		public weak Fm.Path cwd;
		public weak Fm.FileInfoList file_infos;
		public weak Fm.LaunchFolderFunc folder_func;
		public void* folder_func_data;
		public weak Gtk.Widget menu;
		public weak Gtk.Window parent;
		public bool same_fs;
		public bool same_type;
		public weak Gtk.UIManager ui;
		[CCode (has_construct_function = false)]
		public FileMenu.for_file (Gtk.Window parent, Fm.FileInfo fi, Fm.Path cwd, bool auto_destroy);
		[CCode (has_construct_function = false)]
		public FileMenu.for_files (Gtk.Window parent, Fm.FileInfoList files, Fm.Path cwd, bool auto_destroy);
		public unowned Gtk.ActionGroup get_action_group ();
		public unowned Fm.FileInfoList get_file_info_list ();
		public unowned Gtk.Menu get_menu ();
		public unowned Gtk.UIManager get_ui ();
		public bool is_single_file_type ();
		public void set_folder_func (Fm.LaunchFolderFunc func);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class Folder : GLib.Object {
		public weak Fm.FileInfo dir_fi;
		public weak Fm.Path dir_path;
		public weak Fm.FileInfoList files;
		public weak GLib.SList files_to_add;
		public weak GLib.SList files_to_del;
		public weak GLib.SList files_to_update;
		public uint64 fs_free_size;
		public bool fs_info_not_avail;
		public weak GLib.Cancellable fs_size_cancellable;
		public uint64 fs_total_size;
		public weak GLib.File gf;
		public bool has_fs_info;
		public uint idle_handler;
		public weak Fm.DirListJob job;
		public weak GLib.FileMonitor mon;
		public weak GLib.SList pending_jobs;
		[CCode (has_construct_function = false)]
		protected Folder ();
		public static unowned Fm.Folder @get (Fm.Path path);
		public unowned Fm.FileInfo get_file_by_name (string name);
		public unowned Fm.FileInfoList get_files ();
		public bool get_filesystem_info (uint64 total_size, uint64 free_size);
		public static unowned Fm.Folder get_for_gfile (GLib.File gf);
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
	[CCode (cheader_filename = "libfmcore.h")]
	public class FolderModel : GLib.Object, Gtk.TreeModel, Gtk.TreeSortable, Gtk.TreeDragSource, Gtk.TreeDragDest {
		public weak Fm.Folder dir;
		public weak GLib.Sequence hidden;
		public uint icon_size;
		public weak GLib.Sequence items;
		public bool show_hidden;
		public int sort_col;
		public Gtk.SortType sort_order;
		public int stamp;
		public uint theme_change_handler;
		public uint thumbnail_max;
		public weak GLib.List thumbnail_requests;
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
	[CCode (cheader_filename = "libfmcore.h", ref_function = "fm_icon_ref", unref_function = "fm_icon_unref")]
	[Compact]
	public class Icon {
		public weak GLib.Icon gicon;
		public uint n_ref;
		public void* user_data;
		public static unowned Fm.Icon from_gicon (GLib.Icon gicon);
		public static unowned Fm.Icon from_name (string name);
		public unowned Gdk.Pixbuf get_pixbuf (int size);
		public void* get_user_data ();
		public void set_user_data (void* user_data);
		public static void set_user_data_destroy (GLib.DestroyNotify func);
		public static void unload_cache ();
		public static void unload_user_data_cache ();
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class Job : GLib.Object {
		public weak GLib.Cancellable cancellable;
		public weak GLib.Cond cond;
		public weak GLib.Mutex mutex;
		public bool running;
		[CCode (has_construct_function = false)]
		protected Job ();
		public int ask (string question);
		public int ask_valist (string question, void* options);
		public int askv (string question, out unowned string options);
		public void* call_main_thread (Fm.JobCallMainThreadFunc func);
		public virtual void cancel ();
		public void emit_cancelled ();
		public int emit_error (GLib.Error err, int severity);
		public void emit_finished ();
		public void finish ();
		public unowned GLib.Cancellable get_cancellable ();
		public void init_cancellable ();
		public bool is_cancelled ();
		public bool is_running ();
		[NoWrapper]
		public virtual bool run ();
		public virtual bool run_async ();
		public bool run_sync ();
		public bool run_sync_with_mainloop ();
		public void set_cancellable (GLib.Cancellable cancellable);
		public virtual signal int ask2 (void* question, void* options);
		public virtual signal void cancelled ();
		public virtual signal int error (void* err, int severity);
		public virtual signal void finished ();
	}
	[CCode (cheader_filename = "libfmcore.h", ref_function = "fm_list_ref", unref_function = "fm_list_unref")]
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
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class ListFuncs {
		public weak GLib.Callback item_ref;
		public weak GLib.Callback item_unref;
	}
	[CCode (cheader_filename = "libfmcore.h", ref_function = "fm_mime_type_ref", unref_function = "fm_mime_type_unref")]
	[Compact]
	public class MimeType {
		public weak string description;
		public weak Fm.Icon icon;
		public int n_ref;
		public weak string type;
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
	[CCode (cheader_filename = "libfmcore.h", ref_function = "fm_path_ref", unref_function = "fm_path_unref")]
	[Compact]
	public class Path {
		public uchar flags;
		public int n_ref;
		[CCode (array_length = false)]
		public weak GLib.ObjectPath[] name;
		public weak Fm.Path parent;
		[CCode (has_construct_function = false)]
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
		public Path.for_path (string path_name);
		[CCode (has_construct_function = false)]
		public Path.for_str (string path_str);
		[CCode (has_construct_function = false)]
		public Path.for_uri (string uri);
		public static unowned Fm.Path get_apps_menu ();
		public unowned string get_basename ();
		public static unowned Fm.Path get_desktop ();
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
	[CCode (cheader_filename = "libfmcore.h")]
	public class PathEntry : Gtk.Entry, Atk.Implementor, Gtk.Buildable, Gtk.Editable, Gtk.CellEditable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public PathEntry ();
		public unowned Fm.Path get_path ();
		public void set_path (Fm.Path path);
		[NoAccessorMethod]
		public bool highlight_completion_match { get; set; }
	}
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class PathList {
		[CCode (has_construct_function = false)]
		public PathList ();
		[CCode (has_construct_function = false)]
		public PathList.from_file_info_glist (GLib.List fis);
		[CCode (has_construct_function = false)]
		public PathList.from_file_info_gslist (GLib.SList fis);
		[CCode (has_construct_function = false)]
		public PathList.from_file_info_list (Fm.List fis);
		[CCode (has_construct_function = false)]
		public PathList.from_uri_list (string uri_list);
		[CCode (has_construct_function = false)]
		public PathList.from_uris (out unowned string uris);
		public unowned string to_uri_list ();
		public void write_uri_list (GLib.StringBuilder buf);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class ProgressDisplay {
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public class SimpleJob : Fm.Job {
		public weak GLib.DestroyNotify destroy_data;
		public weak Fm.SimpleJobFunc func;
		public void* user_data;
		[CCode (has_construct_function = false, type = "FmJob*")]
		public SimpleJob (Fm.SimpleJobFunc func, GLib.DestroyNotify destroy_data);
	}
	[CCode (cheader_filename = "libfmcore.h")]
	[Compact]
	public class ThumbnailRequest {
		public void cancel ();
		public unowned Fm.FileInfo get_file_info ();
		public unowned Gdk.Pixbuf get_pixbuf ();
		public uint get_size ();
	}
	[CCode (cheader_filename = "libfmcore.h", cprefix = "FM_WP_", has_type_id = false)]
	public enum WallpaperMode {
		COLOR,
		STRETCH,
		FIT,
		CENTER,
		TILE
	}
	[CCode (cheader_filename = "libfmcore.h")]
	public delegate void* JobCallMainThreadFunc (Fm.Job job);
	[CCode (cheader_filename = "libfmcore.h", has_target = false)]
	public delegate bool LaunchFolderFunc (GLib.AppLaunchContext ctx, GLib.List folder_infos, void* user_data) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h", has_target = false)]
	public delegate bool SimpleJobFunc (Fm.SimpleJob p1, void* p2);
	[CCode (cheader_filename = "libfmcore.h", has_target = false)]
	public delegate void ThumbnailReadyCallback (Fm.ThumbnailRequest p1, void* p2);
	[CCode (cheader_filename = "libfmcore.h")]
	public const int CONFIG_DEFAULT_BIG_ICON_SIZE;
	[CCode (cheader_filename = "libfmcore.h")]
	public const int CONFIG_DEFAULT_PANE_ICON_SIZE;
	[CCode (cheader_filename = "libfmcore.h")]
	public const int CONFIG_DEFAULT_SMALL_ICON_SIZE;
	[CCode (cheader_filename = "libfmcore.h")]
	public const int CONFIG_DEFAULT_THUMBNAIL_MAX;
	[CCode (cheader_filename = "libfmcore.h")]
	public const int CONFIG_DEFAULT_THUMBNAIL_SIZE;
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.List app_chooser_combo_box_get_custom_apps (Gtk.ComboBox combo);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.AppInfo app_chooser_combo_box_get_selected (Gtk.ComboBox combo, bool is_sel_changed);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void app_chooser_combo_box_setup (Gtk.ComboBox combo, Fm.MimeType mime_type, GLib.List apps, GLib.AppInfo sel);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.AppInfo app_chooser_dlg_get_selected_app (Gtk.Dialog dlg, bool set_default);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Gtk.Widget app_chooser_dlg_new (Fm.MimeType mime_type, bool can_set_default);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.AppInfo app_info_create_from_commandline (string commandline, string application_name, GLib.AppInfoCreateFlags flags) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool app_info_launch (GLib.AppInfo appinfo, GLib.List files, GLib.AppLaunchContext launch_context) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool app_info_launch_default_for_uri (string uri, GLib.AppLaunchContext launch_context) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool app_info_launch_uris (GLib.AppInfo appinfo, GLib.List uris, GLib.AppLaunchContext launch_context) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.AppInfo app_menu_view_get_selected_app (Gtk.TreeView view);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string app_menu_view_get_selected_app_desktop_file (Gtk.TreeView view);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string app_menu_view_get_selected_app_desktop_id (Gtk.TreeView view);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool app_menu_view_is_app_selected (Gtk.TreeView view);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool app_menu_view_is_item_app (Gtk.TreeView view, Gtk.TreeIter it);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Gtk.Widget app_menu_view_new ();
	[CCode (cheader_filename = "libfmcore.h")]
	public static int ask (Gtk.Window parent, string title, string question);
	[CCode (cheader_filename = "libfmcore.h")]
	public static int ask_valist (Gtk.Window parent, string title, string question, void* options);
	[CCode (cheader_filename = "libfmcore.h")]
	public static int askv (Gtk.Window parent, string title, string question, out unowned string options);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string canonicalize_filename (string filename, string cwd);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.AppInfo choose_app_for_mime_type (Gtk.Window parent, Fm.MimeType mime_type, bool can_set_default);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void copy_files (Gtk.Window parent, Fm.PathList files, Fm.Path dest_dir);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void delete_files (Gtk.Window parent, Fm.PathList files);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Fm.FileInfoList dir_dist_job_get_files (Fm.DirListJob job);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void dnd_set_dest_auto_scroll (Gtk.Widget drag_dest_widget, Gtk.Adjustment hadj, Gtk.Adjustment vadj);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void dnd_unset_dest_auto_scroll (Gtk.Widget drag_dest_widget);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool eject_mount (Gtk.Window parent, GLib.Mount mount, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool eject_volume (Gtk.Window parent, GLib.Volume vol, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void empty_trash (Gtk.Window parent);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Fm.ProgressDisplay file_ops_job_run_with_progress (Gtk.Window parent, int job);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string file_size_to_str (string buf, int64 size, bool si_prefix);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void finalize ();
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string get_user_input (Gtk.Window parent, string title, string msg, string default_text);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Fm.Path get_user_input_path (Gtk.Window parent, string title, string msg, Fm.Path default_path);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool init (Fm.Config config);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool key_file_get_bool (GLib.KeyFile kf, string grp, string key, bool val);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool key_file_get_int (GLib.KeyFile kf, string grp, string key, int val);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_desktop_entry (GLib.AppLaunchContext ctx, string file_or_id, GLib.List uris, Fm.FileLauncher launcher);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_file_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, Fm.FileInfo file_info, Fm.LaunchFolderFunc func);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_files (GLib.AppLaunchContext ctx, GLib.List file_infos, Fm.FileLauncher launcher);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_files_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, GLib.List file_infos, Fm.LaunchFolderFunc func);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_path_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, Fm.Path path, Fm.LaunchFolderFunc func);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_paths (GLib.AppLaunchContext ctx, GLib.List paths, Fm.FileLauncher launcher);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool launch_paths_simple (Gtk.Window parent, GLib.AppLaunchContext ctx, GLib.List paths, Fm.LaunchFolderFunc func);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void marshal_INT__POINTER_INT (GLib.Closure closure, GLib.Value return_value, uint n_param_values, GLib.Value param_values, void* invocation_hint, void* marshal_data);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void marshal_INT__POINTER_POINTER (GLib.Closure closure, GLib.Value return_value, uint n_param_values, GLib.Value param_values, void* invocation_hint, void* marshal_data);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void marshal_INT__POINTER_POINTER_POINTER (GLib.Closure closure, GLib.Value return_value, uint n_param_values, GLib.Value param_values, void* invocation_hint, void* marshal_data);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.FileMonitor monitor_directory (GLib.File gf) throws GLib.Error;
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.FileMonitor monitor_lookup_dummy_monitor (GLib.File gf);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned GLib.FileMonitor monitor_lookup_monitor (GLib.File gf);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool mount_path (Gtk.Window parent, Fm.Path path, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool mount_volume (Gtk.Window parent, GLib.Volume vol, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void move_files (Gtk.Window parent, Fm.PathList files, Fm.Path dest_dir);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void move_or_copy_files_to (Gtk.Window parent, Fm.PathList files, bool is_move);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool ok_cancel (Gtk.Window parent, string title, string question, bool default_ok);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void rename_file (Gtk.Window parent, Fm.Path file);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Fm.Path select_folder (Gtk.Window parent, string title);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void show_error (Gtk.Window parent, string title, string msg);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned string str_replace (string str, string old, string @new);
	[CCode (cheader_filename = "libfmcore.h")]
	public static unowned Fm.ThumbnailRequest thumbnail_request (Fm.FileInfo src_file, uint size, Fm.ThumbnailReadyCallback callback);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void trash_files (Gtk.Window parent, Fm.PathList files);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void trash_or_delete_files (Gtk.Window parent, Fm.PathList files);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool unmount_mount (Gtk.Window parent, GLib.Mount mount, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool unmount_volume (Gtk.Window parent, GLib.Volume vol, bool interactive);
	[CCode (cheader_filename = "libfmcore.h")]
	public static void untrash_files (Gtk.Window parent, Fm.PathList files);
	[CCode (cheader_filename = "libfmcore.h")]
	public static bool yes_no (Gtk.Window parent, string title, string question, bool default_yes);
}
