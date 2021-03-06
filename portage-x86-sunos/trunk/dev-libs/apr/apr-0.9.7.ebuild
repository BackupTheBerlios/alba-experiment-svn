# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-0.9.7.ebuild,v 1.11 2006/05/18 18:14:40 vericgar Exp $

inherit flag-o-matic libtool

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ~ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="ipv6 urandom"
RESTRICT="test"

DEPEND=""

src_compile() {

	filter-ldflags -Wl,--as-needed --as-needed

	elibtoolize || die "elibtoolize failed"

	myconf="--datadir=/usr/share/apr-0"

	myconf="${myconf} $(use_enable ipv6)"
	myconf="${myconf} --enable-threads"
	myconf="${myconf} --enable-nonportable-atomics"
	if use urandom; then
		einfo "Using /dev/urandom as random device"
		myconf="${myconf} --with-devrandom=/dev/urandom"
	else
		einfo "Using /dev/random as random device"
		myconf="${myconf} --with-devrandom=/dev/random"
	fi

	econf ${myconf} || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" installbuilddir=/usr/share/apr-0/build install || die

	# bogus values pointing at /var/tmp/portage
	sed -i -e 's:APR_SOURCE_DIR=.*:APR_SOURCE_DIR=/usr/share/apr-0:g' ${D}/usr/bin/apr-config
	sed -i -e 's:APR_BUILD_DIR=.*:APR_BUILD_DIR=/usr/share/apr-0/build:g' ${D}/usr/bin/apr-config

	sed -i -e 's:apr_builddir=.*:apr_builddir=/usr/share/apr-0/build:g' ${D}/usr/share/apr-0/build/apr_rules.mk
	sed -i -e 's:apr_builders=.*:apr_builders=/usr/share/apr-0/build:g' ${D}/usr/share/apr-0/build/apr_rules.mk

	cp -p build/*.awk ${D}/usr/share/apr-0/build
	cp -p build/*.sh ${D}/usr/share/apr-0/build
	cp -p build/*.pl ${D}/usr/share/apr-0/build

	dodoc CHANGES LICENSE NOTICE
}
