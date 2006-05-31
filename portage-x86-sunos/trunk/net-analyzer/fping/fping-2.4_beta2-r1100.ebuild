# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/fping/fping-2.4_beta2-r1.ebuild,v 1.15 2006/03/05 20:21:51 jokey Exp $

S=${WORKDIR}/fping-2.4b2_to
DESCRIPTION="A utility to ping multiple hosts at once"
SRC_URI="http://www.fping.com/download/fping-2.4b2_to.tar.gz"
HOMEPAGE="http://www.fping.com/"

SLOT="0"
LICENSE="fping"
KEYWORDS="x86 ppc sparc amd64 hppa alpha ia64 ppc64 x86-sunos"
IUSE=""

src_compile() {

	econf || die
	make || die
}

src_install () {

	dosbin fping
	doman fping.8
	dodoc ChangeLog README
}