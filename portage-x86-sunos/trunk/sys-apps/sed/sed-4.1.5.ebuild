# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sed/sed-4.1.5.ebuild,v 1.4 2006/08/21 02:02:44 vapier Exp $

inherit flag-o-matic gnuize

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"
SRC_URI="mirror://gnu/sed/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-sunos"
IUSE="nls static gnulinks"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_bootstrap_sed() {
	# make sure system-sed works #40786
	export NO_SYS_SED=""
	if ! type -p sed ; then
		NO_SYS_SED="!!!"
		./bootstrap.sh || die "couldnt bootstrap"
		cp sed/sed ${T}/ || die "couldnt copy"
		export PATH="${PATH}:${T}"
	fi
}
src_bootstrap_cleanup() {
	if [[ -n ${NO_SYS_SED} ]] ; then
		make clean || die "couldnt clean"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.1.4-makeinfo-c-locale.patch
	epatch "${FILESDIR}"/${P}-alloca.patch
	sed -i \
		-e "/docdir =/s:/doc:/doc/${PF}/html:" \
		doc/Makefile.in || die "sed html doc"
}

src_compile() {
	src_bootstrap_sed

	local myconf=""
	use userland_GNU \
		&& myconf="${myconf} --bindir=/bin" \
		|| myconf="${myconf} --bindir=/usr/libexec/gnu"
	econf \
		$(use_enable nls) \
		${myconf} \
		|| die "Configure failed"

	src_bootstrap_cleanup
	use static && append-ldflags -static
	emake LDFLAGS="${LDFLAGS}" || die "build failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "Install failed"
	dodoc NEWS README* THANKS AUTHORS BUGS ChangeLog
	docinto examples
	dodoc "${FILESDIR}"/{dos2unix,unix2dos}

	use gnulinks && create_glinks

	rm -f "${D}"/usr/lib/charset.alias "${D}"/usr/share/locale/locale.alias
}
