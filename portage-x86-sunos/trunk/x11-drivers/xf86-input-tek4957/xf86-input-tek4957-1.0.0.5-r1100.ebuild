# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-tek4957/xf86-input-tek4957-1.0.0.5.ebuild,v 1.11 2006/04/16 13:03:30 flameeyes Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org driver for tek4957 input devices"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd -x86-sunos"
RDEPEND="x11-base/xorg-server"
DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/randrproto
	x11-proto/xproto"
