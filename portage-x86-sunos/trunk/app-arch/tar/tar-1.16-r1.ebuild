# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.16-r1.ebuild,v 1.1 2006/11/01 01:18:48 vapier Exp $

inherit flag-o-matic eutils gnuize

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRC_URI="http://ftp.gnu.org/gnu/tar/${P}.tar.bz2
	ftp://alpha.gnu.org/gnu/tar/${P}.tar.bz2
	mirror://gnu/tar/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-sunos"
IUSE="nls static gnulinks"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-segv.patch

	#if ! use userland_GNU ; then
		#sed -i \
			#-e 's:/backup\.sh:/gbackup.sh:' \
			#scripts/{backup,dump-remind,restore}.in \
			#|| die "sed non-GNU"
	#fi
}

src_compile() {
	local myconf
	use static && append-ldflags -static
	LIBEXECDIR=""
	if [[ "${USERLAND}" == "GNU" ]] ; then
		LIBEXECDIR="/usr/sbin"
		myconf="--bindir=/bin --libexecdir=${LIBEXECDIR}" 
	else
		LIBEXECDIR="/usr/libexec/gnu"
		myconf="--bindir=${LIBEXECDIR} --libexecdir=${LIBEXECDIR}"
	fi
	# Work around bug in sandbox #67051
	gl_cv_func_chown_follows_symlink=yes \
	econf \
		--enable-backup-scripts \
		$(use_enable nls) \
		${myconf} || die
	emake || die "emake failed"
}

src_install() {
	local p=""
	##use userland_GNU || p=g

	emake DESTDIR="${D}" install || die "make install failed"

	# a nasty yet required symlink
	dodir /etc
	dosym ${LIBEXECDIR}/${p}rmt /etc/${p}rmt
	if [[ "${USERLAND}" == "GNU" ]]; then
		mv "${D}"/usr/sbin/${p}backup{,-tar}
		mv "${D}"/usr/sbin/${p}restore{,-tar}
	else
		mv "${D}"/usr/sbin/${p}backup "${D}"/usr/libexec/gnu/backup-tar
		mv "${D}"/usr/sbin/${p}restore "${D}"/usr/libexec/gnu/restore-tar
	fi
	
	[[ ! "${USERLAND}" == "GNU" ]] && use gnulinks && create_glinks

	dodoc AUTHORS ChangeLog* NEWS README* PORTS THANKS
	newman "${FILESDIR}"/tar.1 ${p}tar.1

	rm -f "${D}"/usr/$(get_libdir)/charset.alias
}
