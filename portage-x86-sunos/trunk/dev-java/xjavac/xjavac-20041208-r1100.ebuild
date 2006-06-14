# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xjavac/xjavac-20041208-r1.ebuild,v 1.3 2005/11/13 21:00:22 hansmi Exp $

inherit java-pkg

DESCRIPTION="The implementation of the javac compiler for IBM JDK 1.4 (needed for xerces-2)"
SRC_URI="mirror://gentoo/${P}.tar.gz"
HOMEPAGE="http://cvs.apache.org/viewcvs.cgi/xml-xerces/java/tools/src/XJavac.java"
LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="amd64 ppc ppc64 sparc x86 x86-sunos"
IUSE="jikes"
DEPEND=">=virtual/jdk-1.4
	jikes? ( >=dev-java/jikes-1.21 )
	>=dev-java/ant-core-1.4"
RDEPEND=">=virtual/jdk-1.4"

src_unpack() {
	unpack ${A}
	cd ${S}

	cp ${FILESDIR}/${P}-build.xml ./build.xml
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "failed to build"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodir /usr/share/ant-core/lib/
	dosym /usr/share/${PN}-${SLOT}/lib/${PN}.jar /usr/share/ant-core/lib/
}