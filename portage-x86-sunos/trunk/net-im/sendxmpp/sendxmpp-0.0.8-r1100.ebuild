# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/sendxmpp/sendxmpp-0.0.8.ebuild,v 1.3 2006/03/05 20:23:50 gmsoft Exp $

inherit eutils
DESCRIPTION="sendxmpp is a perl-script to send xmpp (jabber), similar to what mail(1) does for mail."
HOMEPAGE="http://www.djcbsoftware.nl/code/sendxmpp/"
SRC_URI="http://www.djcbsoftware.nl/code/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="hppa sparc ~x86 x86-sunos"
IUSE=""
RESTRICT="nomirror"
DEPEND="dev-perl/Net-XMPP"
#RDEPEND=""

#S=${WORKDIR}/${P}

src_compile() {
	perl Makefile.PL \
		PREFIX=/usr DESTDIR=${D}

	make || die "make failed"
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc Changes README INSTALL
}