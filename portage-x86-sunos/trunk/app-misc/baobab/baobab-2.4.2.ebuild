# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/baobab/baobab-2.4.2.ebuild,v 1.1 2006/07/31 02:02:32 vapier Exp $

inherit gnome2

DESCRIPTION="A graphical tool to analyze directory trees"
HOMEPAGE="http://www.marzocca.net/linux/baobab.html"
SRC_URI="http://www.marzocca.net/linux/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-sunos"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6
	>=gnome-base/libgnomeui-2.0
	>=gnome-base/gnome-vfs-2.6
	>=gnome-base/gconf-2.0
	>=gnome-base/libgtop-2.10
	>=gnome-base/libglade-2.5.1
	>=gnome-base/libgnomecanvas-2.10.2
	sys-devel/gettext"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS README"
USE_DESTDIR="1"
