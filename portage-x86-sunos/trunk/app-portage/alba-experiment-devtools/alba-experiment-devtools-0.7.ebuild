# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit-dev/gentoolkit-dev-0.2.5.ebuild,v 1.3 2005/12/16 02:51:40 vapier Exp $

DESCRIPTION="Collection of developer scripts for Gentoo/Solaris aka alba-experiment"
HOMEPAGE="http://developer.berlios.de/projects/alba-experiment/"
SRC_URI="http://download.berlios.de/alba-experiment/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-sunos"
IUSE=""

DEPEND=">=sys-apps/portage-2.0.50
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4"

src_install() {
	cd "${S}"/conf.d
	insinto /etc/conf.d
	doins alba-experiment-devtools.conf

	for d in bin tools ; do
		dodir /usr/share/alba-experiment/${d}
		exeinto /usr/share/alba-experiment/${d}
		cd "${S}"/${d}
		doexe *
	done

	for d in conf lib ; do
		cd "${S}"/${d}
		dodir /usr/share/alba-experiment/${d}
		insinto /usr/share/alba-experiment/${d}
		doins *
	done
}
