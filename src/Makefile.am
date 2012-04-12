NULL=

AM_CPPFLAGS = \
	-include config.h \
	-DPACKAGE_DATA_DIR=\""$(datadir)/desk2"\" \
	-DPACKAGE_UI_DIR=\""$(datadir)/desk2/ui"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	$(NULL)

bin_PROGRAMS = lxdesktop

lxdesktop_SOURCES = \
	DesktopConfig.vala \
	Application.vala \
	DesktopWindow.vala \
	DesktopGrid.vala \
	DesktopItem.vala \
	TEMP.vala \
	misc.c \
	$(NULL)

lxdesktop_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	--pkg vconfig \
	--pkg gtk+-2.0 \
	--pkg libfmcore \
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


