# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/rgb/rgb-1.0.1.ebuild,v 1.8 2006/07/19 13:48:40 gmsoft Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org rgb application"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RDEPEND="x11-libs/libXt"
DEPEND="${RDEPEND}
	x11-proto/xproto"
