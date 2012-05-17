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
    
    const string settings_dialog_xml = """
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <!-- interface-requires gtk+ 3.0 -->
  <object class="GtkDialog" id="dlg">
    <property name="can_focus">False</property>
    <property name="border_width">5</property>
    <property name="title" translatable="yes">Desktop Preferences</property>
    <property name="resizable">False</property>
    <property name="window_position">center</property>
    <property name="type_hint">dialog</property>
    <child internal-child="vbox">
      <object class="GtkBox" id="dialog-vbox1">
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <property name="orientation">vertical</property>
        <property name="spacing">2</property>
        <child internal-child="action_area">
          <object class="GtkButtonBox" id="dialog-action_area1">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="layout_style">end</property>
            <child>
              <object class="GtkButton" id="close">
                <property name="label">gtk-close</property>
                <property name="use_action_appearance">False</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="use_action_appearance">False</property>
                <property name="use_stock">True</property>
              </object>
              <packing>
                <property name="expand">False</property>
                <property name="fill">False</property>
                <property name="position">0</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="pack_type">end</property>
            <property name="position">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkNotebook" id="notebook1">
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <child>
              <object class="GtkVBox" id="vbox1">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="border_width">12</property>
                <property name="spacing">18</property>
                <child>
                  <object class="GtkVBox" id="vbox3">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="spacing">6</property>
                    <child>
                      <object class="GtkLabel" id="label14">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="xalign">0</property>
                        <property name="label" translatable="yes">&lt;b&gt;Background&lt;/b&gt;</property>
                        <property name="use_markup">True</property>
                      </object>
                      <packing>
                        <property name="expand">False</property>
                        <property name="fill">True</property>
                        <property name="position">0</property>
                      </packing>
                    </child>
                    <child>
                      <object class="GtkAlignment" id="alignment3">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="left_padding">12</property>
                        <child>
                          <object class="GtkVBox" id="vbox5">
                            <property name="visible">True</property>
                            <property name="can_focus">False</property>
                            <property name="spacing">6</property>
                            <child>
                              <object class="GtkHBox" id="hbox3">
                                <property name="visible">True</property>
                                <property name="can_focus">False</property>
                                <property name="spacing">12</property>
                                <child>
                                  <object class="GtkLabel" id="label3">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="xalign">0</property>
                                    <property name="label" translatable="yes">Wallpaper:</property>
                                  </object>
                                  <packing>
                                    <property name="expand">False</property>
                                    <property name="fill">True</property>
                                    <property name="position">0</property>
                                  </packing>
                                </child>
                                <child>
                                  <object class="GtkFileChooserButton" id="wallpaper">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="title" translatable="yes">Please select an image file</property>
                                    <property name="width_chars">40</property>
                                  </object>
                                  <packing>
                                    <property name="expand">True</property>
                                    <property name="fill">True</property>
                                    <property name="position">1</property>
                                  </packing>
                                </child>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">0</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkHBox" id="hbox1">
                                <property name="visible">True</property>
                                <property name="can_focus">False</property>
                                <property name="spacing">12</property>
                                <child>
                                  <object class="GtkLabel" id="label10">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="xalign">0</property>
                                    <property name="label" translatable="yes">Background color:</property>
                                  </object>
                                  <packing>
                                    <property name="expand">False</property>
                                    <property name="fill">True</property>
                                    <property name="position">0</property>
                                  </packing>
                                </child>
                                <child>
                                  <object class="GtkColorButton" id="desktop_bg">
                                    <property name="use_action_appearance">False</property>
                                    <property name="visible">True</property>
                                    <property name="can_focus">True</property>
                                    <property name="receives_default">True</property>
                                    <property name="use_action_appearance">False</property>
                                    <property name="color">#000000000000</property>
                                  </object>
                                  <packing>
                                    <property name="expand">False</property>
                                    <property name="fill">True</property>
                                    <property name="position">1</property>
                                  </packing>
                                </child>
                              </object>
                              <packing>
                                <property name="expand">True</property>
                                <property name="fill">True</property>
                                <property name="position">1</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkHBox" id="hbox2">
                                <property name="visible">True</property>
                                <property name="can_focus">False</property>
                                <property name="spacing">12</property>
                                <child>
                                  <object class="GtkLabel" id="label4">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="xalign">0</property>
                                    <property name="label" translatable="yes">Wallpaper mode:</property>
                                  </object>
                                  <packing>
                                    <property name="expand">False</property>
                                    <property name="fill">True</property>
                                    <property name="position">0</property>
                                  </packing>
                                </child>
                                <child>
                                  <object class="GtkComboBox" id="wallpaper_mode">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="model">wp_modes</property>
                                    <child>
                                      <object class="GtkCellRendererText" id="cellrenderertext1"/>
                                      <attributes>
                                        <attribute name="text">0</attribute>
                                      </attributes>
                                    </child>
                                  </object>
                                  <packing>
                                    <property name="expand">True</property>
                                    <property name="fill">True</property>
                                    <property name="position">1</property>
                                  </packing>
                                </child>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">3</property>
                              </packing>
                            </child>
                          </object>
                        </child>
                      </object>
                      <packing>
                        <property name="expand">False</property>
                        <property name="fill">True</property>
                        <property name="position">1</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">True</property>
                    <property name="position">0</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkVBox" id="vbox4">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="spacing">6</property>
                    <child>
                      <object class="GtkLabel" id="label6">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="xalign">0</property>
                        <property name="label" translatable="yes">&lt;b&gt;Text&lt;/b&gt;</property>
                        <property name="use_markup">True</property>
                      </object>
                      <packing>
                        <property name="expand">False</property>
                        <property name="fill">True</property>
                        <property name="position">0</property>
                      </packing>
                    </child>
                    <child>
                      <object class="GtkAlignment" id="alignment4">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="left_padding">12</property>
                        <child>
                          <object class="GtkVBox" id="vbox6">
                            <property name="visible">True</property>
                            <property name="can_focus">False</property>
                            <property name="spacing">6</property>
                            <child>
                              <object class="GtkHBox" id="hbox4">
                                <property name="visible">True</property>
                                <property name="can_focus">False</property>
                                <property name="spacing">12</property>
                                <child>
                                  <object class="GtkLabel" id="label5">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="label" translatable="yes">Font of label text:</property>
                                  </object>
                                  <packing>
                                    <property name="expand">False</property>
                                    <property name="fill">True</property>
                                    <property name="position">0</property>
                                  </packing>
                                </child>
                                <child>
                                  <object class="GtkFontButton" id="desktop_font">
                                    <property name="use_action_appearance">False</property>
                                    <property name="visible">True</property>
                                    <property name="can_focus">True</property>
                                    <property name="receives_default">True</property>
                                    <property name="use_action_appearance">False</property>
                                  </object>
                                  <packing>
                                    <property name="expand">True</property>
                                    <property name="fill">True</property>
                                    <property name="position">1</property>
                                  </packing>
                                </child>
                              </object>
                              <packing>
                                <property name="expand">True</property>
                                <property name="fill">True</property>
                                <property name="position">0</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkHBox" id="hbox6">
                                <property name="visible">True</property>
                                <property name="can_focus">False</property>
                                <property name="spacing">12</property>
                                <child>
                                  <object class="GtkHBox" id="hbox9">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="spacing">12</property>
                                    <child>
                                      <object class="GtkLabel" id="label11">
                                        <property name="visible">True</property>
                                        <property name="can_focus">False</property>
                                        <property name="label" translatable="yes">Color of label text:</property>
                                      </object>
                                      <packing>
                                        <property name="expand">False</property>
                                        <property name="fill">True</property>
                                        <property name="position">0</property>
                                      </packing>
                                    </child>
                                    <child>
                                      <object class="GtkColorButton" id="desktop_fg">
                                        <property name="use_action_appearance">False</property>
                                        <property name="visible">True</property>
                                        <property name="can_focus">True</property>
                                        <property name="receives_default">True</property>
                                        <property name="use_action_appearance">False</property>
                                        <property name="color">#000000000000</property>
                                      </object>
                                      <packing>
                                        <property name="expand">False</property>
                                        <property name="fill">True</property>
                                        <property name="position">1</property>
                                      </packing>
                                    </child>
                                  </object>
                                  <packing>
                                    <property name="expand">True</property>
                                    <property name="fill">True</property>
                                    <property name="position">0</property>
                                  </packing>
                                </child>
                                <child>
                                  <object class="GtkHBox" id="hbox5">
                                    <property name="visible">True</property>
                                    <property name="can_focus">False</property>
                                    <property name="spacing">12</property>
                                    <child>
                                      <object class="GtkLabel" id="label13">
                                        <property name="visible">True</property>
                                        <property name="can_focus">False</property>
                                        <property name="label" translatable="yes">Color of shadow:</property>
                                      </object>
                                      <packing>
                                        <property name="expand">False</property>
                                        <property name="fill">True</property>
                                        <property name="position">0</property>
                                      </packing>
                                    </child>
                                    <child>
                                      <object class="GtkColorButton" id="desktop_shadow">
                                        <property name="use_action_appearance">False</property>
                                        <property name="visible">True</property>
                                        <property name="can_focus">True</property>
                                        <property name="receives_default">True</property>
                                        <property name="use_action_appearance">False</property>
                                        <property name="color">#000000000000</property>
                                      </object>
                                      <packing>
                                        <property name="expand">False</property>
                                        <property name="fill">True</property>
                                        <property name="position">1</property>
                                      </packing>
                                    </child>
                                  </object>
                                  <packing>
                                    <property name="expand">True</property>
                                    <property name="fill">True</property>
                                    <property name="position">1</property>
                                  </packing>
                                </child>
                              </object>
                              <packing>
                                <property name="expand">True</property>
                                <property name="fill">True</property>
                                <property name="position">1</property>
                              </packing>
                            </child>
                          </object>
                        </child>
                      </object>
                      <packing>
                        <property name="expand">True</property>
                        <property name="fill">True</property>
                        <property name="position">1</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">True</property>
                    <property name="position">1</property>
                  </packing>
                </child>
              </object>
            </child>
            <child type="tab">
              <object class="GtkLabel" id="label1">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="label" translatable="yes">Appearance</property>
              </object>
              <packing>
                <property name="tab_fill">False</property>
              </packing>
            </child>
            <child>
              <object class="GtkVBox" id="icons_page">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="border_width">12</property>
                <property name="spacing">18</property>
                <child>
                  <object class="GtkVBox" id="vbox8">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="spacing">6</property>
                    <child>
                      <object class="GtkLabel" id="label19">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="xalign">0</property>
                        <property name="label" translatable="yes">&lt;b&gt;Show desktop icons&lt;/b&gt;</property>
                        <property name="use_markup">True</property>
                      </object>
                      <packing>
                        <property name="expand">False</property>
                        <property name="fill">True</property>
                        <property name="position">0</property>
                      </packing>
                    </child>
                    <child>
                      <object class="GtkAlignment" id="alignment1">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="left_padding">12</property>
                        <child>
                          <object class="GtkVBox" id="vbox2">
                            <property name="visible">True</property>
                            <property name="can_focus">False</property>
                            <property name="spacing">6</property>
                            <child>
                              <object class="GtkCheckButton" id="show_my_doc">
                                <property name="label" translatable="yes">Show "My Documents" icon on desktop</property>
                                <property name="use_action_appearance">False</property>
                                <property name="visible">True</property>
                                <property name="can_focus">True</property>
                                <property name="receives_default">False</property>
                                <property name="use_action_appearance">False</property>
                                <property name="use_underline">True</property>
                                <property name="draw_indicator">True</property>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">0</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkCheckButton" id="show_my_computer">
                                <property name="label" translatable="yes">Show "My Computer" icon on desktop</property>
                                <property name="use_action_appearance">False</property>
                                <property name="visible">True</property>
                                <property name="can_focus">True</property>
                                <property name="receives_default">False</property>
                                <property name="use_action_appearance">False</property>
                                <property name="use_underline">True</property>
                                <property name="draw_indicator">True</property>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">1</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkCheckButton" id="show_trash">
                                <property name="label" translatable="yes">Show "Trash Bin" icon on desktop</property>
                                <property name="use_action_appearance">False</property>
                                <property name="visible">True</property>
                                <property name="can_focus">True</property>
                                <property name="receives_default">False</property>
                                <property name="use_action_appearance">False</property>
                                <property name="use_underline">True</property>
                                <property name="draw_indicator">True</property>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">2</property>
                              </packing>
                            </child>
                            <child>
                              <object class="GtkCheckButton" id="show_volumes">
                                <property name="label" translatable="yes">Show icons of volumes on desktop</property>
                                <property name="use_action_appearance">False</property>
                                <property name="visible">True</property>
                                <property name="can_focus">True</property>
                                <property name="receives_default">False</property>
                                <property name="use_action_appearance">False</property>
                                <property name="use_underline">True</property>
                                <property name="draw_indicator">True</property>
                              </object>
                              <packing>
                                <property name="expand">False</property>
                                <property name="fill">True</property>
                                <property name="position">3</property>
                              </packing>
                            </child>
                          </object>
                        </child>
                      </object>
                      <packing>
                        <property name="expand">True</property>
                        <property name="fill">True</property>
                        <property name="position">1</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">True</property>
                    <property name="position">0</property>
                  </packing>
                </child>
              </object>
              <packing>
                <property name="position">1</property>
              </packing>
            </child>
            <child type="tab">
              <object class="GtkLabel" id="label2">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="label" translatable="yes">Desktop Icons</property>
              </object>
              <packing>
                <property name="position">1</property>
                <property name="tab_fill">False</property>
              </packing>
            </child>
            <child>
              <object class="GtkVBox" id="vbox7">
                <property name="can_focus">False</property>
                <property name="border_width">12</property>
                <property name="spacing">6</property>
                <child>
                  <object class="GtkCheckButton" id="show_wm_menu">
                    <property name="label" translatable="yes">Show menus provided by window managers when desktop is clicked</property>
                    <property name="use_action_appearance">False</property>
                    <property name="visible">True</property>
                    <property name="can_focus">True</property>
                    <property name="receives_default">False</property>
                    <property name="events">GDK_POINTER_MOTION_MASK | GDK_POINTER_MOTION_HINT_MASK | GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK</property>
                    <property name="use_action_appearance">False</property>
                    <property name="draw_indicator">True</property>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">True</property>
                    <property name="position">0</property>
                  </packing>
                </child>
              </object>
              <packing>
                <property name="position">2</property>
              </packing>
            </child>
            <child type="tab">
              <object class="GtkLabel" id="label7">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="label" translatable="yes">Advanced</property>
              </object>
              <packing>
                <property name="position">2</property>
                <property name="tab_fill">False</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="position">1</property>
          </packing>
        </child>
      </object>
    </child>
    <action-widgets>
      <action-widget response="0">close</action-widget>
    </action-widgets>
  </object>
  <object class="GtkListStore" id="wp_modes">
    <columns>
      <!-- column-name title -->
      <column type="gchararray"/>
      <!-- column-name mode -->
      <column type="guint"/>
    </columns>
    <data>
      <row>
        <col id="0" translatable="yes">Fill with background color only</col>
        <col id="1">0</col>
      </row>
      <row>
        <col id="0" translatable="yes">Stretch to fill the entire screen</col>
        <col id="1">1</col>
      </row>
      <row>
        <col id="0" translatable="yes">Stretch to fit the screen</col>
        <col id="1">2</col>
      </row>
      <row>
        <col id="0" translatable="yes">Center on the screen</col>
        <col id="1">3</col>
      </row>
      <row>
        <col id="0" translatable="yes">Tile the image to fill the entire screen</col>
        <col id="1">4</col>
      </row>
    </data>
  </object>
</interface>
    """;
    
    public class SettingsDialog {
        
        private Gtk.Dialog? _dialog = null;
        
        
        public void run () {
            
            if (_dialog != null) {
                _dialog.present ();
                return;
            }
            
            Gtk.Builder builder = new Gtk.Builder ();
            
            builder.add_from_string (settings_dialog_xml, -1);
            
            _dialog = builder.get_object ("dlg") as Gtk.Dialog;

            //~ Gtk.Widget item;
            //~ Gtk.Widget img_preview;
            //~ item = gtk_builder_get_object(builder, "wallpaper");
            //~ 
            //~ g_signal_connect(item, "file-set", G_CALLBACK(on_wallpaper_set), null);
            //~ 
            //~ img_preview = gtk_image_new();
            //~ 
            //~ gtk_misc_set_alignment(GTK_MISC(img_preview), 0.5, 0.0);
            //~ 
            //~ gtk_widget_set_size_request( img_preview, 128, 128 );
            //~ 
            //~ gtk_file_chooser_set_preview_widget( (Gtk.FileChooser*)item, img_preview );
            //~ 
            //~ g_signal_connect( item, "update-preview", G_CALLBACK(on_update_img_preview), img_preview );
            //~ 
            //~ if(app_config->wallpaper)
            //~     gtk_file_chooser_set_filename(GTK_FILE_CHOOSER(item), app_config->wallpaper);
            //~ 
            //~ INIT_COMBO(builder, FmAppConfig, wallpaper_mode, "wallpaper");
            //~ INIT_COLOR(builder, FmAppConfig, desktop_bg, "wallpaper");
            //~ 
            //~ INIT_COLOR(builder, FmAppConfig, desktop_fg, "desktop_text");
            //~ INIT_COLOR(builder, FmAppConfig, desktop_shadow, "desktop_text");
            //~ 
            //~ INIT_BOOL(builder, FmAppConfig, show_wm_menu, null);
            //~ 
            //~ item = gtk_builder_get_object(builder, "desktop_font");
            //~ if(app_config->desktop_font)
            //~     gtk_font_button_set_font_name(GTK_FONT_BUTTON(item), app_config->desktop_font);
            //~ g_signal_connect(item, "font-set", G_CALLBACK(on_desktop_font_set), null);
            //~ 
            //~ g_signal_connect(desktop_pref_dlg, "response", G_CALLBACK(on_response), &desktop_pref_dlg);
            //~ g_object_unref(builder);
            //~ 
            //~ pcmanfm_ref();
            //~ g_signal_connect(desktop_pref_dlg, "destroy", G_CALLBACK(pcmanfm_unref), null);
            
            _dialog.present ();
            
        }
    }
}




