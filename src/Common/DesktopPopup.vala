/***********************************************************************************************************************
 * DesktopPopup.vala
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
    
    public class Popup {
        
        private const Gtk.ActionEntry _default_popup_actions[] = {
            
            {"CreateNew", null, N_("Create _New..."), "", null,                     null},
            
            {"NewFolder", "folder", N_("Folder"), "<Ctrl><Shift>N", null,           _on_action_new_folder},
            
            {"NewBlank", "text-x-generic", N_("Blank File"), null, null,            _on_action_new_file},
            
            {"Paste", Gtk.Stock.PASTE, null, null, null,                            _on_action_paste},
            
            {"Properties", Gtk.Stock.PROPERTIES, N_("Desktop Preferences"),
                           "<Alt>Return", null,                                     _on_action_proterties}
        };

        private const string _desktop_menu_xml = """
            <popup>
                <menu action='CreateNew'>
                    <menuitem action='NewFolder'/>
                    <menuitem action='NewBlank'/>
                    <separator/>
                    <placeholder name='NewFromTemplate'/>
                </menu>
                
                <separator/>
                <menuitem action='Paste'/>
                
                <separator/>
                <menuitem action='Properties'/>
            </popup>
        """;
        
        Fm.Path     _dest_directory;
        Gtk.Widget  _owner_widget;

        public Popup (Gtk.Widget owner) {
            _owner_widget = owner;
        }
        
        public Gtk.Menu create_desktop_popup (Fm.Path destination) {
            
            _dest_directory = destination;
            
            Gtk.ActionGroup action_group = new Gtk.ActionGroup ("Desktop");
            action_group.set_translation_domain ("");
            action_group.add_actions (_default_popup_actions, this);
            
            Gtk.UIManager ui = new Gtk.UIManager ();
            ui.insert_action_group (action_group, 0);
            
            try {
                ui.add_ui_from_string (_desktop_menu_xml, -1);

                /***Gtk.AccelGroup accel_group = ui.get_accel_group ();
                this.add_accel_group (accel_group);
                ***/
            
                string xml_def =    "<popup>\n";
                xml_def +=              "<menu action='CreateNew'>\n";
                xml_def +=              "<placeholder name='NewFromTemplate'>\n";
                    
                File template_dir = File.new_for_path (Environment.get_user_special_dir (UserDirectory.TEMPLATES));
            
                FileEnumerator infos = template_dir.enumerate_children ("standard::*", FileQueryInfoFlags.NONE);

                FileInfo info;
                while ((info = infos.next_file ()) != null) {
                    
                    FileType type = info.get_file_type();
                    
                    if (type != FileType.REGULAR /*** && type != FileType.SYMBOLIC_LINK ***/)
                        continue;
                    
                    string file_name = info.get_name ();
                    string file_description = ContentType.get_description (info.get_content_type ());
                        
                    Gtk.Action action = new Gtk.Action (file_name,
                                                        file_description,
                                                        "test tooltip...",
                                                        null);
                    
                    action.activate.connect (_on_action_new_from_template);
                    /***gtk_action_set_gicon(act, g_app_info_get_icon(app));***/
                    
                    action_group.add_action (action);
                    
                    xml_def += "<menuitem action='%s'/>\n".printf (file_name);
                };

                xml_def +=      "</placeholder>\n";
                xml_def +=              "</menu>\n";
                xml_def +=  "</popup>\n";
                
                ui.add_ui_from_string (xml_def, -1);
            } catch (Error e) {
            }
            
            return ui.get_widget ("/popup") as Gtk.Menu;
        }
        
        private void _on_action_new_folder (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory, Utils.NewFileNameType.FOLDER);
        }

        private void _on_action_new_file (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory, Utils.NewFileNameType.FILE);
        }

        private void _on_action_new_from_template (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory,
                                            Utils.NewFileNameType.FROM_DESCRIPTION,
                                            action.name,
                                            action.label);
        }
        
        private void _on_action_paste (Gtk.Action action) {
            
            Fm.Clipboard.paste_files (_owner_widget, _dest_directory);
        }

        private void _on_action_proterties (Gtk.Action action) {
            
            // FIXME_axl: passing the widget here won't work... needs to set this parameter in dconf...
            
            if (global_settings_dialog == null)
                global_settings_dialog = new Desktop.SettingsDialog (_owner_widget);
            
            global_settings_dialog.run ();
        }

    }
}


