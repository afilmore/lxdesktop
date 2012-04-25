NULL=

AM_CPPFLAGS = \
	-include config.h \
	-DPACKAGE_DATA_DIR=\""$(datadir)/desk2"\" \
	-DPACKAGE_UI_DIR=\""$(datadir)/desk2/ui"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	$(NULL)

bin_PROGRAMS = lxdesktop

exo_SOURCES = \
	gtk/exo/exo-icon-view.c \
	gtk/exo/exo-private.c \
	gtk/exo/exo-tree-view.c \
	gtk/exo/exo-marshal.c \
	gtk/exo/exo-string.c \
	$(NULL)

gtk_SOURCES = \
	gtk/fm-cell-renderer-text.c \
	gtk/fm-dir-tree-model.c \
	gtk/fm-dir-tree-view.c \
	gtk/fm-folder-view.c \
	gtk/fm-path-entry.c \
	$(NULL)

TEMP = \
	gtk/fm-places-model.c \
	gtk/fm-places-view.c \
	gtk/fm-places-view.h
	gtk/fm-places-model.h
	gtk/fm-folder-view.h
	gtk/fm-dir-tree-view.h
	gtk/fm-dir-tree-model.h
	gtk/exo/exo-icon-view.h \
	gtk/exo/exo-private.h \
	gtk/exo/exo-marshal.h \
	gtk/exo/exo-string.h \
	gtk/exo/exo-tree-view.h \
	$(NULL)
	
lxdesktop_SOURCES = \
	Application.vala \
	Desktop/DesktopConfig.vala \
	Desktop/DesktopGroup.vala \
	Desktop/DesktopWindow.vala \
	Desktop/DesktopGrid.vala \
	Desktop/DesktopItem.vala \
	FileManager/ManagerWindow.vala \
	FileManager/ManagerGroup.vala \
	Misc/Utils.vala \
	Misc/OptionsParser.vala \
	Misc/TEMP.vala \
	Misc/misc.c \
	$(exo_SOURCES) \
	$(gtk_SOURCES) \
	$(NULL)

lxdesktop_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	--pkg vconfig \
	--pkg gtk+-2.0 \
	--pkg libfmcore \
	--pkg fm-gtk \
	$(NULL)

lxdesktop_CFLAGS = \
	$(XLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(PANGO_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GMODULE_CFLAGS) \
	$(FM_CFLAGS) \
	$(MENU_CACHE_CFLAGS) \
	$(G_CAST_CHECKS) \
	-Wall \
	-Werror-implicit-function-declaration \
	$(NULL)

lxdesktop_LDADD = \
	$(XLIB_LIBS) \
	$(GTK_LIBS) \
	$(PANGO_LIBS) \
	$(GLIB_LIBS) \
	$(GIO_LIBS) \
	$(GMODULE_LIBS) \
	$(FM_LIBS) \
	$(MENU_CACHE_LIBS) \
	$(NULL)

CLEANFILES = $(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) lxdesktop.stamp


