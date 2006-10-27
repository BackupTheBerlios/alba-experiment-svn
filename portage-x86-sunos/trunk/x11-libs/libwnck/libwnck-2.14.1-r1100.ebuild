# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.14.1.ebuild,v 1.1 2006/05/02 21:07:33 dang Exp $

inherit gnome2

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 -x86-sunos"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.5.4
	>=dev-libs/glib-2
	>=x11-libs/startup-notification-0.4
	|| ( x11-libs/libXres virtual/x11 )"

DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.34
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"
USE_DESTDIR="1"
