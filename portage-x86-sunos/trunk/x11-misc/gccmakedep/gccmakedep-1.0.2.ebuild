# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/gccmakedep/gccmakedep-1.0.2.ebuild,v 1.8 2006/09/10 08:46:08 vapier Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org gccmakedep utility"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"
