# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/font-adobe-utopia-type1/font-adobe-utopia-type1-1.0.1.ebuild,v 1.13 2006/07/19 18:20:53 gmsoft Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular


DESCRIPTION="X.Org Adobe Utopia Type 1 fonts"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RDEPEND=""
DEPEND="${RDEPEND}
	media-libs/fontconfig"
