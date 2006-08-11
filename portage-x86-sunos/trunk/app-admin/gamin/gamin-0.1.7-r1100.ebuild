# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.7.ebuild,v 1.15 2006/03/31 23:53:04 flameeyes Exp $

inherit autotools eutils libtool

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/gamin/sources/${P}.tar.gz
	kernel_FreeBSD? ( mirror://gentoo/${P}-freebsd.patch.bz2 )"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2
	!app-admin/fam"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PROVIDE="virtual/fam"

src_unpack() {
	unpack ${A}

	cd ${S}

	use kernel_FreeBSD && epatch "${DISTDIR}/${P}-freebsd.patch.bz2"

	# Do not remove
	elibtoolize
}

src_compile() {
	econf \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug) \
		$(use_enable debug debug-api) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog README TODO NEWS doc/*txt
	use doc && dohtml doc/*
}

pkg_postinst() {
	if use kernel_linux; then
		einfo "It is strongly suggested you use Gamin with an inotify enabled"
		einfo "kernel for best performance. For this release of gamin you need"
		einfo "at least gentoo-sources-2.6.13 or later."
	fi
}
