# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gnome-icon-theme/gnome-icon-theme-2.14.2.ebuild,v 1.2 2006/05/06 12:46:05 allanonjl Exp $

inherit gnome2

DESCRIPTION="GNOME 2 default icon themes"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 x86-sunos"
IUSE=""

DEPEND="sys-devel/gettext
	x11-themes/hicolor-icon-theme
	>=dev-util/pkgconfig-0.19
	>=x11-misc/icon-naming-utils-0.6.7
	>=dev-util/intltool-0.29"

DOCS="AUTHORS ChangeLog NEWS TODO"