/***********************************************************************************************************************
 * OptionParser.vala
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * This Option Parser is inspired of xnoise-application by Jörn Magens:
 * https://github.com/shuerhaaken/xnoise/blob/master/libxnoise/Application/xnoise-application.vala#L77
 * 
 * Purpose: A simple argument parsing class that permits to parse arguments several times within the same application,
 *          for example parse arguments given to the Main function or arguments received via DBus.
 * 
 * 
 * 
 **********************************************************************************************************************/
namespace Desktop {

    public class OptionParser {
        
        public static bool desktop;
        public static bool debug;
        public static string[] remaining;
            
        private const OptionEntry[] _option_entries = {
            
            {"desktop", '\0',    0,  OptionArg.NONE,            ref desktop,
             N_("Launch desktop manager"),
             null},
            {"debug",   'd',   0,  OptionArg.NONE,              ref debug,
             N_("Run In Debug Mode"),
             null},
            {"",        '\0',   0,  OptionArg.FILENAME_ARRAY,   ref remaining,
             null,
             "[FILE...]"},
            {null}
        };

        public OptionParser (string[] args) {
            
            desktop = false;
            debug = false;
            
            string[] sa_args = {};
            
            foreach (string arg in args) {
                //print ("%s\n", arg);
                sa_args += arg;
            }
            OptionContext context = new OptionContext ("");
            context.add_main_entries (_option_entries, null);

            unowned string[] uargs = sa_args;
            try {
                context.parse (ref uargs);
            } catch (OptionError e) {
                stdout.printf ("OptionParser: %s\n", e.message);
            }
        }
    }
}


