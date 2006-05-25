# Copyright 2005, 2006 BreakMyGentoo.org
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 python virtualx

DESCRIPTION="A Gnome panel applet for searching various engines including desktop search with Beagle."
HOMEPAGE="http://browserbookapp.sourceforge.net/deskbar.html"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 x86-sunos"
IUSE="beagle eds soap"

RDEPEND=">=dev-lang/python-2.3
	>=x11-libs/gtk+-2.6
	>=dev-python/pygtk-2.6
	>=dev-python/gnome-python-2.12
	|| ( =dev-python/gnome-python-extras-2.12*
		( >=dev-python/gnome-python-extras-2.13.3
			>=dev-python/gnome-python-desktop-2.13.3 )
			)
	>=gnome-base/gconf-2
	>=gnome-base/gnome-desktop-2.10
	eds? ( >=gnome-extra/evolution-data-server-1.4 )
	beagle? ( >=app-misc/beagle-0.1.3 )
	soap? ( dev-python/soappy )"

G2CONF="${G2CONF} $(use_enable eds evolution)"
USE_DESTDIR=1
DOCS="COPYING AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	if ! built_with_use app-misc/beagle python; then
		eerror "Deskbar-applet requires app-misc/beagle to be built"
		eerror "with Python support."
		die "Please re-emerge beagle with the python USE flag"
	fi
}

src_compile() {

	Xeconf ${G2CONF} || die "Xeconf failed"
	Xemake || die "Xemake failed"
}

pkg_postinst() {
	python_version
	python_mod_optimize ${ROOT}/usr/$(get_libdir)/python${PYVER}/site-packages/deskbar
	python_mod_optimize ${ROOT}/usr/$(get_libdir)/deskbar-applet/handlers
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}

