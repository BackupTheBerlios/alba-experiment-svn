# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/mplayer-bin/mplayer-bin-1.0.20060415.ebuild,v 1.1 2006/04/18 21:21:50 dang Exp $

inherit multilib

DESCRIPTION="Pre-build wificonfig binary for x86-sunox systems"
HOMEPAGE="http://www.opensolaris.org/os/community/laptop/wireless/wificonfig/"
SRC_URI="http://www.opensolaris.org/os/community/laptop/downloads/wificonfig-${PV}-bin.tar.gz"

LICENSE="CDDL"
SLOT="0"
KEYWORDS="-* x86-sunos"
IUSE=""

RDEPEND=""

DEPEND=""

S=${WORKDIR}

RESTRICT="nostrip"

src_install() {
	dodir /opt/wificonfig-bin/bin
	cp -pPRvf ${WORKDIR}/wificonfig ${D}/opt/wificonfig-bin/bin

	dodir /usr/bin
	dosym /opt/wificonfig-bin/bin/wificonfig /usr/bin/wificonfig
}
