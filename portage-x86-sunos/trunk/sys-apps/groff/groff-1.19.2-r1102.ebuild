# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.19.2-r1.ebuild,v 1.2 2006/03/30 15:16:27 flameeyes Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

MB_PATCH="groff_1.18.1-7" #"${P/-/_}-7"
DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd x86-sunos"
IUSE="X g-prefix gnulinks"

DEPEND=">=sys-apps/texinfo-4.7-r1
	!app-i18n/man-pages-ja"
PDEPEND=">=sys-apps/man-1.5k-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the info pages to have .info extensions,
	# else they do not get gzipped.
	epatch "${FILESDIR}"/${P}-infoext.patch

	# Make dashes the same as minus on the keyboard so that you
	# can search for it. Fixes #17580 and #16108
	# Thanks to James Cloos <cloos@jhcloos.com>
	epatch "${FILESDIR}"/${PN}-man-UTF-8.diff

	# Fix make dependencies so we can build in parallel
	epatch "${FILESDIR}"/${P}-parallel-make.patch

	# Make sure we can cross-compile this puppy
	if tc-is-cross-compiler ; then
		sed -i \
			-e '/^GROFFBIN=/s:=.*:=/usr/bin/groff:' \
			-e '/^TROFFBIN=/s:=.*:=/usr/bin/troff:' \
			-e '/^GROFF_BIN_PATH=/s:=.*:=:' \
			contrib/mom/Makefile.sub \
			doc/Makefile.in \
			doc/Makefile.sub || die "cross-compile sed failed"
	fi
}

src_compile() {
	# Fix problems with not finding g++
	tc-export CC CXX

	# -Os causes segfaults, -O is probably a fine replacement
	# (fixes bug 36008, 06 Jan 2004 agriffis)
	replace-flags -Os -O

	# CJK doesnt work yet with groff-1.19
	#	$(use_enable cjk multibyte)

	local myconf=""
	if use g-prefix ; then
		pprefix="g"
		myconf="${myconf} --program-prefix=${pprefix}"
    fi

	econf \
		${myconf} \
		--with-appresdir=/etc/X11/app-defaults \
		$(use_with X x) \
		|| die
	emake || die
}

src_install() {
	dodir /usr/bin
	make \
		prefix="${D}"/usr \
		bindir="${D}"/usr/bin \
		libdir="${D}"/usr/$(get_libdir) \
		appresdir="${D}"/etc/X11/app-defaults \
		datadir="${D}"/usr/share \
		mandir="${D}"/usr/share/man \
		infodir="${D}"/usr/share/info \
		install || die

	# The following links are required for man #123674
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl

	dodoc BUG-REPORT ChangeLog FDL MORE.STUFF NEWS \
		PROBLEMS PROJECTS README REVISION TODO VERSION
		
		local gexecs="troff tbl eqn neqn refer soelim lookbib indxbib nroff"
		if use gnulinks ; then
			ebegin "GNU-ization of the distribution."
			[[ ! -z ${GNU_PREFIX} ]] || die "Environment variable GNU_PREFIX must be set."
		    # create symlinks in /usr/gnu/bin
			dodir ${GNU_PREFIX}/bin
			cd "${D}"
			local d="/usr/bin"
			local x
			for x in ${gexecs} ; do
				if [ -x ${d}/${x} ]; then
					if use g-prefix; then
						#einfo "${d}/${x} -mv-> ${pprefix}${x}"
						newbin ${D}/${d}/${x} ${pprefix}${x}
						rm -f ${D}/${d}/${x}
						#einfo "${d}/${pprefix}${x} -ln-> ${GNU_PREFIX}/bin/${x}"
						dosym /${d}/${pprefix}${x} ${GNU_PREFIX}/bin/${x}
					else
						dosym /${d}/${x} ${GNU_PREFIX}/bin/${x}
					fi
				fi
			done
			eend
		fi
}
