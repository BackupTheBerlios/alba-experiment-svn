# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/xcursor-themes/xcursor-themes-1.0.1.ebuild,v 1.12 2006/09/10 18:25:23 the_paya Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org cursor themes: whiteglass, redglass and handhelds"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-sunos"
RDEPEND="x11-libs/libX11
	x11-libs/libXcursor
	=media-libs/libpng-1.2*"
DEPEND="${RDEPEND}
	x11-apps/xcursorgen"
