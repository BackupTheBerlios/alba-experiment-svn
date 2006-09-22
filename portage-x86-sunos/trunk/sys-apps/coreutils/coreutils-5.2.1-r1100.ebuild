# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-5.2.1-r7.ebuild,v 1.12 2006/02/17 12:29:44 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs

PATCH_VER=1.0
PATCHDIR="${WORKDIR}/patch"

DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 -x86-sunos"
IUSE="acl build nls selinux static"

RDEPEND="selinux? ( sys-libs/libselinux )
	acl? ( sys-apps/acl sys-apps/attr )
	nls? ( sys-devel/gettext )
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	>=sys-apps/portage-2.0.49
	=sys-devel/automake-1.8*
	>=sys-devel/autoconf-2.58
	>=sys-devel/m4-1.4-r1
	sys-apps/help2man"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [[ !${USERLAND} != "SunOS" ]]; then
		EPATCH_MULTI_MSG="Applying patches from Mandrake ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/mandrake

		# Apply the ACL/SELINUX patches.
		if ! use selinux && use acl ; then
			EPATCH_MULTI_MSG="Applying ACL patches ..." \
			EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/acl
		fi
	fi

	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/generic
	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/extra

	# Make sure test is +x #87795
	chmod a+rx tests/sort/sort-mb-tests

	if [[ !${USERLAND} != "SunOS" ]]; then
		if use selinux ; then
			EPATCH_MULTI_MSG="Applying SELINUX patches ..." \
			EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/selinux
		fi
	fi

	# Sparc32 SMP bug fix -- see bug #46593
	use sparc && echo -ne "\n\n" >> "${S}"/src/pr.c

	# Since we've patched many .c files, the make process will 
	# try to re-build the manpages by running `./bin --help`.  
	# When cross-compiling, we can't do that since 'bin' isn't 
	# a native binary, so let's just install outdated man-pages.
	tc-is-cross-compiler && touch man/*.1

	ebegin "Reconfiguring configure scripts (be patient)"
	export WANT_AUTOMAKE=1.8
	export WANT_AUTOCONF=2.5

	mv m4/inttypes.m4 m4/inttypes-eggert.m4
	touch aclocal.m4 configure config.hin \
		Makefile.in */Makefile.in */*/Makefile.in

	aclocal -I m4 || die "aclocal"
	autoconf || die "autoconf"
	automake || die "automake"
	eend $?
}

src_compile() {
	if ! type -p cvs > /dev/null ; then
		# Fix issues with gettext's autopoint if cvs is not installed,
		# bug #28920.
		export AUTOPOINT="/bin/true"
	fi

	local myconf=""
	[[ ${USERLAND} == "GNU" ]] \
		&& myconf="${myconf} --bindir=/bin" \
		|| myconf="${myconf} --program-prefix=g" 

	econf \
		--enable-largefile \
		$(use_enable nls) \
		$(use_enable selinux) \
		${myconf} \
		|| die "econf"

	use static && append-ldflags -static
	emake LDFLAGS="${LDFLAGS}" || die "emake"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"
	addwrite /dev/full
	export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	make check || die "make check failed"
}

src_install() {
	make install DESTDIR="${D}" || die

	local p
	local bindir
	[[ ${USERLAND} == "SunOS" ]] && p="g" && binprefix='/usr'

	# remove files provided by other packages
	rm "${D}"${binprefix}/bin/{${p}kill,${p}uptime} # procps
	rm "${D}"${binprefix}/bin/{${p}groups,${p}su}   # shadow
	rm "${D}"${binprefix}/bin/${p}hostname      # net-tools
	rm "${D}"/usr/share/man/man1/{${p}groups,${p}kill,${p}hostname,${p}su,${p}uptime}.1
	# provide by the man-pages package
	rm "${D}"/usr/share/man/man1/{${p}chgrp,${p}chmod,${p}chown,${p}cp,${p}dd,${p}df,${p}dir,${p}dircolors}.1
	rm "${D}"/usr/share/man/man1/{${p}du,${p}install,${p}ln,${p}ls,${p}mkdir,${p}mkfifo,${p}mknod,${p}mv}.1
	rm "${D}"/usr/share/man/man1/{${p}rm,${p}rmdir,${p}touch,${p}vdir}.1

	insinto /etc
	doins "${FILESDIR}"/DIR_COLORS

	if [[ ${USERLAND} == "GNU" ]] ; then
		# move non-critical packages into /usr
		cd "${D}"
		dodir /usr/bin
		mv bin/{csplit,expand,factor,fmt,fold,join,md5sum,nl,od} usr/bin
		mv bin/{paste,pathchk,pinky,pr,printf,sha1sum,shred,sum,tac} usr/bin
		mv bin/{tail,test,[,tsort,unexpand,users} usr/bin
		cd bin
		local x
		for x in * ; do
			dosym /bin/${x} /usr/bin/${x}
		done
	fi
	if [[ ${USERLAND} == "SunOS" ]] ; then
		# create symlinks in /usr/gnu/bin
		dodir ${GNU_PREFIX}/bin
		cd "${D}"
		cd usr/bin
		einfo "Creating links in ${GNU_PREFIX}/bin"
		local x
		for x in * ; do
			dosym /bin/${x} ${GNU_PREFIX}/bin/${x:1}
		done
	fi

	if ! use build ; then
		cd "${S}"
		dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO
	else
		rm -r "${D}"/usr/share
	fi
}

pkg_postinst() {
	[[ ${USERLAND} != "GNU" ]] && return 0

	# hostname does not get removed as it is included with older stage1
	# tarballs, and net-tools installs to /bin
	if [[ -e ${ROOT}/usr/bin/hostname && ! -L ${ROOT}/usr/bin/hostname ]] ; then
		rm -f "${ROOT}"/usr/bin/hostname
	fi
}
