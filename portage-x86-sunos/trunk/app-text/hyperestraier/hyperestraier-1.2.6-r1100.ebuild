# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hyperestraier/hyperestraier-1.2.6.ebuild,v 1.2 2006/07/02 02:00:32 matsuu Exp $

inherit java-pkg

IUSE="bzip2 debug java mecab ruby"

DESCRIPTION="a full-text search system for communities"
HOMEPAGE="http://hyperestraier.sf.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-sunos"
SLOT="0"

DEPEND=">=dev-db/qdbm-1.8.53
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	mecab? ( app-text/mecab )"

src_unpack() {

	unpack ${A}
	cd ${S}

	sed -i -e "/^LDENV/d" Makefile.in

}

src_compile() {

	econf \
		`use_enable bzip2 bzip` \
		`use_enable debug` \
		`use_enable mecab` \
		|| die
	emake || die

	local u d

	for u in java ruby; do
		if ! use ${u}; then
			continue
		fi

		for d in ${u}native ${u}pure; do
			cd ${d}
			econf || die
			emake || die
			cd -
		done
	done

}

src_test() {

	# Hyper Estraier can't test in sandbox ?
	return

}

src_install() {

	make DESTDIR=${D} MYDOCS= install || die
	dodoc ChangeLog README* THANKS
	dohtml doc/*

	local u d

	for u in java ruby; do
		if ! use ${u}; then
			continue
		fi

		for d in ${u}native ${u}pure; do
			cd ${d}
			make DESTDIR=${D} install || die
			cd -
			dohtml -r doc/${d}api
		done
	done

	if use java; then
		java-pkg_dojar ${D}/usr/$(get_libdir)/*.jar
		rm -f ${D}/usr/$(get_libdir)/*.jar
	fi

	rm -f ${D}/usr/bin/*test

}
