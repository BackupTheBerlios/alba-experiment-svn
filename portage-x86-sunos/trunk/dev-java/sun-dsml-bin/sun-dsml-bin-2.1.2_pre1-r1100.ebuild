# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-dsml-bin/sun-dsml-bin-2.1.2_pre1.ebuild,v 1.5 2005/07/18 17:10:07 axxo Exp $

inherit java-pkg

At="dsmlv2-1_2-ea1.zip"
DESCRIPTION="Java Naming and Directory Interface (JNDI) DSML Service Provider"
HOMEPAGE="http://java.sun.com/developer/earlyAccess/jndi/"
SRC_URI="${At}"

LICENSE="sun-bcla-dsml"
SLOT="2"
KEYWORDS="x86 amd64 ~ppc x86-sunos"
IUSE="doc"

DEPEND=">=app-arch/unzip-5.50-r1"
RDEPEND=">=virtual/jre-1.4"
RESTRICT="fetch"

S=${WORKDIR}

DOWNLOAD_URL="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=7022-jndi_dsml-2.0-ea-oth-JPR&SiteId=DSC&TransactionId=noreg"

pkg_nofetch() {
	einfo
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " distributables automagically."
	einfo
	einfo " 1. Visit ${HOMEPAGE}"
	einfo "    Direct link: ${DOWNLOAD_URL}"
	einfo " 2. Download ${At}"
	einfo " 3. Move file to ${DISTDIR}"
	einfo
}

src_install() {
	dodoc README-DSMLv2.txt
	if use doc; then
		java-pkg_dohtml -r docs/*
	fi
	java-pkg_dojar lib/*.jar
}
