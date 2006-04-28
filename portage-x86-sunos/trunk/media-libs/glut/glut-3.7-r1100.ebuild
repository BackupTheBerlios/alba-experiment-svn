# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glut/glut-3.7-r2.ebuild,v 1.19 2005/09/07 16:17:56 spyderous Exp $

MESA_VER="4.0.1"
S=${WORKDIR}/Mesa-${MESA_VER}
DESCRIPTION="The OpenGL Utility Toolkit (GLUT)"
SRC_URI="mirror://sourceforge/mesa3d/MesaLib-${MESA_VER}.tar.bz2
	mirror://sourceforge/mesa3d/MesaDemos-${MESA_VER}.tar.bz2"
HOMEPAGE="http://www.opengl.org/developers/documentation/glut/"

LICENSE="glut"
SLOT="0"
KEYWORDS="x86 ppc sparc alpha x86-sunos"
IUSE=""

DEPEND="virtual/opengl
	virtual/glu"

PROVIDE="virtual/glut"

src_compile() {

	./configure || die

	cd ${S}/src-glut

	emake || die
}

src_install() {

	insinto /usr/$(get_libdir)
	doins ${S}/src-glut/libglut.la
	dosed -e "s: -L${S}/si-glu : -L/usr/$(get_libdir) :" /usr/$(get_libdir)/libglut.la
	dosed -e "s:/usr/local/$(get_libdir):/usr/$(get_libdir):g" /usr/$(get_libdir)/libglut.la
	dosed -e "s:installed=no:installed=yes:" /usr/$(get_libdir)/libglut.la

	dolib.so ${S}/src-glut/.libs/libglut.so.${PV}.0
	dosym libglut.so.${PV}.0 /usr/$(get_libdir)/libglut.so
	preplib

	insinto /usr/include/GL
	doins ${S}/include/GL/glut*

	dodoc ${S}/docs/COPY*
}