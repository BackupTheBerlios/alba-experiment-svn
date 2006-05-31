# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-launcher/mozilla-launcher-1.51.ebuild,v 1.1 2006/03/23 19:46:07 agriffis Exp $

inherit eutils

DESCRIPTION="Script that launches mozilla or firefox"
HOMEPAGE="http://dev.gentoo.org/~agriffis/dist/"
SRC_URI="mirror://gentoo/${P}.bz2
		http://dev.gentoo.org/~agriffis/dist/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 x86-sunos"
IUSE=""

DEPEND=""
RDEPEND="|| ( x11-apps/xdpyinfo virtual/x11 )"

S=${WORKDIR}

src_install() {
	if use g-prefix; then
		sed -i -e s/grep/ggrep/ -e s/awk/gawk/ ${P}
	fi
	exeinto /usr/libexec
	newexe ${P} mozilla-launcher || die
}

pkg_postinst() {
	local f

	find ${ROOT}/usr/bin -maxdepth 1 -type l | \
	while read f; do
		[[ $(readlink ${f}) == mozilla-launcher ]] || continue
		einfo "Updating ${f} symlink to /usr/libexec/mozilla-launcher"
		ln -sfn /usr/libexec/mozilla-launcher ${f}
	done
}