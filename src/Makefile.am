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
	gtk/exo/exo-lxde.c \
	gtk/exo/exo-marshal.c \
	$(NULL)

gtk_SOURCES = \
	gtk/fm-cell-renderer-pixbuf.c \
	gtk/fm-cell-renderer-text.c \
	gtk/fm-dir-tree-item.c \
	gtk/fm-dir-tree-model.c \
	gtk/fm-dir-tree-view.c \
	gtk/fm-folder-view.c \
	gtk/fm-path-entry.c \
	$(NULL)

lxdesktop_SOURCES = \
	Application.vala \
	Common/DesktopConfig.vala \
	Common/DesktopPopup.vala \
	Common/DesktopFilePopup.vala \
	Common/DesktopVolumeMonitor.vala \
	Common/OptionsParser.vala \
	Common/Utils.vala \
	Common/xlib.c \
	Desktop/background.c \
	Desktop/DesktopGroup.vala \
	Desktop/DesktopWindow.vala \
	Desktop/DesktopGrid.vala \
	Desktop/DesktopItem.vala \
	Desktop/DesktopSettingsDialog.vala \
	Desktop/DesktopSettingsXML.vala \
	FileManager/ManagerGroup.vala \
	FileManager/ManagerWindow.vala \
	FileManager/View/ViewContainer.vala \
	FileManager/View/BaseView.vala \
	FileManager/View/ViewTab.vala \
	FileManager/View/TerminalWidget.vala \
	FileManager/View/TerminalCloseDialog.vala \
	$(exo_SOURCES) \
	$(gtk_SOURCES) \
	$(NULL)
	

lxdesktop_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	--pkg vconfig \
	--pkg $(GTK_PKG) \
	--pkg libfmcore \
	--pkg fm-gtk \
	--pkg posix \
	--pkg vte-2.90 \
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
	$(VTE_CFLAGS) \
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
	$(VTE_LIBS) \
	$(NULL)

CLEANFILES = $(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) lxdesktop.stamp


