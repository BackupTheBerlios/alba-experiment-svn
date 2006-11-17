# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Fabrizio Listello (flistello@gmail.com)
# Purpose: adds some utility functions for manage / install sun SMF services
#

ECLASS="sun-smf-utils"
INHERITED="$INHERITED $ECLASS"

smf_install() {
	local svcdescfile="sun-svc-${PN}.xml"
	einfo "Importing Service Definition \"${svcdescfile}\""
	einfo "/usr/sbin/svccfg import ${FILESDIR}/${svcdescfile}"
	/usr/sbin/svccfg import ${FILESDIR}/${svcdescfile} || eerror "Cannot import Service Definition"
	einfo "Solaris service description installed."
	einfo "To make GDM start at boot, execute:"
	einfo " svcadm enable ${PN}"
}

smf_delete() {
	einfo "Deleting Service Definition \"${PN}:default\""
	/usr/sbin/svccfg delete -f ${PN}:default || eerror "Cannot remove service definition"
	einfo "${PN} removed from startup"

}

