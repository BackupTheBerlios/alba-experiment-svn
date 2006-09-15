# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/iceauth/iceauth-1.0.1.ebuild,v 1.12 2006/07/19 13:51:39 gmsoft Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org iceauth application"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RDEPEND="x11-libs/libX11
	x11-libs/libICE"
DEPEND="${RDEPEND}"
