# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/which/which-2.16.ebuild,v 1.19 2005/10/28 23:11:36 vapier Exp $

inherit eutils gnuize

DESCRIPTION="Prints out location of specified executables that are in your path"
HOMEPAGE="http://www.xs4all.nl/~carlo17/which/"
SRC_URI="http://www.xs4all.nl/~carlo17/which/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-sunos"
IUSE="g-prefix gnulinks"

DEPEND="sys-apps/texinfo"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/which-gentoo.patch
	use g-prefix && EXTRA_ECONF="--program-prefix=g"
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS EXAMPLES NEWS README*
	if use gnulinks; then
		create_gnulinks
	fi
}
