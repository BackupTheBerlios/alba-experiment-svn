# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/svn2cl/svn2cl-0.3.ebuild,v 1.1 2005/10/03 12:49:55 ka0ttic Exp $

inherit eutils

DESCRIPTION="Create a GNU-style ChangeLog from subversion's svn log --xml output."
HOMEPAGE="http://ch.tudelft.nl/~arthur/svn2cl/"
SRC_URI="${HOMEPAGE}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~mips x86-sunos"
IUSE=""

RDEPEND="dev-libs/libxslt
	dev-util/subversion"

src_unpack() {
	unpack ${A}
	cd ${S}
	# the wrapper script looks for the xsl file in the
	# same directory as the script.
	epatch ${FILESDIR}/${P}-no-same-dir-xsl.diff
	#[[ ${USERLAND} == "SunOS" ]] && sed -e 's%#!/bin/sh%#!/bin/bash%' -i ${PN}.sh
	use g-prefix && sed -e 's:[^g]awk:gawk:' -i ${PN}.sh
}

src_install() {
	newbin svn2cl.sh svn2cl || die "failed to install wrapper script"
	insinto /usr/share/svn2cl
	doins svn2cl.xsl || die "failed to install xsl"
	dodoc README
}