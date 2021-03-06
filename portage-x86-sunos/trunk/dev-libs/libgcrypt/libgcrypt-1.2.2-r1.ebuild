# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.2.2-r1.ebuild,v 1.17 2006/10/19 15:53:59 uberlord Exp $

inherit eutils libtool

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.gz
	mirror://gentoo/${PN}-1.2.1-patches.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd ~x86-sunos"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )
	dev-libs/libgpg-error"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	epunt_cxx

	# fix for miss detection of 32 bit ppc
	cd "${S}"
	epatch "${WORKDIR}"/${PN}-1.2.1-ppc64-fix.patch

#	cd ${S}
#	epatch ${WORKDIR}/${PN}-1.2.1-GNU-stack-fix.patch

	elibtoolize
	${SED:-sed} -i -e "s:^LDADD = ../src/libgcrypt.la:LDADD = ../src/libgcrypt.la ../cipher/libcipher.la:" ${S}/tests/Makefile.in
}

src_compile() {
	local myconf

	use ppc64 && myconf="${myconf} --disable-asm"

	econf $(use_enable nls) --disable-dependency-tracking --with-pic \
		--enable-noexecstack ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog NEWS README* THANKS TODO VERSION

	# backwards compat symlinks
	if use ppc-macos ; then
		dosym libgcrypt.11.dylib /usr/lib/libgcrypt.7.dylib
	else
		dosym libgcrypt.so.11 /usr/lib/libgcrypt.so.7
	fi
}
