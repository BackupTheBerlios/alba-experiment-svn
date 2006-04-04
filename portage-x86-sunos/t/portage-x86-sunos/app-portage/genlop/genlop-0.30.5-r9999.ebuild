# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/genlop/genlop-0.30.5.ebuild,v 1.9 2006/02/20 00:59:04 kumba Exp $

inherit bash-completion

DESCRIPTION="A nice emerge.log parser"
HOMEPAGE="http://pollycoke.org/genlop.html"
SRC_URI="http://gelo.dolcetta.net/software/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 x86-sunos"
IUSE=""

DEPEND=">=dev-lang/perl-5.8.0-r12
	 >=dev-perl/DateManip-5.40"
RDEPEND="${DEPEND}"

src_install() {
	dobin genlop || die
	dodoc README Changelog
	doman genlop.1
	dobashcompletion genlop.bash-completion genlop
}