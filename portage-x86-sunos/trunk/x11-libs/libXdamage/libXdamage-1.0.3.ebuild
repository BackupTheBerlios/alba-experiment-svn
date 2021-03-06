# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXdamage/libXdamage-1.0.3.ebuild,v 1.7 2006/07/19 18:14:39 gmsoft Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Xdamage library"
#RESTRICT="mirror"
#HOMEPAGE="http://foo.bar.com/"
#SRC_URI="ftp://foo.bar.com/${P}.tar.bz2"
#LICENSE=""
#SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
#IUSE="X gnome"
RDEPEND="x11-libs/libX11
	x11-libs/libXfixes
	x11-proto/damageproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"
