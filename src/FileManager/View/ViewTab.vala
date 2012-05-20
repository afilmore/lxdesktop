/***********************************************************************************************************************
 * 
 *      ViewTab.vala
 *
 *      Adapted From Pantheon Terminal From Elementary OS (https://launchpad.net/pantheon-terminal)
 * 
 *      Copyright (C) 2011-2012 David Gomes <davidrafagomes@gmail.com>
 *      Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
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
            
            // Add the label...
            _label = new Gtk.Label (text);
            this.pack_start (_label, false, true, 0);

            // Add the button...
            _button = new Gtk.Button ();
            
            _button.set_image (new Gtk.Image.from_stock (Gtk.Stock.CLOSE, Gtk.IconSize.MENU));
            _button.set_relief (Gtk.ReliefStyle.NONE);
            _button.clicked.connect (() => { clicked (); });
            _button.tooltip_text = "Close the tab";
            this.pack_start (_button, false, true, 0);

            show_all ();
        }

        public void set_text (string text) {
            
            _label.set_text (text);
        }

        public signal void clicked ();
    }
}



