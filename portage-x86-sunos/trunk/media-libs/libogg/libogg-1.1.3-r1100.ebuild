# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.3.ebuild,v 1.2 2006/03/06 16:13:53 flameeyes Exp $

inherit eutils

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~sh ~sparc ~x86 x86-sunos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epunt_cxx
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}