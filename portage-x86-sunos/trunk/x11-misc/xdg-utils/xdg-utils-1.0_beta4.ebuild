# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xdg-utils/xdg-utils-1.0_beta4.ebuild,v 1.1 2006/09/15 14:26:05 genstef Exp $

MY_P="${P/_}"
DESCRIPTION="Portland utils for cross-platform/cross-toolkit/cross-desktop interoperability"
HOMEPAGE="http://portland.freedesktop.org/wiki/Portland"
SRC_URI="http://portland.freedesktop.org/download/${MY_P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-sunos"
IUSE=""
RESTRICT="test"

DEPEND=""
RDEPEND="|| ( x11-apps/xprop <virtual/x11-7 )"

S=${WORKDIR}/${MY_P}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README TODO
}
