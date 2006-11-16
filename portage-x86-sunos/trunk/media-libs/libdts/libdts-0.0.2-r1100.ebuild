# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdts/libdts-0.0.2-r3.ebuild,v 1.10 2006/03/06 15:00:51 flameeyes Exp $

inherit eutils autotools

DESCRIPTION="library for decoding DTS Coherent Acoustics streams used in DVD"
HOMEPAGE="http://www.videolan.org/dtsdec.html"
SRC_URI="http://www.videolan.org/pub/videolan/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 -x86-sunos"
IUSE="oss debug"
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-libtool.patch"
	epatch "${FILESDIR}/${P}-freebsd.patch"

	eautoreconf
}

src_compile() {
	econf $(use_enable oss) $(use_enable debug) || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO doc/libdts.txt
}
