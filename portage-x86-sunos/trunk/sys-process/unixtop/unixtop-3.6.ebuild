# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/atop/atop-1.15.ebuild,v 1.3 2006/03/11 20:47:17 deltacow Exp $

inherit eutils bash-completion flag-o-matic

DESCRIPTION="The process viewer"
HOMEPAGE=""
SRC_URI="mirror://sourceforge/${PN}/top-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86-sunos"
IUSE=""

src_unpack() {
    unpack ${A} || die "unpack failed"
}

src_compile() {
	cd ${WORKDIR}/top-${PV}
	econf || die "econf failed"
}

src_install() {
	cd ${WORKDIR}/top-${PV}
    make DESTDIR=${D} install || die "make install failed"
	dodoc AUTHORS Changes README LICENCE Porting Y2K INSTALL
}
