# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/aspell/aspell-0.50.5-r4.ebuild,v 1.15 2006/06/05 03:26:24 vapier Exp $

inherit libtool eutils flag-o-matic

DESCRIPTION="A spell checker replacement for ispell"
HOMEPAGE="http://aspell.net/"
SRC_URI="mirror://gnu/aspell/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86 ~x86-sunos"
IUSE="gpm"

DEPEND=">=sys-libs/ncurses-5.2
	gpm? ( sys-libs/gpm )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.50.5-charcount.patch
	epatch "${FILESDIR}"/${PN}-quotechar-fix.patch
}

src_compile() {
	if [ "${ARCH}" == "ppc" ] || [ "${ARCH}" == "ppc-macos" ]; then
		append-flags -O2 -fsigned-char
	fi
	if [ "${ARCH}" == "alpha" ]; then
		replace-flags -Os -O2
	fi
	use gpm && append-ldflags -lgpm
	filter-flags -fno-rtti
	elibtoolize --reverse-deps

	econf \
		--disable-static \
		--sysconfdir=/etc/aspell \
		--enable-docdir=/usr/share/doc/${PF} || die

	emake || die
}

src_install() {
	dodoc README* TODO

	make DESTDIR=${D} install || die
	mv ${D}/usr/share/doc/${PF}/man-html ${D}/usr/share/doc/${PF}/html
	mv ${D}/usr/share/doc/${PF}/man-text ${D}/usr/share/doc/${PF}/text

	# install ispell/aspell compatibility scripts
	exeinto /usr/bin
	newexe scripts/ispell ispell-aspell
	newexe scripts/spell spell-aspell

	cd examples
	make clean || die
	docinto examples
	dodoc ${S}/examples/*

}

pkg_postinst() {
	einfo "You will need to install a dictionary now.  Please choose an"
	einfo "aspell-<LANG> dictionary from the app-dicts category"
	einfo "After installing an aspell dictionary for your language(s),"
	einfo "You may use the aspell-import utility to import your personal"
	einfo "dictionaries from ispell, pspell and the older aspell"

	ewarn ""
	ewarn "Please re-emerge ALL your aspell-LANG dictionaries"
	ewarn ""
	ebeep 5
}
