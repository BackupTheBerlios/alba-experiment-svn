# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mysql/mysql-4.1.19.ebuild,v 1.9 2006/05/17 21:20:37 flameeyes Exp $

# Leave this empty
MYSQL_VERSION_ID=""
# Set the patchset revision to use, must be either empty or a decimal number
MYSQL_PATCHSET_REV="1"

inherit mysql

KEYWORDS="alpha amd64 ~arm hppa ~ia64 ppc ppc64 ~s390 ~sh sparc x86 ~x86-fbsd x86-sunos"

src_test() {
	cd "${S}"
	einfo ">>> Test phase [check]: ${CATEGORY}/${PF}"
	make check || die "make check failed"
	if ! useq "minimal" ; then
		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		local retstatus
		addpredict /this-dir-does-not-exist/t9.MYI

		cd mysql-test
		sed -i -e "s|PORT=3306|PORT=3307|g" mysql-test-run
		./mysql-test-run
		retstatus=$?

		# Just to be sure ;)
		pkill -9 -f "${S}/ndb" 2>/dev/null
		pkill -9 -f "${S}/sql" 2>/dev/null
		[[ $retstatus -eq 0 ]] || die "make test failed"
	else
		einfo "Skipping server tests due to minimal build."
	fi
}