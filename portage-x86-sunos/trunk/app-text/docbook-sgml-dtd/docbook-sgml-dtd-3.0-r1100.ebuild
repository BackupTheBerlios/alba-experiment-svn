# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-dtd/docbook-sgml-dtd-3.0-r3.ebuild,v 1.2 2005/07/15 16:54:46 leonardop Exp $

inherit sgml-catalog eutils

MY_P="docbk30"
DESCRIPTION="Docbook SGML DTD 3.0"
HOMEPAGE="http://www.oasis-open.org/docbook/sgml/3.0/index.html"
SRC_URI="http://www.oasis-open.org/docbook/sgml/${PV}/${MY_P}.zip"

LICENSE="X11"
SLOT="3.0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sparc x86 -x86-sunos"
IUSE=""

DEPEND=">=app-arch/unzip-5.41"
RDEPEND="app-text/sgml-common"

S="${WORKDIR}"

sgml-catalog_cat_include "/etc/sgml/sgml-docbook-${PV}.cat" \
	"/usr/share/sgml/docbook/sgml-dtd-${PV}/catalog"
sgml-catalog_cat_include "/etc/sgml/sgml-docbook-${PV}.cat" \
	"/etc/sgml/sgml-docbook.cat"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-catalog.diff || die
}

src_install () {

	insinto /usr/share/sgml/docbook/sgml-dtd-${PV}
	doins *.dcl *.dtd *.mod
	newins docbook.cat catalog

	dodoc *.txt
}
