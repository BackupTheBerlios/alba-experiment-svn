# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.0.1.ebuild,v 1.6 2006/07/10 13:01:39 agriffis Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xtrans library"
RESTRICT="mirror"
KEYWORDS="alpha amd64 arm ~hppa ia64 ~m68k mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd x86-sunos"
RDEPEND=""
DEPEND="${RDEPEND}"
