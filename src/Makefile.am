NULL=


AM_CPPFLAGS = \
	-include config.h \
	-I $(srcdir)/Common \
	-DPACKAGE_DATA_DIR=\""$(datadir)/desk2"\" \
	-DPACKAGE_UI_DIR=\""$(datadir)/desk2/ui"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	$(NULL)


bin_PROGRAMS = lxdesktop


lxdesktop_SOURCES = \
	Application.vala \
	Common/DesktopConfig.vala \
	Common/DesktopPopup.vala \
	Common/DesktopFilePopup.vala \
	Common/DesktopVolumeMonitor.vala \
	Common/LabelEdit.vala \
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
	FileManager/View/ViewTab.vala \
	FileManager/View/BaseView.vala \
	FileManager/View/Folder/FolderView.vala \
	FileManager/View/Search/SearchView.vala \
	FileManager/View/Terminal/TerminalView.vala \
	FileManager/View/Terminal/TerminalWidget.vala \
	FileManager/View/Terminal/TerminalCloseDialog.vala \
	$(NULL)
	

lxdesktop_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	--pkg vconfig \
	--pkg $(GTK_PKG) \
	--pkg libfmcore \
	--pkg libfmcore-private \
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

CLEANFILES = $(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) lxdesktop_vala.stamp


