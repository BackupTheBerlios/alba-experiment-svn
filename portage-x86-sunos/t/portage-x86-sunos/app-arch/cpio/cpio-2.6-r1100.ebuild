# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/cpio-2.6-r5.ebuild,v 1.11 2006/02/18 21:42:46 vapier Exp $

inherit eutils

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86 x86-sunos"
IUSE="nls"

DEPEND=""

src_unpack() {
	unpack ${A}
	if ! use x86-sunos; then
		cd "${S}"
		epatch "${FILESDIR}"/${PV}-rili-big-files.patch #68520
		epatch "${FILESDIR}"/${PV}-isnumber.patch #74929
		epatch "${FILESDIR}"/${PV}-umask.patch #79844
		epatch "${FILESDIR}"/${PV}-lstat.patch #80246
		epatch "${FILESDIR}"/${P}-chmodRaceC.patch #90619
		epatch "${FILESDIR}"/${P}-gcc4-tests.patch #89123
		epatch "${FILESDIR}"/${P}-dirTraversal.patch #90619
		epatch "${FILESDIR}"/${P}-checksum.patch
		epatch "${FILESDIR}"/${P}-warnings.patch
		epatch "${FILESDIR}"/${P}-writeOutHeaderBufferOverflow.patch #112140
	 	epatch "${FILESDIR}"/${P}-stpcpy-hack.patch #123237
	fi
}

src_compile() {
	# The configure script has a useless check for gethostname in 
	# libnsl ... but cpio doesn't utilize the lib/func anywhere, 
	# so let's force the lib to not be detected
	local myconf
	local p
	if [[ ${USERLAND} == "SunOS" ]]  ; then
		p='g'
		myconf="--program-prefix=${p}"
		
	fi
	ac_cv_lib_nsl_gethostname=no \
	econf \
		$(use_enable nls) \
		--bindir=/bin \
		--with-rmt=/usr/sbin/${p}rmt \
		${myconf} \
		|| die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README INSTALL
	rm -f "${D}"/usr/share/man/man1/mt.1
	rmdir "${D}"/usr/libexec || die
	if [[ ${USERLAND} == "SunOS" ]] ; then
		local BINDIR="bin"
    	# create symlinks in /usr/gnu/bin
		dodir ${GNU_PREFIX}/${BINDIR}
		cd "${D}"
		cd ${BINDIR}
		einfo "Creating links in ${GNU_PREFIX}/${BINDIR}"
		local x
		for x in * ; do
			dosym /${BINDIR}/${x} ${GNU_PREFIX}/${BINDIR}/${x:1}
		done
	fi

}