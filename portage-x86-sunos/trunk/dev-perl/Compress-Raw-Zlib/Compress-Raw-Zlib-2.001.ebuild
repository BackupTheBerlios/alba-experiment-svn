# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Compress-Raw-Zlib/Compress-Raw-Zlib-2.001.ebuild,v 1.10 2006/12/11 23:54:01 pylon Exp $

inherit perl-module

DESCRIPTION="Low-Level Interface to zlib compression library"
HOMEPAGE="http://search.cpan.org/~pmqs"
SRC_URI="mirror://cpan/authors/id/P/PM/PMQS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 arm ~hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-sunos"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
