# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.7-r1.ebuild,v 1.24 2006/09/19 13:46:35 antarus Exp $

inherit libtool eutils flag-o-matic autotools

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://www.rpm.org/"
SRC_URI="ftp://ftp.rpm.org/pub/rpm/dist/rpm-4.1.x/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )
	=sys-devel/automake-1.6*"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-missing-tests.patch
	epatch "${FILESDIR}"/${P}-nls.patch
	use nls || touch ../rpm.c

	eautomake
	elibtoolize
}

src_compile() {
	use ppc-macos && append-ldflags -undefined dynamic_lookup
	econf $(use_enable nls) || die
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc CHANGES README
}
