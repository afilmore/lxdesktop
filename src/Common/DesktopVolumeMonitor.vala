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
        
        public List<Volume> get_volumes () {
        
            
            return _gio_monitor.get_volumes ();
        }
    }
}


