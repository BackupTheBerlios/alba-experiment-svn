# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gksu/gksu-1.9.1.ebuild,v 1.1 2006/05/06 12:46:44 dragonheart Exp $

inherit gnome2

DESCRIPTION="A gtk+ frontend for libgksu"
HOMEPAGE="http://www.nongnu.org/gksu/"
SRC_URI="http://people.debian.org/~kov/gksu/gksu/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 -x86-sunos"
IUSE="${IUSE} nls"

RDEPEND=">=x11-libs/libgksu-1.9.2
	>=x11-libs/gtk+-2.4.0
	>=gnome-base/gconf-2.0
	>=gnome-base/gnome-keyring-0.4.3
	app-admin/sudo
	>=gnome-base/orbit-2.12.2
	dev-libs/atk
	x11-libs/pango
	x11-libs/cairo
	media-libs/libpng
	nls? ( sys-devel/gettext )
	>=dev-libs/glib-2.8.4
	|| (
	( >=x11-libs/libX11-1.0.0 )
	virtual/x11 )"

DEPEND="${RDEPEND}"


GCONF2="$(use_enable nls)"
USE_DESTDIR="1"
