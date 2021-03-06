# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-5.1_p4.ebuild,v 1.13 2006/10/17 06:02:10 uberlord Exp $

inherit eutils multilib toolchain-funcs

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-5.1-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/readline/${MY_P}.tar.gz
	$(for ((i=1; i<=PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
		printf 'mirror://gnu/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
	done)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd -x86-sunos"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	# Official patches
	local i
	for ((i=1; i<=PLEVEL; i++)); do
		epatch "${DISTDIR}"/${PN}${MY_PV/\.}-$(printf '%03d' ${i})
	done
	epatch "${FILESDIR}"/bash-3.0-etc-inputrc.patch
	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${MY_P}-cleanups.patch
	epatch "${FILESDIR}"/${MY_P}-rlfe-build.patch #116483
	epatch "${FILESDIR}"/${MY_P}-rlfe-uclibc.patch
	epatch "${FILESDIR}"/${MY_P}-rlfe-libutil.patch
	epatch "${FILESDIR}"/${MY_P}-fbsd-pic.patch

	ln -s ../.. examples/rlfe/readline

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"
}

src_compile() {
	# the --libdir= is needed because if lib64 is a directory, it will default
	# to using that... even if CONF_LIBDIR isnt set or we're using a version
	# of portage without CONF_LIBDIR support.
	econf --with-curses --libdir=/usr/$(get_libdir) || die
	emake || die

	if ! tc-is-cross-compiler; then
		cd examples/rlfe
		econf || die
		emake || die "make rlfe failed"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die
	dodir /$(get_libdir)

	if ! use userland_Darwin ; then
		mv "${D}"/usr/$(get_libdir)/*.so* "${D}"/$(get_libdir)
		chmod a+rx "${D}"/$(get_libdir)/*.so*

		# Bug #4411
		gen_usr_ldscript libreadline.so
		gen_usr_ldscript libhistory.so
	fi

	if ! tc-is-cross-compiler; then
		dobin examples/rlfe/rlfe || die
	fi

	dodoc CHANGELOG CHANGES README USAGE NEWS
	docinto ps
	dodoc doc/*.ps
	dohtml -r doc
}

pkg_preinst() {
	# Backwards compatibility #29865
	if [[ -e ${ROOT}/$(get_libdir)/libreadline.so.4 ]] ; then
		cp -pPR "${ROOT}"/$(get_libdir)/libreadline.so.4* "${D}"/$(get_libdir)/
		touch "${D}"/$(get_libdir)/libreadline.so.4*
	fi
}

pkg_postinst() {
	if [[ -e ${ROOT}/$(get_libdir)/libreadline.so.4 ]] ; then
		ewarn "Your old readline libraries have been copied over."
		ewarn "You should run 'revdep-rebuild --library libreadline.so.4' asap."
		ewarn "Once you have, you can safely delete /$(get_libdir)/libreadline.so.4*"
	fi
}
