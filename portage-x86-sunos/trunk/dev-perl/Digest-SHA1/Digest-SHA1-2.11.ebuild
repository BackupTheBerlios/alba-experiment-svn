# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Digest-SHA1/Digest-SHA1-2.11.ebuild,v 1.14 2006/08/05 03:06:00 mcummings Exp $

inherit perl-module

DESCRIPTION="NIST SHA message digest algorithm"
HOMEPAGE="http://cpan.pair.com/modules/by-category/14_Security_and_Encryption/Digest/${P}.readme"
SRC_URI="http://www.perl.com/CPAN/authors/id/GAAS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-sunos"
IUSE=""

DEPEND="perl-core/digest-base
	dev-lang/perl"
RDEPEND="${DEPEND}"

SRC_TEST="do"

