# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libsvg-cairo/libsvg-cairo-0.1.6.ebuild,v 1.19 2006/09/10 00:17:35 the_paya Exp $

DESCRIPTION="Render SVG content using cairo"
HOMEPAGE="http://xsvg.org/"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ~ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE=""

DEPEND=">=x11-libs/cairo-0.5.0
	>=media-libs/libsvg-0.1.2"

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README
}
