# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.3.ebuild,v 1.7 2005/11/26 01:03:35 vapier Exp $

inherit eutils flag-o-matic

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://www.gzip.org/zlib/${P}.tar.bz2
	http://www.zlib.net/${P}.tar.bz2"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 -x86-sunos"
IUSE="build"

RDEPEND=""

src_compile() {
	tc-export CC RANLIB
	export AR="$(tc-getAR) rc"
	[[ ${USERLAND} == "SunOS" ]] && unset CFLAGS
	./configure --shared --prefix=/usr --libdir=/$(get_libdir) || die
	emake || die
}

src_install() {
	einstall libdir="${D}"/$(get_libdir) || die
	[[ ${USERLAND} != "SunOS" ]] && rm "${D}"/$(get_libdir)/libz.a
	insinto /usr/include
	doins zconf.h zlib.h

	if ! use build ; then
		doman zlib.3
		dodoc FAQ README ChangeLog
		docinto txt
		dodoc algorithm.txt
	fi

	# we don't need the static lib in /lib
	# as it's only for compiling against
	dolib libz.a

	# all the shared libs go into /lib
	# for NFS based /usr
	into /
	dolib libz.so.${PV}
	( cd "${D}"/$(get_libdir) ; chmod 755 libz.so.* )
	dosym libz.so.${PV} /$(get_libdir)/libz.so
	dosym libz.so.${PV} /$(get_libdir)/libz.so.1
	[[ ${USERLAND} != "SunOS" ]] && gen_usr_ldscript libz.so
}
