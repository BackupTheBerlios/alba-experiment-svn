# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.5.1-r9.ebuild,v 1.6 2006/01/12 02:05:14 vapier Exp $

inherit flag-o-matic eutils

DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/grep.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86 -x86-sunos"
IUSE="build nls static g-prefix gnulinks"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix a weird sparc32 compiler bug
	echo "" >> src/dfa.h

	epatch "${FILESDIR}"/${PV}-manpage.patch
	epatch "${FILESDIR}"/${PV}-manpage-line-buffering.patch
	epatch "${FILESDIR}"/${P}-fgrep.patch.bz2
	epatch "${FILESDIR}"/${P}-i18n.patch.bz2
	epatch "${FILESDIR}"/${P}-gofast.patch.bz2
	epatch "${FILESDIR}"/${P}-oi.patch
	epatch "${FILESDIR}"/${P}-restrict_arr.patch
	epatch "${FILESDIR}"/${PV}-utf8-case.patch
	epatch "${FILESDIR}"/${P}-perl-segv.patch #95495
	epatch "${FILESDIR}"/${P}-libintl.patch #92586
	epatch "${FILESDIR}"/${P}-fix-devices-skip.patch #113640

	# retarded
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c || die

	# uclibc does not suffer from this glibc bug.
	use elibc_uclibc || epatch "${FILESDIR}"/${PV}-tests.patch
}

src_compile() {
	if use static ; then
		append-flags -static
		append-ldflags -static
	fi
	local myconf=""
	myconf="--bindir=/bin"

	if use g-prefix ; then
		myconf="${myconf} --program-prefix=g"
		pprefix="g"
	fi

	econf \
		${myconf} \
		$(use_enable nls) \
		--disable-perl-regexp \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# Override the default shell scripts... grep knows how to act
	# based on how it's called

	if use gnulinks  ; then
		test -z ${GNU_PREFIX} && die "GNU_PREFIX environment variable must be set"
                # create symlinks in /usr/gnu/bin
                dodir ${GNU_PREFIX}/bin
                cd "${D}"/bin
                einfo "Creating links in ${GNU_PREFIX}/bin"
                local x
                for x in * ; do
                        dosym /bin/${x} ${GNU_PREFIX}/bin/${x:1}
                done
	fi

	ln -sfn ${pprefix}grep "${D}"/bin/${pprefix}egrep || die "ln egrep failed"
	ln -sfn ${pprefix}grep "${D}"/bin/${pprefix}fgrep || die "ln fgrep failed"

	if use build ; then
		rm -r "${D}"/usr/share
	else
		dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	fi
}

pkg_postinst() {
	if has pcre ${USE} ; then
		ewarn "This grep ebuild no longer supports pcre.  If you want this"
		ewarn "functionality, please use 'pcregrep' from the pcre package."
	fi
}
