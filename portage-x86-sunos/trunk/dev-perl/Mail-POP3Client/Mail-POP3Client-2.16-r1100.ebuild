# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Mail-POP3Client/Mail-POP3Client-2.16.ebuild,v 1.16 2006/02/13 13:13:15 mcummings Exp $

inherit perl-module

DESCRIPTION="POP3 client module for Perl"
HOMEPAGE="http://www.cpan.org/modules/by-module/Mail/${P}.readme"
SRC_URI="mirror://cpan/authors/id/S/SD/SDOWD/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc s390 sparc x86 -x86-sunos"
IUSE=""

SRC_TEST="do"

DEPEND=">=virtual/perl-libnet-1.0703"

mydoc="FAQ"
