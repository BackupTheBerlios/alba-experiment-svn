# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xproto/xproto-7.0.7.ebuild,v 1.9 2006/08/22 20:56:43 fmccor Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xproto protocol headers"

KEYWORDS="~alpha ~amd64 arm ~hppa ia64 m68k ~mips ~ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
RESTRICT="mirror"
IUSE='sun-ld'

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_unpack_source
	x-modular_reconf_source
	# Solaris Sun ld does not support __visibility__("hidden")
	use sun-ld && epatch ${FILESDIR}/Xfuncproto-sun-ld-visibility-path.diff
}
