/***********************************************************************************************************************
 * 
 *      TerminalCloseDialog.vala
 *
 *      Adapted From Pantheon Terminal From Elementary OS (https://launchpad.net/pantheon-terminal)
 * 
 *      Copyright (C) 2011-2012 Mario Guerriero <mefrio.g@gmail.com>
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
namespace Terminal {

    public class CloseDialog : Gtk.MessageDialog {

        public CloseDialog () {
            
            use_markup = true;
            set_markup ("<b>" + _("There is an active process on this shell!") + "</b>\n\n" +
                      _("Do you want to stay on the shell?"));
            
            Gtk.Button button = new Gtk.Button.with_label (_("Stay on this terminal"));
            button.show ();
            add_action_widget (button, 0);
            
            button = new Gtk.Button.with_label (_("Kill terminal"));
            button.show ();
            add_action_widget (button, 1);
        }
        
        public CloseDialog.before_close () {
            
            use_markup = true;
            set_markup ("<b>" + _("There is an active process on this terminal!") + "</b>\n\n" +
                      _("Do you want to close this terminal?"));
            
            Gtk.Button button = new Gtk.Button.with_label (_("Stay"));
            button.show ();
            add_action_widget (button, 0);
            
            button = new Gtk.Button.with_label (_("Close terminal"));
            button.show ();
            add_action_widget (button, 1);
        }

    }

}
