# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/skippy/skippy-0.5.0.ebuild,v 1.10 2005/12/28 18:06:36 nelchael Exp $

inherit eutils flag-o-matic

IUSE=""

DESCRIPTION="A full-screen task-switcher providing Apple Expose-like functionality with various WMs"
HOMEPAGE="http://thegraveyard.org/skippy.php"
SRC_URI="http://thegraveyard.org/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-sunos"

RDEPEND="|| ( ( x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXinerama
		x11-libs/libXmu
		)
		virtual/x11
	)
	virtual/xft"

DEPEND="${RDEPEND}
	|| ( ( x11-proto/xproto
		x11-proto/xineramaproto
		)
		virtual/x11
	)
	>=media-libs/imlib2-1.1.0"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}-pointer-size.patch
}

src_compile() {
	use x86-sunos && append-flags -lrt
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} BINDIR=/usr/bin install || die

	insinto /usr/share/${P}
	doins skippyrc-default

	dodoc CHANGELOG
}

pkg_postinst() {
	einfo
	einfo "You should copy /usr/share/${P}/skippyrc-default to ~/.skippyrc"
	einfo "and edit the keysym used to invoke skippy"
	einfo "(Find out the keysym name using 'xev')"
	einfo
	echo
}
