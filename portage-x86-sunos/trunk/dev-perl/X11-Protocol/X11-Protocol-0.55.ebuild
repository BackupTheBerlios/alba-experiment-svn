# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/X11-Protocol/X11-Protocol-0.55.ebuild,v 1.10 2006/10/20 20:14:17 kloeri Exp $

inherit perl-module eutils

DESCRIPTION="Client-side interface to the X11 Protocol"
HOMEPAGE="http://www.cpan.org/modules/by-module/X11/${P}.readme"
SRC_URI="mirror://cpan/authors/id/S/SM/SMCCAM/${P}.tar.gz"

LICENSE="Artistic X11"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ~ppc64 sparc ~x86 ~x86-sunos"
IUSE=""

DEPEND="|| ( ( x11-libs/libXrender
	x11-libs/libXext
		)
		virtual/x11
	)
	dev-lang/perl"

