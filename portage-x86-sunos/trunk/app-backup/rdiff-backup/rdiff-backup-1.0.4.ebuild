# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/rdiff-backup/rdiff-backup-1.0.4.ebuild,v 1.10 2006/09/16 21:03:49 vapier Exp $

inherit distutils

DESCRIPTION="Remote incremental file backup utility; uses librsync's rdiff utility to create concise, versioned backups."
HOMEPAGE="http://www.nongnu.org/rdiff-backup/"
SRC_URI="http://savannah.nongnu.org/download/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm ppc ~ppc-macos ppc64 sh sparc x86 ~x86-sunos"
IUSE="acl xattr"

DEPEND=">=net-libs/librsync-0.9.7
		!arm? ( xattr? ( dev-python/pyxattr )
				acl? ( dev-python/pylibacl ) )"
RDEPEND="${DEPEND}"
