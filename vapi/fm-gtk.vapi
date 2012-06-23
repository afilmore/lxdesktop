/***********************************************************************************************************************
 * fm-gtk.vapi
 * 
 * Copyright 2012 Axel FILMORE <axel.filmore@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2.
 * http://www.gnu.org/licenses/gpl-2.0.txt
 * 
 * Purpose: Binding file for Gtk Views.
 * 
 * Version: 0.2
 * 
 * 
 **********************************************************************************************************************/
namespace Fm {
	
    
    [CCode (cheader_filename = "Desktop/background.h", cprefix = "FM_WP_")]
    public enum WallpaperMode {
        COLOR,
        STRETCH,
        FIT,
        CENTER,
        TILE
    }
    
    
}


