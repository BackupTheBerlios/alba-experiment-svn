# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-mad/gst-plugins-mad-0.10.3.ebuild,v 1.6 2006/05/14 15:20:01 dertobi123 Exp $

inherit gst-plugins-ugly

KEYWORDS="~alpha ~amd64 ~hppa ~ppc ppc64 sparc ~x86 x86-sunos"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.3
	>=media-libs/gstreamer-0.10.3
	>=media-libs/libmad-0.15.1b
	>=media-libs/libid3tag-0.15"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"