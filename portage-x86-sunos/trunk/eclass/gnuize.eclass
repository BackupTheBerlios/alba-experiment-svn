# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Fabrizio Listello <flistello@gmail.com>
# Purpose: Commodoty functions for g-prefix and gnuize flags
#

ECLASS="gnuize"
INHERITED="$INHERITED $ECLASS"

_dognulinks() {
	local d=${1}
	local dest=${2}
	einfo "Creating links from ${d} in ${GNU_PREFIX}/${dest}"
	dodir ${ROOT}/${GNU_PREFIX}/${dest}
	cd ${d}
	local x
	for x in * ; do
		if [ -x ${x} ]; then
			if use g-prefix || [[ ${USERLAND} -ne "GNU" ]]; then
				dosym /${d}/${x} ${GNU_PREFIX}/${dest}/${x:1} #removes leading 'g'
			else
				dosym /${d}/${x} ${GNU_PREFIX}/${dest}/${x}
			fi
		fi
	done
}

create_gnulinks() {
	# Creates symlinks in /usr/gnu/bin and /usr/gnu/sbin
	# taking them from /bin /usr/bin /sbin and /usr/sbin
	[[ ! -z ${GNU_PREFIX} ]] || die "Environment variable GNU_PREFIX must be set."
	cd "${D}"
	for d in usr/bin bin; do
		if [ -d ${d} ]; then
			_dognulinks ${d} bin
		fi
	done
	for d in usr/sbin sbin; do
		if [ -d ${d} ]; then
			_dognulinks ${d} sbin
		fi
	done
}
