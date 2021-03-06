# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/perl-tk/perl-tk-804.027.ebuild,v 1.21 2006/08/06 03:01:53 mcummings Exp $

inherit perl-module eutils multilib

MY_P=Tk-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="A Perl Module for Tk"
HOMEPAGE="http://search.cpan.org/~ni-s/${MY_P}/"
SRC_URI="mirror://cpan/authors/id/N/NI/NI-S/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-sunos"
IUSE=""

DEPEND="|| ( x11-libs/libX11 virtual/x11 )
	dev-lang/perl"
RDEPEND="${DEPEND}"

myconf="-I/usr/include/ -l/usr/$(get_libdir)"

mydoc="ToDo VERSIONS"

export X11ROOT=/usr

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/xorg.patch
}

