# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/aalib/aalib-1.4_rc4-r2.ebuild,v 1.35 2006/04/03 05:11:23 eradicator Exp $

inherit eutils libtool

MY_P="${P/_/}"
S="${WORKDIR}/${PN}-1.4.0"

DESCRIPTION="A ASCII-Graphics Library"
HOMEPAGE="http://aa-project.sourceforge.net/aalib/"
SRC_URI="mirror://sourceforge/aa-project/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc-macos ppc64 s390 sh sparc x86 x86-sunos"
IUSE="X slang gpm static"

RDEPEND="X? ( || ( x11-libs/libX11 virtual/x11 ) )"

DEPEND="${RDEPEND}
	>=sys-libs/ncurses-5.1
	X? ( || ( x11-proto/xproto virtual/x11 ) )
	gpm? ( sys-libs/gpm )
	slang? ( >=sys-libs/slang-1.4.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-m4.patch
	if use ppc-macos; then
		cd src
		epatch "${FILESDIR}"/${PN}-osx.patch
	fi
	elibtoolize
}

src_compile() {
	econf \
		$(use_with slang slang-driver) \
		$(use_with X x11-driver) \
		$(use_enable static) \
		|| die
	if use ppc-macos && use X; then
		sed -i -e 's:aafire_LDFLAGS =:aafire_LDFLAGS = -undefined define_a_way:' \
		${S}/src/Makefile || die "Failed to edit Makefile for X compatibility"
	fi
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README*
}
