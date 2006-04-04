# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/epm/epm-0.9.0.ebuild,v 1.2 2005/10/19 15:57:21 agriffis Exp $

DESCRIPTION="rpm workalike for Gentoo Linux"
HOMEPAGE="http://www.gentoo.org/~agriffis/epm/"
SRC_URI="http://www.gentoo.org/~kanaka/epm/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc-macos ppc64 s390 sparc x86 x86-sunos"
IUSE=""

DEPEND=">=dev-lang/perl-5"

src_compile() {
	pod2man epm > epm.1 || die "pod2man failed"
}

src_install() {
	dobin epm || die
	doman epm.1
}