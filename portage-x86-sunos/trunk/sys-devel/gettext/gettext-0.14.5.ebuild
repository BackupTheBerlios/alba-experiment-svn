# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.14.5.ebuild,v 1.18 2006/09/04 05:59:29 kumba Exp $

inherit flag-o-matic eutils toolchain-funcs mono libtool elisp-common gnuize

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/gettext.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="emacs nls doc nocxx g-prefix gnulinks"

DEPEND="virtual/libiconv"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epunt_cxx

	epatch "${FILESDIR}"/${PN}-0.14.1-lib-path-tests.patch #81628
	# java sucks
	epatch "${FILESDIR}"/${PN}-0.14.1-without_java.patch
	epatch "${FILESDIR}"/${PN}-0.14.2-no-java-tests.patch
	# Fix race, bug #85054
	epatch "${FILESDIR}"/${PN}-0.14.2-fix-race.patch

	# bundled libtool seems to be broken so skip certain rpath tests
	# http://lists.gnu.org/archive/html/bug-libtool/2005-03/msg00070.html
	sed -i \
		-e '2iexit 77' \
		autoconf-lib-link/tests/rpath-3*[ef] || die "sed tests"

	# use Gentoo std docdir
	sed -i \
		-e "/^docdir=/s:=.*:=/usr/share/doc/${PF}:" \
		gettext-runtime/configure \
		gettext-tools/configure \
		gettext-tools/examples/installpaths.in \
		|| die "sed docdir"

	if use ppc-macos ; then
		glibtoolize
		append-flags -bind_at_load
	fi

	# sanity check for Bug 105304
	if [[ -z ${USERLAND} ]] ; then
		eerror "You just hit Bug 105304, please post your 'emerge info' here:"
		eerror "http://bugs.gentoo.org/105304"
		die "Aborting to prevent screwing your system"
	fi
}

src_compile() {
	local myconf=""
	# Build with --without-included-gettext (on glibc systems)
	if use elibc_glibc ; then
		myconf="${myconf} --without-included-gettext $(use_enable nls)"
	else
		myconf="${myconf} --with-included-gettext --enable-nls"
	fi
	use emacs || export EMACS=no #93823
	use nocxx && export CXX=$(tc-getCC)
	use g-prefix && myconf='${myconf} --program-prefix=g'
	econf \
		--without-java \
		${myconf} \
		|| die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die "install failed"
	use nls || rm -r "${D}"/usr/share/locale
	dobin gettext-tools/misc/gettextize || die "gettextize"

	if use gnulinks ; then
		create_gnulinks
	else
		dosym msgfmt /usr/bin/gmsgfmt #43435
	fi

	# remove stuff that glibc handles
	if use elibc_glibc ; then
		rm -f "${D}"/usr/include/libintl.h
		rm -f "${D}"/usr/$(get_libdir)/libintl.*
	fi
	rm -f "${D}"/usr/share/locale/locale.alias "${D}"/usr/lib/charset.alias

	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	if use ppc-macos; then
		if [ -e "${ROOT}"/usr/$(get_libdir)/libintl.2.dylib ] ; then
			cp -pPR ${ROOT}/usr/$(get_libdir)/libintl.2.dylib ${D}/usr/$(get_libdir)/
			touch "${D}"/usr/$(get_libdir)/libintl.2.dylib
		fi
	else
		if [ -e "${ROOT}"/usr/$(get_libdir)/libintl.so.2 ] ; then
			cp -pPR ${ROOT}/usr/$(get_libdir)/libintl.so.2* ${D}/usr/$(get_libdir)/
			touch "${D}"/usr/$(get_libdir)/libintl.so.2*
		fi
	fi

	if ! use doc ; then
		rm -rf "${D}"/usr/share/doc/${PF}/html
		rm -rf "${D}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	dohtml "${D}"/usr/share/doc/${PF}/*.html
	rm -f "${D}"/usr/share/doc/${PF}/*.html

	# Remove emacs site-lisp stuff if 'emacs' is not in USE
	if use emacs ; then
		elisp-site-file-install "${FILESDIR}"/50po-mode-gentoo.el
	else
		rm -rf "${D}"/usr/share/emacs
	fi

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_postinst() {
	use emacs && elisp-site-regen
	ewarn "Any package that linked against the previous version"
	ewarn "of gettext will have to be rebuilt."
	ewarn "Please 'emerge gentoolkit' and run:"
	ewarn "revdep-rebuild --library libintl.so.2"
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
