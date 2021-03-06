# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/xterm/xterm-215.ebuild,v 1.10 2006/08/19 14:39:17 vapier Exp $

inherit flag-o-matic

DESCRIPTION="Terminal Emulator for X Windows"
HOMEPAGE="http://dickey.his.com/xterm/"
SRC_URI="ftp://invisible-island.net/${PN}/${P}.tgz"

LICENSE="X11"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="truetype Xaw3d unicode toolbar"

RDEPEND="|| ( (	x11-libs/libX11
		x11-libs/libXrender
		x11-libs/libXt
		x11-libs/libXmu
		x11-libs/libxkbfile
		x11-libs/libXft
		x11-libs/libXaw
		unicode? ( x11-apps/luit ) )
	virtual/x11 )
	Xaw3d? ( x11-libs/Xaw3d )
	!x86-sunos? ( sys-libs/libutempter )"

DEPEND="${RDEPEND}
	|| ( x11-proto/xproto virtual/x11 )"

pkg_setup() {
	if has_version "x11-libs/libX11"; then
		DEFAULTS_DIR="/usr/share/X11/app-defaults"
	else
		DEFAULTS_DIR="/etc/X11/app-defaults"
	fi
}

src_compile() {
	use x86-sunos && epatch ${FILESDIR}/xterm-displaced-ncurses.patch
	filter-flags "-fstack-protector"

	local myconf=""

	if has_version "x11-libs/libX11"; then
		myconf="--disable-narrowproto"
	fi

	econf \
		--libdir=/etc \
		--with-x \
		--with-utempter \
		--disable-setuid \
		--disable-full-tgetent \
		--disable-imake \
		--enable-ansi-color \
		--enable-256-color \
		--enable-broken-osc \
		--enable-broken-st \
		--enable-load-vt-fonts \
		--enable-i18n \
		--enable-wide-chars \
		--enable-doublechars \
		--enable-warnings \
		--enable-tcap-query \
		--enable-logging \
		--enable-dabbrev \
		--with-app-defaults=${DEFAULTS_DIR} \
		$(use_enable toolbar) \
		$(use_enable truetype freetype) \
		$(use_enable unicode luit) $(use_enable unicode mini-luit) \
		$(use_with Xaw3d) \
		${myconf} \
		|| die

	emake || die "failed to compile xterm"
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc README{,.i18n} ctlseqs.txt xterm.log.html

	# Fix permissions -- it grabs them from live system, and they can
	# be suid or sgid like they were in pre-unix98 pty or pre-utempter days,
	# respectively (#69510).
	# (info from Thomas Dickey) - Donnie Berkholz <spyderous@gentoo.org>
	fperms 0755 /usr/bin/xterm

	# restore the navy blue
	sed -i "s:blue2$:blue:" ${D}${DEFAULTS_DIR}/XTerm-color

	# Fix for bug #91453 at Thomas Dickey's suggestion:
	echo "*allowWindowOps: 	false" >> ${D}/${DEFAULTS_DIR}/XTerm
	echo "*allowWindowOps: 	false" >> ${D}/${DEFAULTS_DIR}/UXTerm
}
