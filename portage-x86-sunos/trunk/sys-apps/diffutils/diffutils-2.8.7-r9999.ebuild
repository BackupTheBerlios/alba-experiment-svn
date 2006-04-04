# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/diffutils/diffutils-2.8.7-r1.ebuild,v 1.10 2006/01/11 04:37:28 vapier Exp $

inherit eutils flag-o-matic

DESCRIPTION="Tools to make diffs and compare files"
HOMEPAGE="http://www.gnu.org/software/diffutils/diffutils.html"
SRC_URI="ftp://alpha.gnu.org/gnu/diffutils/${P}.tar.gz
	mirror://gentoo/${P}-i18n.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 ~ppc-macos s390 sh sparc x86 x86-sunos"
IUSE="nls static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Removes waitpid() call after pclose() on piped diff stream, closing
	# bug #11728, thanks to D Wollmann <converter@dalnet-perl.org>
	epatch "${FILESDIR}"/diffutils-2.8.4-sdiff-no-waitpid.patch

	# Fix utf8 support.  Patch from MDK. #71689
	epatch "${WORKDIR}"/${P}-i18n.patch

	# Make sure we don't try generating the manpages ... this requires 
	# 'help2man' which is a perl app which is not available in a 
	# stage2 / stage3 ... don't DEPEND on it or we get a DEPEND loop :(
	# for more info, see #55479
	touch man/*.1

	# There's no reason for this crap to use the private version
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c

	# Fix userpriv perm problems #76600
	chmod ug+w config/*
}

src_compile() {
	local myconf
	if [[ ${USERLAND} == "SunOS" ]]; then
                einfo USERLAND=${USERLAND}
                myconf="--bindir=/usr/gnu/bin --sbindir=/usr/gnu/sbin"
	fi
	econf $(use_enable nls) ${myconf} || die "econf"
	use static && append-ldflags -static
	emake LDFLAGS="${LDFLAGS}" || die "make"
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README

	# use the manpage from 'sys-apps/man-pages'
	rm -f "${D}"/usr/share/man/man1/diff.1*
}