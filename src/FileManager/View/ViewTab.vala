/***********************************************************************************************************************
 * 
 *      ViewTab.vala
 *
 *      Adapted From Pantheon Terminal From Elementary OS (https://launchpad.net/pantheon-terminal)
 * 
 *      Copyright (C) 2011-2012 David Gomes <davidrafagomes@gmail.com>
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 *      
 *      The button styling code is inspired of GNOME Terminal's close button. (terminal-close-button.c)
 *      
 *      Copyright © 2010 - Paolo Borelli
 *      Copyright © 2011 - Ignacio Casal Quinteiro
 * 
 *      This program is free software: you can redistribute it and/or modify it
 *      under the terms of the GNU Lesser General Public License version 3, as published
 *      by the Free Software Foundation.
 *
 *      This program is distributed in the hope that it will be useful, but
 *      WITHOUT ANY WARRANTY; without even the implied warranties of
 *      MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 *      PURPOSE.  See the GNU General Public License for more details.
 *
 *      You should have received a copy of the GNU General Public License along
 *      with this program.  If not, see <http://www.gnu.org/licenses/>
 * 
 *      Purpose: 
 * 
 * 
 **********************************************************************************************************************/
namespace Manager {

    public class ViewTab : Gtk.Box {

        private Gtk.Label   _label;
        private Gtk.Button  _button;

        public ViewTab (string text) {
            
            this.border_width = 0;
            this.set_spacing (0);
            this.width_request = 64;
            
            // Add the label...
            _label = new Gtk.Label (text);

            _label.set_alignment ((float) 0.0, (float) 0.5);
            _label.set_padding (0, 0);
            //_label.set_ellipsize (Pango.EllipsizeMode.START);
            _label.set_single_line_mode (true);

            this.pack_start (_label, false, true, 0);

            // Add the button...
            _button = new Gtk.Button ();
	
            Gtk.CssProvider provider = new Gtk.CssProvider ();
            Gtk.StyleContext context = _button.get_style_context ();
            const string button_style = """
                * {
                  -GtkButton-default-border : 0;
                  -GtkButton-default-outside-border : 0;
                  -GtkButton-inner-border: 0;
                  -GtkWidget-focus-line-width : 0;
                  -GtkWidget-focus-padding : 0;
                  padding: 0;
                }
                """;

            provider.load_from_data (button_style, -1);
            context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            
            _button.set_image (new Gtk.Image.from_stock (Gtk.Stock.CLOSE, Gtk.IconSize.MENU));
            _button.set_relief (Gtk.ReliefStyle.NONE);
            _button.clicked.connect (() => { clicked (); });
            _button.tooltip_text = "Close the tab";
            this.pack_end (_button, false, false, 0);

            show_all ();
        }

        public void set_text (string text) {
            
            _label.set_text (text);
        }

        public signal void clicked ();
    }
}



