# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jad-bin/jad-bin-1.5.8e.ebuild,v 1.7 2005/07/16 11:47:58 axxo Exp $

DESCRIPTION="Jad - The fast JAva Decompiler"
HOMEPAGE="http://www.kpdus.com/jad.html"
SRC_URI="x86? (http://www.kpdus.com/jad/linux/jadls158.zip)
		amd64? (http://www.kpdus.com/jad/linux/jadls158.zip)
		x86-sunos? (http://www.kpdus.com/jad/solaris/jadsx8158.zip)"
DEPEND="app-arch/unzip"
RDEPEND=""
KEYWORDS="amd64 -ppc x86 -x86-sunos"
SLOT="0"
LICENSE="freedist"
IUSE=""

S=${WORKDIR}

src_install() {
	into /opt
	dobin jad
	dodoc Readme.txt
}
