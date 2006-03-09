# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.1.4.ebuild,v 1.4 2005/12/07 01:05:02 vapier Exp $

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Various ELF related utils for ELF32, ELF64 binaries useful for displaying PaX and security info on a large groups of bins"
HOMEPAGE="http://www.gentoo.org/proj/en/hardened"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 x86-sunos"
IUSE="caps"

DEPEND="caps? ( sys-libs/libcap )"

src_compile() {
	if use caps ; then
		append-flags -DWANT_SYSCAP
		append-ldflags -lcap
	fi
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" all || die
}

src_install() {
	make DESTDIR="${D}" install || die
}
