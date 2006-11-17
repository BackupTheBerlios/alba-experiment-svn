# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 autotools

DESCRIPTION="A versatile IDE for GNOME"
HOMEPAGE="http://www.anjuta.org"
SRC_URI="mirror://sourceforge/${PN}/${PF}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~x86-sunos"
IUSE="doc glade inherit-graph scintilla sourceview subversion valgrind"

RDEPEND=">=dev-libs/glib-2.8.0
	>=x11-libs/gtk+-2.8.0
	>=gnome-base/orbit-2.10.0
	>=gnome-base/libglade-2.5.0
	>=gnome-base/libgnome-2.14.0
	>=gnome-base/libgnomeui-2.14.0
	>=gnome-base/libgnomeprint-2.12.0
	>=gnome-base/libgnomeprintui-2.12.0
	>=gnome-base/gnome-vfs-2.10.0
	>=gnome-base/libbonobo-2.6
	>=gnome-base/libbonoboui-2.6
	>=gnome-base/gconf-2.12.0
	>=dev-libs/libxml2-2.4.23
	>=dev-libs/libxslt-1.1.13
	>=x11-libs/pango-1.1.1
	>=x11-libs/libwnck-2.12
	>=x11-libs/vte-0.9.0
	>=dev-libs/gdl-0.6.1
	>=dev-libs/gnome-build-0.1.3
	>=dev-util/devhelp-0.11.0
	>=sys-devel/autogen-5.6.4
	inherit-graph? ( >=media-gfx/graphviz-2.2.1 )
	sourceview? ( >=x11-libs/gtksourceview-1.6.0 )
	valgrind? ( dev-util/valgrind )
	doc? ( >=dev-util/gtk-doc-1.0 )
	>=dev-libs/libpcre-5.0
	subversion? (
		>=net-misc/neon-0.24.5
		dev-libs/apr
		dev-libs/apr-util
		>=dev-util/subversion-1.1.4
	)"
#	glade? ( >=dev-util/glade-2.91.3 )

DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

pkg_setup() {
	# workaround parallel make bug
	#MAKEOPTS="${MAKEOPTS} -j1"
	
	G2CONF="${G2CONF} \
		$(use_enable glade plugin-glade) \
		$(use_enable inherit-graph plugin-class-inheritance) \
		$(use_enable sourceview plugin-sourceview) \
		$(use_enable scintilla plugin-scintilla) \
		$(use_enable valgrind plugin-valgrind) \
		$(use_enable doc gtk-doc) \
		$(use_enable subversion plugin-subversion) \
	"
	if ! use sourceview && ! use scintilla; then
		# enable at least one editor plugin
		G2CONF="${G2CONF} --enable-plugin-scintilla"
	fi
}

src_unpack() {
	gnome2_src_unpack
	#gnome2_omf_fix ${S}/manuals/omf.make
	epatch ${FILESDIR}/2.0.2-install-sandbox.patch
	eautomake
}

src_install() {
	# Fix docs installation (per bug #61344)
	sed -i "s:doc/${PN}:doc/${PF}:g" Makefile
	sed -i "s:doc/${PN}:doc/${PF}/html:g" doc/Makefile

	gnome2_src_install

	prepalldocs
}

pkg_postinst() {
	gnome2_pkg_postinst

	ebeep 1
	einfo "Some project templates may require additional development"
	einfo "libraries to function correctly. It goes beyond the scope"
	einfo "of this ebuild to provide them."
	epause 5
}
