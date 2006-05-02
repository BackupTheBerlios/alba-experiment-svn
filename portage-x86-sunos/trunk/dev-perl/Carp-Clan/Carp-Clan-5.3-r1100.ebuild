# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Carp-Clan/Carp-Clan-5.3.ebuild,v 1.11 2005/10/02 12:20:49 agriffis Exp $

inherit perl-module

DESCRIPTION="Report errors from perspective of caller of a clan of modules"
HOMEPAGE="http://search.cpan.org/~stbey/${P}/"
SRC_URI="mirror://cpan/authors/id/S/ST/STBEY/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc ppc64 s390 sparc x86 x86-sunos"
IUSE=""

SRC_TEST="do"