# Copyright 1999-200es Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.0.2.ebuild,v 1.11 2006/03/12 07:36:06 vapier Exp $

inherit eutils flag-o-matic

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"
LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 x86-sunos"
IUSE="gtk numeric svg"

DEPEND=">=dev-lang/python-2.3
	>=x11-libs/cairo-1.0.2
	gtk? ( >=dev-python/pygtk-2.2 )
	svg? ( >=x11-libs/libsvg-cairo-0.1.6 )
	numeric? ( dev-python/numeric )"

src_compile() {
	use x86-sunos && append-flags "-D_XPG6"
	# dev-python/numeric and libsvg-cairo are automatically 
	# detected by the ./configure script, so don't need to force
	econf $(use_with gtk pygtk)
	emake || die "emake failed"
}

src_install() {
	einstall || die "install failed"

	insinto /usr/share/doc/${PF}/examples
	doins -r examples/*
	rm ${D}/usr/share/doc/${PF}/examples/Makefile*

	dodoc AUTHORS NOTES README NEWS ChangeLog
}
