# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXprintAppUtil/libXprintAppUtil-1.0.1.ebuild,v 1.13 2006/09/10 09:11:12 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XprintAppUtil library"

KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-sunos"

RDEPEND="x11-libs/libX11
	x11-libs/libXp
	x11-libs/libXprintUtil"
DEPEND="${RDEPEND}"
