# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jdk/jdk-1.5.0.ebuild,v 1.9 2006/11/09 04:31:53 vapier Exp $

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.5"
KEYWORDS="amd64 ia64 ppc ppc64 x86 ~x86-fbsd ~x86-sunos"
IUSE=""

RDEPEND="|| (
		=dev-java/sun-jdk-1.5.0*
		=dev-java/sun-jdk-config-1.5.0*
		=dev-java/ibm-jdk-bin-1.5.0*
		=dev-java/jrockit-jdk-bin-1.5.0*
		=dev-java/diablo-jdk-1.5.0*
	)"
DEPEND=""
