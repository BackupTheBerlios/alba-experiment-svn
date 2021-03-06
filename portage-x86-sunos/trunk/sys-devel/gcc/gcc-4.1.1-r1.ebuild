# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.1.1-r1.ebuild,v 1.6 2006/09/23 16:30:08 vapier Exp $

PATCH_VER="1.7"
UCLIBC_VER="1.1"

ETYPE="gcc-compiler"

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=no #${SPLIT_SPECS-true} hard disable until #106690 is fixed

inherit toolchain

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"

LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="-* ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~x86-fbsd ~x86-sunos"

RDEPEND=">=sys-libs/zlib-1.1.4
	|| ( >=sys-devel/gcc-config-1.3.12-r4 app-admin/eselect-compiler )
	virtual/libiconv
	fortran? (
		>=dev-libs/gmp-4.2.1
		>=dev-libs/mpfr-2.2.0_p10
	)
	!build? (
		gcj? (
			gtk? (
				|| ( ( x11-libs/libXt x11-libs/libX11 x11-libs/libXtst x11-proto/xproto x11-proto/xextproto ) virtual/x11 )
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	>=${CATEGORY}/binutils-2.15.94"
PDEPEND="|| ( sys-devel/gcc-config app-admin/eselect-compiler )"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.3.6 )"
fi

IUSE="sun-ld"

src_unpack() {
	gcc_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	# Fix cross-compiling
	epatch "${FILESDIR}"/4.1.0/gcc-4.1.0-cross-compile.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch
}

src_compile() {
	if use x86-sunos; then
		EXTRA_ECONF="${EXTRA_ECONF} --with-as=/usr/bin/gas --with-gnu-as"
		if ! use multilib; then 
			EXTRA_ECONF="${EXTRA_ECONF} --disable-multilib"
		fi
		if use sun-ld ; then
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --with-ld=/usr/ccs/bin/ld"
		else
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld --with-ld=/usr/bin/gld"
		fi
	fi
	gcc_src_compile
}

