# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXv/libXv-1.0.1.ebuild,v 1.7 2006/04/13 13:35:58 flameeyes Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xv library"
#HOMEPAGE="http://foo.bar.com/"
#SRC_URI="ftp://foo.bar.com/${P}.tar.bz2"
#LICENSE=""
#SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd x86-sunos"
#IUSE="X gnome"
RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/xextproto"
