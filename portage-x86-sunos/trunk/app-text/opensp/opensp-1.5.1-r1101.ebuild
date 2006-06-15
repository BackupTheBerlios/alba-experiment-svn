# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/opensp/opensp-1.5.1.ebuild,v 1.12 2005/11/28 18:38:37 hanno Exp $

inherit eutils flag-o-matic

MY_P=${P/opensp/OpenSP}
S=${WORKDIR}/${MY_P}
DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="http://openjade.sourceforge.net/"
SRC_URI="mirror://sourceforge/openjade/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sparc x86 x86-sunos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
PDEPEND=">=app-text/openjade-1.3.2"

# Note: openjade is in PDEPEND because starting from openjade-1.3.2, opensp
#       has been SPLIT from openjade into its own package. Hence if you
#       install this, you need to upgrade to a new openjade as well.


src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.5-gcc34.patch
	epatch ${FILESDIR}/opensp-1.5.1-gcc41.patch
}

src_compile() {
	#
	# The following filters are taken from openjade's ebuild. See bug #100828.
	#

	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	# Default CFLAGS and CXXFLAGS is -O2 but this make openjade segfault
	# on hppa. Using -O1 works fine. So I force it here.
	use hppa && replace-flags -O2 -O1
	use x86-sunos && replace-flags -O2 -O1

	myconf="--enable-http"
	myconf="${myconf} --enable-default-catalog=/etc/sgml/catalog"
	myconf="${myconf} --enable-default-search-path=/usr/share/sgml"
	myconf="${myconf} --datadir=/usr/share/sgml/${P}"
	# Added becasue otherwise we have segfaults on Solaris x86.
	use x86-sunos && myconf="{myconf}  --disable-shared --enable-static"
	econf ${myconf} $(use_enable nls) || die "econf failed"
	emake pkgdocdir=/usr/share/doc/${PF} || die "parallel make failed"
}

src_install() {
	make DESTDIR="${D}" pkgdocdir=/usr/share/doc/${PF} install || die
}
