# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/art-sharp/art-sharp-2.8.0.ebuild,v 1.4 2006/07/17 15:58:25 dang Exp $

inherit gtk-sharp-component

SLOT="2"
KEYWORDS="amd64 ppc x86 ~x86-sunos"
IUSE=""

DEPEND="${DEPEND} >=media-libs/libart_lgpl-2.3.16"

GTK_SHARP_COMPONENT_SLOT="2"
GTK_SHARP_COMPONENT_SLOT_DEC="-2.0"
