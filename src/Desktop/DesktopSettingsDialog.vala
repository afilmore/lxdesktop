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
namespace Desktop {
    

    public class SettingsDialog {
        
        private Gtk.Dialog? _dialog = null;
        private Gtk.Widget  _owner_widget;
        
        public SettingsDialog (Gtk.Widget owner) {
            _owner_widget = owner;
        }
        
        public void run () {
            
            /*** doesn't work...
            if (_dialog != null) {
                _dialog.present ();
                return;
            }
            ***/
            
            Gtk.Builder builder = new Gtk.Builder ();
            
            builder.add_from_string (settings_dialog_xml, -1);
            builder.connect_signals (this);
            
            _dialog = builder.get_object ("dlg") as Gtk.Dialog;

            _dialog.present ();
            
        }
        
        [CCode (instance_pos = -1)]
        public void _on_wallpaper_set (Gtk.FileChooserButton button)
        {

            string filename = button.get_filename ();
            global_config.wallpaper = filename;
            global_config.set_background (_owner_widget);
            
            /*** create a dconf schema...
            g_free(app_config->wallpaper);

            app_config->wallpaper = file;
            
            fm_config_emit_changed(fm_config, "wallpaper");
            ***/
        }
    }
}




