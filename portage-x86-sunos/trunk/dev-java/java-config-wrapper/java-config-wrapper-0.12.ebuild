# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config-wrapper/java-config-wrapper-0.12.ebuild,v 1.1 2006/09/11 05:24:58 nichoj Exp $

inherit eutils
DESCRIPTION="Wrapper for java-config"
HOMEPAGE="http://www.gentoo.org/proj/en/java"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-sunos"
DEPEND="!<dev-java/java-config-1.3"
RDEPEND="app-portage/portage-utils"

IUSE=""

src_install() {
	dobin src/shell/*
}
