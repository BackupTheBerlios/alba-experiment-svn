# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jss/jss-3.4.ebuild,v 1.9 2005/08/05 16:06:59 betelgeuse Exp $

inherit eutils java-pkg versionator

RTM_NAME="JSS_${PV//./_}_RTM"
DESCRIPTION="Network Security Services for Java (JSS)"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/jss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/${PN}/releases/${RTM_NAME}/src/${P}-src.tar.gz"

LICENSE="MPL-1.1"
SLOT="3.4"
KEYWORDS="amd64 sparc x86 -x86-sunos"
IUSE=""

RDEPEND=">=virtual/jre-1.4
		>=dev-libs/nspr-4.3
		>=dev-libs/nss-3.9.2"
DEPEND=">=virtual/jdk-1.4
		${RDEPEND}
		app-arch/zip
		>=sys-apps/sed-4"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}
	cd ${S}/mozilla/security/coreconf
	case ${CHOST} in
		*-linux*)
			cp Linux2.5.mk Linux$(get_version_component_range 1-3 ${KV}).mk
			cp Linux2.5.mk Linux$(get_version_component_range 1-2 ${KV}).mk
			;;
		*-solaris*)
			cp ${FILESDIR}/SunOS5.11_i86pc.mk ${S}/mozilla/security/coreconf
			;;
	esac

	echo "INCLUDES += -I${ROOT}usr/include/nss -I${ROOT}usr/include/nspr" \
		>> ${S}/mozilla/security/coreconf/headers.mk

	if use x86; then
		gsed -e 's:-L$(DIST)/lib:-L/usr/lib/nspr -L/usr/lib/nss -L$(JAVA_HOME)/jre/lib/i386 -L$(JAVA_HOME)/jre/lib/i386/server -L$(DIST)/lib:' \
			-i ${S}/mozilla/security/jss/lib/config.mk
	elif use amd64; then
		gsed -e 's:-L$(DIST)/lib:-L/usr/lib/nspr -L/usr/lib/nss -L$(JAVA_HOME)/jre/lib/amd64 -L$(JAVA_HOME)/jre/lib/amd64/server -L$(DIST)/lib:' \
			-i ${S}/mozilla/security/jss/lib/config.mk
	elif use sparc; then
		gsed -e 's:-L$(DIST)/lib:-L/usr/lib/nspr -L/usr/lib/nss -L$(JAVA_HOME)/jre/lib/sparc -L$(JAVA_HOME)/jre/lib/sparc/server -L$(DIST)/lib:' \
			-i ${S}/mozilla/security/jss/lib/config.mk
	fi
}

src_compile() {
	local myconf;
	use gcc && myconf="NS_USE_GCC=1"
	cd ${S}/mozilla/security/coreconf
	emake -j1 BUILD_OPT=1 $myconf || die "coreconf make failed"

	cd ${S}/mozilla/security/jss
	emake -j1 BUILD_OPT=1 $myconf || die "nss make failed"
}

src_install() {
	cd ${S}/mozilla/dist/classes*
	zip -q -r ../jss34.jar . || die "zip failed"
	java-pkg_dojar ../jss34.jar

	cd ${S}
	java-pkg_doso mozilla/dist/Linux*/lib/libjss3.so
}
