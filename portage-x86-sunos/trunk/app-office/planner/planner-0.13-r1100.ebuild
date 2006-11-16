# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/planner/planner-0.13.ebuild,v 1.2 2005/06/09 00:31:54 mr_bones_ Exp $

inherit gnome2 fdo-mime

DESCRIPTION="Project manager for Gnome2"
HOMEPAGE="http://planner.imendio.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~ppc ~sparc ~x86 -x86-sunos"
IUSE="doc libgda python"

RDEPEND=">=dev-libs/glib-2.4
	>=x11-libs/gtk+-2.4
	>=gnome-base/libgnomecanvas-2.6
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/libglade-2.4
	>=gnome-base/gnome-vfs-2.6
	>=gnome-base/libgnomeprintui-2.6
	>=gnome-base/gconf-2.6
	>=dev-libs/libxml2-2.6
	>=dev-libs/libxslt-1.1
	libgda? ( >=gnome-extra/libgda-1.0 )
	python? ( >=dev-python/pygtk-2.0.0-r1 )"
# disable eds backend for now, its experimental
#	eds? ( >=gnome-extra/evolution-data-server-1.1 )"
#		>=mail-client/evolution-2.1.3 )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0
	app-text/scrollkeeper
	dev-util/intltool
	doc? ( >=dev-util/gtk-doc-0.10 )"

DOCS="AUTHORS COPYING ChangeLog INSTALL README"

# darn thing breaks in paralell make :/
MAKEOPTS="${MAKEOPTS} -j1"

G2CONF="${G2CONF} \
	$(use_enable libgda database) \
	$(use_enable python) \
	$(use_enable python python-plugin) \
	--disable-update-mimedb"
#	$(use_enable eds) \
#	$(use_enable eds eds-backend) \
