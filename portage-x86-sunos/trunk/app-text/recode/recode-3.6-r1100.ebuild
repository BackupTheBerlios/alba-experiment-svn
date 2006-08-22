# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/recode/recode-3.6-r2.ebuild,v 1.17 2006/08/17 01:08:50 tcort Exp $

inherit flag-o-matic eutils libtool toolchain-funcs

DEB_VER=11
DESCRIPTION="Convert files between various character sets"
HOMEPAGE="http://recode.progiciels-bpi.ca/"
SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-debian-${DEB_VER}.patch

	# Needed under FreeBSD, too
	epatch "${FILESDIR}"/${P}-ppc-macos.diff
	cp lib/error.c lib/xstrdup.c src/ || die "file copy failed"

	if use ppc-macos; then
		append-ldflags -lgettextlib -lintl
	fi
	elibtoolize
}

src_compile() {
	tc-export CC LD
	econf $(use_enable nls) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BACKLOG ChangeLog NEWS README THANKS TODO
	rm -f "${D}"/usr/lib/charset.alias
}
