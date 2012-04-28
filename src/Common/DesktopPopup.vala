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
        
        private const string _desktop_menu_xml = """
            <popup>
                <menu action='CreateNew'>
                    <menuitem action='NewFolder'/>
                    <menuitem action='NewBlank'/>
                    <separator/>
                    <placeholder name='ph1'/>
                </menu>
                <separator/>
                <menuitem action='Paste'/>
                <separator/>
                <menuitem action='SelAll'/>
                <menuitem action='InvSel'/>
                <separator/>
                <menuitem action='Properties'/>
            </popup>
        """;
        
        Fm.Path _dest_directory;

        public Popup (Fm.Path destination) {
            _dest_directory = destination;
        }
        
        public Gtk.Menu create_desktop_popup (Gtk.ActionEntry[] desktop_actions) {
            
            //function = action_callback;
            
            Gtk.ActionGroup action_group = new Gtk.ActionGroup ("Desktop");
            action_group.set_translation_domain ("");
            action_group.add_actions (desktop_actions, this);
            
            Gtk.UIManager ui = new Gtk.UIManager ();
            ui.insert_action_group (action_group, 0);
            ui.add_ui_from_string (_desktop_menu_xml, -1);
        
            /*Gtk.AccelGroup accel_group = ui.get_accel_group ();
            this.add_accel_group (accel_group);
        */
            string xml_def =    "<popup>\n";
            xml_def +=              "<menu action='CreateNew'>\n";
            xml_def +=              "<placeholder name='ph1'>\n";
                
            File template_dir = File.new_for_path (Environment.get_user_special_dir (UserDirectory.TEMPLATES));
            
            FileEnumerator infos = template_dir.enumerate_children (
                "standard::*", FileQueryInfoFlags.NONE);
            
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
                
                action.activate.connect (_test_template);
                /*action.activate.connect ( (act) => {
                    
                    action_callback (act);
                });*/
                
                //gtk_action_set_gicon(act, g_app_info_get_icon(app));
                
                action_group.add_action (action);
                
                xml_def += "<menuitem action='%s'/>\n".printf (file_name);
            };

            xml_def +=      "</placeholder>\n";
            xml_def +=              "</menu>\n";
            xml_def +=  "</popup>\n";
            
            ui.add_ui_from_string (xml_def, -1);
            return ui.get_widget ("/popup") as Gtk.Menu;
        }
        
        private void _test_template (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory,
                                            Utils.NewFileNameType.FROM_DESCRIPTION,
                                            action.name,
                                            action.label);
        }
        
        private void _on_action_new_folder (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory, Utils.NewFileNameType.FOLDER);
        }

        private void _on_action_new_file (Gtk.Action action) {
            
            Utils.filemanager_new_document (_dest_directory, Utils.NewFileNameType.FILE);
        }

        private void _on_action_paste (Gtk.Action action) {
            
            //Fm.Path path = Fm.Path.get_desktop ();
            //Fm.Clipboard.paste_files (this, _dest_directory);
        }

        
        
        
    }
}


