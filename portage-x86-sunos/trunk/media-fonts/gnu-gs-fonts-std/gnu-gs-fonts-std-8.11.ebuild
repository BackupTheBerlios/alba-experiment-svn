# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/gnu-gs-fonts-std/gnu-gs-fonts-std-8.11.ebuild,v 1.8 2006/04/02 17:44:38 flameeyes Exp $

MY_PN=ghostscript-fonts-std
MY_P=${MY_PN}-${PV}

DESCRIPTION="Ghostscript Standard Fonts"
HOMEPAGE="http://www.cups.org/"
SRC_URI="mirror://sourceforge/ghostscript/${MY_P}.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE=""

DEPEND=""

S=${WORKDIR}/fonts

src_install() {
	insinto /usr/share/fonts/default/ghostscript
	doins * || die
}
