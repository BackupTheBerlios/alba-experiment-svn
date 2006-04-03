# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/baselayout/baselayout-1.12.0_pre16-r3.ebuild,v 1.2 2006/03/03 00:48:05 uberlord Exp $

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="Filesystem baselayout addendum for Solaris based system"
HOMEPAGE="http://developer.berlios.de/projects/alba-experiment/"
SRC_URI="http://download.berlios.de/alba-experiment/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86-sunos"
IUSE="bootstrap build static unicode"

RDEPEND="!build? ( !bootstrap? (
		>=sys-libs/readline-5.0-r1
		>=app-shells/bash-3.0
		>=sys-apps/coreutils-5.2.1
	) )"
DEPEND="virtual/os-headers
	>=sys-apps/portage-2.0.51"
PROVIDE="virtual/baselayout"

src_install() {
	local dir libdirs libdirs_env rcscripts_dir

	dodir /usr/share/baselayout-sunos

	einfo "Creating directories..."
	for d in /etc /etc/conf.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly \
			/etc/cron.weekly /etc/env.d /etc/opt /opt /usr/gnu\
			${PORTDIR} ${PORTDIR_OVERLAY} /var/log/portage
			do
			if [ ! -d $d ]; then
				keepdir $d
			fi
	done
	dodir /var/db/pkg			# .keep file messes up Portage
	#
	# Setup files in /etc
	#
	insopts -m0644
	insinto /etc
	doins -r "${S}"/etc/*

	echo "Gentoo Base System version ${PV} - alba-experiment" > ${D}/etc/gentoo-release

	#
	# Setup files in /sbin
	#
	cd "${S}"/sbin
	into /
	dosbin *
}

