# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-vorbis/gst-plugins-vorbis-0.10.7.ebuild,v 1.1 2006/05/15 08:52:26 zaheerm Exp $

inherit eutils gst-plugins-base

KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 x86-sunos"
IUSE=""

RDEPEND=">=media-libs/libvorbis-1
	 >=media-libs/libogg-1
	 >=media-libs/gst-plugins-base-0.10.7"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"
