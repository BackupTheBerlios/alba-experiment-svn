# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.9.6-r1.ebuild,v 1.4 2005/11/05 04:06:48 vapier Exp $

inherit eutils

DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://sources.redhat.com/automake/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 ~ppc-macos s390 sh sparc x86 x86-sunos"
IUSE=""

# stupid blocker for stupid package #98762
RDEPEND="!app-text/dgs
	dev-lang/perl
	sys-devel/automake-wrapper
	>=sys-devel/autoconf-2.59-r6
	>=sys-apps/texinfo-4.7
	sys-devel/gnuconfig"
DEPEND="${RDEPEND}
	sys-apps/help2man"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "/^@setfilename/s|automake|automake${SLOT}|" \
		-e "s|automake: (automake)|automake v${SLOT}: (automake${SLOT})|" \
		-e "s|aclocal: (automake)|aclocal v${SLOT}: (automake${SLOT})|" \
		doc/automake.texi || die "sed failed"
	epatch "${FILESDIR}"/${PN}-1.9.6-infopage-namechange.patch
	epatch "${FILESDIR}"/${P}-include-dir-prefix.patch #107435
	export WANT_AUTOCONF=2.5
}

src_install() {
	make DESTDIR="${D}" install || die

	local x
	for x in aclocal automake ; do
		help2man ${x} > ${x}.1
		doman ${x}.1
		rm -f "${D}"/usr/bin/${x}
	done

	dodoc NEWS README THANKS TODO AUTHORS ChangeLog
	doinfo doc/*.info*

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}