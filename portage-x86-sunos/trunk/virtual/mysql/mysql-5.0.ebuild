# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.0.ebuild,v 1.3 2006/11/25 13:12:28 corsair Exp $

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE="http://dev.mysql.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ~ia64 ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd ~x86-sunos"
IUSE=""

DEPEND=""
RDEPEND="|| (
	=dev-db/mysql-${PV}*
	=dev-db/mysql-community-${PV}*
)"
