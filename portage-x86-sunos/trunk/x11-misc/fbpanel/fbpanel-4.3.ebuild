# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/fbpanel/fbpanel-4.3.ebuild,v 1.5 2005/09/25 15:50:32 ka0ttic Exp $

inherit toolchain-funcs

DESCRIPTION="fbpanel is a light-weight X11 desktop panel"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"
HOMEPAGE="http://fbpanel.sourceforge.net/"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha ~amd64 ppc x86 ~x86-sunos"
IUSE=""

DEPEND=">=x11-libs/gtk+-2
	>=sys-apps/sed-4"
RDEPEND=">=x11-libs/gtk+-2"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e '/^CFLAGS/d;/^CC/d' Makefile.common
}

src_compile() {
	# econf not happy here
	./configure --prefix=/usr || die "Configure failed."
	emake CHATTY=1 CC=$(tc-getCC) || die "Make failed."
}

src_install () {
	emake install PREFIX=${D}/usr || die
	dodoc README CREDITS COPYING CHANGELOG
}
