# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xcmiscproto/xcmiscproto-1.1.2.ebuild,v 1.15 2006/08/06 16:47:23 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XCMisc protocol headers"

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
