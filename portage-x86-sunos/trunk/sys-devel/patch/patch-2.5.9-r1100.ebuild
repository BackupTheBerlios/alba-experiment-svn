# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/patch/patch-2.5.9-r1.ebuild,v 1.8 2005/09/01 05:54:20 vapier Exp $

inherit flag-o-matic eutils

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"
#SRC_URI="mirror://gnu/patch/${P}.tar.gz"
#Using own mirrors until gnu has md5sum and all packages up2date
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 x86-sunos"
IUSE="build static g-prefix gnulinks"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/patch-2.5.9-cr-stripping.patch
}

src_compile() {
	strip-flags
	append-flags -DLINUX -D_XOPEN_SOURCE=500
	use static && append-ldflags -static

	local myconf=""
	( [[ ${USERLAND} != "GNU" ]] || use g-prefix ) && myconf="--program-prefix=g"
	ac_cv_sys_long_file_names=yes econf ${myconf} || die

	emake || die "emake failed"
}

src_install() {
	einstall || die
	dodoc AUTHORS ChangeLog NEWS README
	use build && rm -r "${D}"/usr/share
	if use gnulinks; then
		[[ -z ${GNU_PREFIX} ]] && die "environment variable GNU_PREFIX must be set"
                dodir ${GNU_PREFIX}/bin
                cd "${D}"
		local d
		for d in usr/bin bin; do
                	if [ -d ${d} ]; then
                		einfo "Creating links in ${GNU_PREFIX}/bin"
				cd ${d}
                		local x
                		for x in * ; do
                        		dosym /bin/${x} ${GNU_PREFIX}/bin/${x:1}
                		done
			fi
		done
	fi
}
