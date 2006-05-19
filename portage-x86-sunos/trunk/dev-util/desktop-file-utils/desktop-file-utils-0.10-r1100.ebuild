# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/desktop-file-utils/desktop-file-utils-0.10-r1.ebuild,v 1.1 2005/11/06 02:42:18 obz Exp $

inherit eutils

DESCRIPTION="Command line utilities to work with desktop menu entries"
HOMEPAGE="http://www.freedesktop.org/software/desktop-file-utils/"
SRC_URI="http://www.freedesktop.org/software/desktop-file-utils/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 x86-sunos"
IUSE=""

RDEPEND=">=dev-libs/glib-2.0.0
	>=dev-libs/popt-1.6.3"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {

	unpack ${A}
	cd ${S}
	# patch that disables auto pre-compiling of emacs mode file.
	epatch ${FILESDIR}/${PN}-0.10-noemacs.patch

	# add the man pages, see bug #85354
	epatch ${FILESDIR}/${PN}-0.10-man.patch

}

src_install() {

	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
	doman man/*

}
