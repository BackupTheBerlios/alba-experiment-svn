# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Inline/Inline-0.44-r1.ebuild,v 1.20 2006/07/04 11:35:43 ian Exp $

inherit perl-module eutils

DESCRIPTION="Write Perl subroutines in other languages"
HOMEPAGE="http://search.cpan.org/doc/INGY/Inline-0.43/Inline.pod"
SRC_URI="mirror://cpan/authors/id/I/IN/INGY/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc sparc x86 x86-sunos"
IUSE="gtk"

DEPEND="perl-core/Digest-MD5
	perl-core/File-Spec
	dev-perl/Parse-RecDescent
	perl-core/Test-Harness"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
	cd ${S}
	#gtk-2 suggested patch
	use gtk && epatch ${FILESDIR}/gtk2-patch.diff
}

src_compile() {
	echo "y" | perl-module_src_compile
	perl-module_src_test
}

src_install() {
	perl-module_src_install
	dohtml DT.html
}
