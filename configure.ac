#***************************************************************************************************
#   
#   make clean;make distclean;./autogen.sh && ./configure --enable-debug=yes --prefix=/usr && make
#
#
#
#***************************************************************************************************
AC_PREREQ([2.63])

AC_INIT([lxdesktop], [0.3.0], [https://github.com/afilmore/lxdesktop])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_CONFIG_HEADERS([config.h])


# Checks for programs.
AC_ISC_POSIX
AC_PROG_CC
AM_PROG_LIBTOOL
AM_PROG_CC_STDC


# Checks for header files.
AC_HEADER_STDC


#*****************************************************************************************
#   Large file support
#
#
#*****************************************************************************************
AC_ARG_ENABLE([largefile],
              AS_HELP_STRING([--enable-largefile],
              [Enable Large file support (default: yes)]),
              largefile=$enableval,
              largefile="yes")

if test x"$largefile" = x"yes"; then
    CPPFLAGS="$CPPFLAGS -D_LARGEFILE_SOURCE -D_REENTRANT -D_FILE_OFFSET_BITS=64"
    AC_DEFINE(_LARGEFILE64_SOURCE, 1, [Whether to enable large file support])
    AC_DEFINE(_FILE_OFFSET_BITS, 64, [File offset bits])
fi


#*****************************************************************************************
#   Glib Cast Checks...
#
#
#*****************************************************************************************
AC_ARG_ENABLE([cast-checks],
              AS_HELP_STRING([--enable-cast-checks],
              [Enable Glib Cast Checks (default: disable)]),
              cast_checks=$enableval,
              cast_checks="no")

G_CAST_CHECKS=""
if test x"$cast_checks" = x"no"; then
    G_CAST_CHECKS="-DG_DISABLE_CAST_CHECKS"
fi
AC_SUBST(G_CAST_CHECKS)


#*****************************************************************************************
#   Debug Support...
#
#
#*****************************************************************************************
AC_ARG_ENABLE(treeview-debug,
              [AC_HELP_STRING([--enable-treeview-debug],
              [Debug The Tree View (default: no)])],
              enable_treeview_debug=$enableval,
              enable_treeview_debug="no")


if test "$enable_treeview_debug" = "yes"; then
    CPPFLAGS="$CPPFLAGS -DENABLE_TREEVIEW_DEBUG"
    enable_debug = "yes"
fi


AC_ARG_ENABLE(debug,
              [AC_HELP_STRING([--enable-debug],
              [build lxdesktop with debug support (default: no)])],
              enable_debug=$enableval,
              enable_debug="no")


if test "$enable_debug" = "yes"; then
    CPPFLAGS="$CPPFLAGS -DENABLE_DEBUG -DG_ENABLE_DEBUG -O0 -g"
else
    #CPPFLAGS="$CPPFLAGS -DG_DISABLE_ASSERT -DG_DISABLE_CHECKS"
    CPPFLAGS="$CPPFLAGS -O2"
fi


#*****************************************************************************************
#   Intltool...
#
#
#*****************************************************************************************
#IT_PROG_INTLTOOL([0.40.0])


#*****************************************************************************************
#   Vala...
#
#
#*****************************************************************************************
AM_PROG_VALAC([0.16.0])


#*****************************************************************************************
#   Checks For Libraries...
#
#   pkg-config --cflags --libs LIB_NAME
#
#*****************************************************************************************
pkg_modules="gtk+-3.0 >= 3.0.0"
GTK_PKG="gtk+-3.0"
CPPFLAGS="$CPPFLAGS -DENABLE_GTK3"
VALAFLAGS="$VALAFLAGS -D ENABLE_GTK3"
AC_DEFINE(ENABLE_GTK3, 1, [Enable GTK3])
AC_SUBST(VALAFLAGS)
AC_SUBST(ENABLE_GTK3)
AC_SUBST(GTK_PKG)

PKG_CHECK_MODULES(GTK, [$pkg_modules])
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

fm_modules="libfmcore-3.0 >= 0.1.99"
PKG_CHECK_MODULES(FM, [$fm_modules])
AC_SUBST(FM_CFLAGS)
AC_SUBST(FM_LIBS)

gmodule_modules="gmodule-2.0"
PKG_CHECK_MODULES(GMODULE, [$gmodule_modules])
AC_SUBST(GMODULE_CFLAGS)
AC_SUBST(GMODULE_LIBS)

menu_modules="libmenu-cache >= 0.3.2"
PKG_CHECK_MODULES(MENU_CACHE, [$menu_modules])
AC_SUBST(MENU_CACHE_CFLAGS)
AC_SUBST(MENU_CACHE_LIBS)

vte_modules="vte-2.90"
PKG_CHECK_MODULES(VTE, [$vte_modules])
AC_SUBST(VTE_CFLAGS)
AC_SUBST(VTE_LIBS)


#*****************************************************************************************
#   
#
#   
#
#*****************************************************************************************
GETTEXT_PACKAGE=lxdesktop
AC_SUBST(GETTEXT_PACKAGE)


# Generate po/LINGUAS on the fly rather than relying on translators
# to maintain it manually. This also overcome the problem that Transifex
# cannot add a language to po/LINGUAS if a new po file is submitted.
#~ rm -f $srcdir/po/LINGUAS
#~ for po_file in `ls $srcdir/po/*.po | sort`;
#~ do
    #~ lang=`echo "$po_file" | sed "s|.*/po/\(.*\)\.po|\1|g"`
    #~ echo $lang >> $srcdir/po/LINGUAS
#~ done

AM_GLIB_GNU_GETTEXT
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [Gettext package.])


#*****************************************************************************************
#   
#
#   
#
#*****************************************************************************************
AC_CONFIG_FILES([
    Makefile
    data/Makefile
    src/Makefile
])

AC_OUTPUT



