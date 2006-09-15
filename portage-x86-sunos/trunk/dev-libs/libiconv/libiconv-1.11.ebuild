# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.11.ebuild,v 1.5 2006/08/05 13:19:36 dertobi123 Exp $

inherit eutils multilib flag-o-matic autotools libtool

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/libiconv/"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~x86-fbsd ~x86-sunos"
IUSE="build"

DEPEND="!sys-libs/glibc"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This patch is needed as libiconv 1.10 provides (and uses) new functions
	# and they are not present in the old libiconv.so, and this breaks the
	# ${DESTDIR} != ${prefix} that we use. It's a problem for Solaris, but we
	# don't have to deal with it for now.
	epatch "${FILESDIR}/${PN}-1.10-link.patch"

	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD.
	elibtoolize
}

src_compile() {
	# Filter -static as it breaks compilation
	filter-ldflags -static

	local myconf=""
	if use x86-sunos; then
		myconf="${myconf} \
			--includedir=/usr/gnu/include \
			--bindir=/usr/gnu/bin"
	fi

	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext

	econf \
		--disable-nls \
		--enable-shared \
		--enable-static \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir="/usr/share/doc/${PF}/html" install || die "make install failed"
	
	if ! use sun-ld; then
		# Move static libs and creates ldscripts into /usr/lib
		dodir /$(get_libdir)
		mv "${D}"/usr/$(get_libdir)/*.so* "${D}/$(get_libdir)"
		gen_usr_ldscript libiconv.so
		gen_usr_ldscript libcharset.so
	fi
	
	if use x86-sunos; then
		dodir /usr/bin
		dosym /usr/gnu/bin/iconv /usr/bin/giconv
	fi

	use build && rm -rf "${D}/usr"

	preserve_old_lib /usr/$(get_libdir)/libiconv.so.4
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libiconv.so.4
}
