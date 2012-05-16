/***********************************************************************************************************************
 * DesktopVolumeMonitor.vala
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
namespace Desktop {
    
    public class VolumeMonitor {
        
        private GLib.VolumeMonitor _gio_monitor;
        
        public VolumeMonitor () {
            
            _gio_monitor = GLib.VolumeMonitor.get ();
             
        }
        
        public void test (Gtk.Window parent, Fm.FileInfo? fi) {
            
            List<Volume>? volumes = _gio_monitor.get_volumes ();
            
            foreach (Volume volume in volumes) {
                //stdout.printf ("volume : %s\n", volume.get_name ());
                //stdout.printf ("fi : %s\n", fi.get_disp_name ());
                
                string disp_name = fi.get_disp_name ();
                string volume_name = volume.get_name ();
                
                if (disp_name.contains (volume_name)) {
                    
                    stdout.printf ("found : %s\n", volume_name);
                    
                    //Mount mnt = Volume.get_mount ();
                    //if (mnt == null) {
//~                         GtkWindow* parent = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
                        Fm.mount_volume (parent, volume, true);
                            //return;
//~                         if (!fm_mount_volume(parent, item->vol, TRUE))
//~                             return;
//~                         mnt = g_volume_get_mount(item->vol);
//~                         if(!mnt)
//~                         {
//~                             g_debug("GMount is invalid after successful g_volume_mount().\nThis is quite possibly a gvfs bug.\nSee https://bugzilla.gnome.org/show_bug.cgi?id=552168");
//~                             return;
//~                         }
                    //}

                }
            }
            
            return;
        }
        
        public List<Volume> get_volumes () {
        
            
            return _gio_monitor.get_volumes ();
        }
    }
}


