# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/foomatic-db-engine/foomatic-db-engine-3.0.2.ebuild,v 1.12 2005/11/28 13:19:23 mcummings Exp $

inherit perl-app eutils

DESCRIPTION="Foomatic printer database engine"
HOMEPAGE="http://www.linuxprinting.org/foomatic.html"
SRC_URI="http://www.linuxprinting.org/download/foomatic/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sparc x86 x86-sunos"
IUSE=""

DEPEND="dev-libs/libxml2
	net-misc/wget
	net-misc/curl
	net-print/foomatic-filters"

src_compile() {
	epatch ${FILESDIR}/perl-module-3.0.1.diff
	econf || die
	make || die
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
	# install perl modules
	cd lib
	perl-app_src_prep
	perl-app_src_compile
	perl-module_src_test
	perl-module_src_install
}