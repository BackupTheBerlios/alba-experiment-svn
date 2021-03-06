# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus-bin/azureus-bin-2.3.0.4.ebuild,v 1.6 2005/11/20 03:38:22 josejx Exp $

inherit eutils java-pkg

DESCRIPTION="Azureus - Java BitTorrent Client"
HOMEPAGE="http://azureus.sourceforge.net/"

MY_PN=${PN/-bin/}
MY_PV="${PV}"
MY_DT=20040224

S=${WORKDIR}/${MY_PN}
SRC_URI="mirror://gentoo/seda-${MY_DT}.zip
	x86? ( gtk? ( mirror://sourceforge/${MY_PN}/Azureus_${MY_PV}_linux.GTK.tar.bz2 ) )
	x86? ( !gtk? ( mirror://sourceforge/${MY_PN}/Azureus_${MY_PV}_linux.Motif.tar.bz2 ) )
	amd64? ( mirror://sourceforge/${MY_PN}/Azureus_${MY_PV}_linux.AMD64.tar.bz2 )
	ppc? ( mirror://sourceforge/${MY_PN}/Azureus_${MY_PV}_linux.PPC.tar.bz2 )"

LICENSE="GPL-2 BSD"
SLOT="0"

# Still in progress... trying to get most external classes in through DEPENDs rather than 
KEYWORDS="amd64 ppc x86 ~x86-sunos"
IUSE="kde gtk"

DEPEND="virtual/libc
	app-arch/unzip
	!net-p2p/azureus"

RDEPEND="${DEPEND}
	kde? ( dev-java/systray4j )
	net-libs/linc
	=x11-libs/gtk+-2*
	>=virtual/jre-1.4"

# Where to install the package
PROGRAM_DIR="/usr/$(get_libdir)/${MY_PN}"

src_unpack() {
	if ! use kde; then
		einfo "The kde use flag is off, so the systray support will be disabled."
		einfo "kde is required to build dev-java/systray4j."
	fi

	if use amd64 ; then
		unpack Azureus_${MY_PV}_linux.AMD64.tar.bz2
	else
		if use ppc ; then
			unpack Azureus_${MY_PV}_linux.PPC.tar.bz2
		else
			if use gtk ; then
				unpack Azureus_${MY_PV}_linux.GTK.tar.bz2
				echo
				einfo "Using the GTK Azureus package, to use the Motif package"
				einfo "\`echo \"net-p2p/azureus-bin -gtk\" >> /etc/portage/package.use\`"
				echo
			else
				unpack Azureus_${MY_PV}_linux.Motif.tar.bz2
				echo
				einfo "Using the Motif Azureus package, to use the GTK package"
				einfo "  set USE=\"gtk\" in /etc/make.conf."
				echo
			fi
		fi
	fi

	cp ${FILESDIR}/${PN}-gentoo.sh ${MY_PN}/azureus || die "failed to copy wrapper"

	# Set runtime settings in the startup script
	sed -i "s:##PROGRAM_DIR##:${PROGRAM_DIR}:" ${MY_PN}/azureus

	# Unpack seda
	cd ${S}
	unpack seda-${MY_DT}.zip
	tar xjf seda-jnilibs-linux.tar.bz2
	rm seda*bz2
}

src_compile() {
	einfo "Binary only installation.  No compilation required."
}

src_install() {
	cd ${S}

	insinto ${PROGRAM_DIR}
	exeinto ${PROGRAM_DIR}

	java-pkg_dojar *.jar
	doexe *.so

	# keep the plugins dir bug reports from flowing in
	insinto ${PROGRAM_DIR}/plugins/azupdater
	doins plugins/azupdater/*

	dobin azureus

	insinto /usr/share/pixmaps
	doins ${FILESDIR}/azureus.png

	insinto /usr/share/applications
	doins ${FILESDIR}/azureus.desktop

	dodoc seda-README.txt
	dohtml swt-about.html
}

pkg_postinst() {
	echo
	einfo "Due to the nature of the portage system, we recommend"
	einfo "that users check portage for new versions of Azureus"
	einfo "instead of attempting to use the auto-update feature."
	einfo "You can disable the upgrade warning in"
	einfo "View->Configuration->Interface->Start"
	echo
	einfo "After running azureus for the first time, configuration"
	einfo "options will be placed in ~/.Azureus/gentoo.config"
	einfo "It is recommended that you modify this file rather than"
	einfo "the azureus startup script directly."
	echo
	einfo "As of this version, the new ui type 'console' is supported,"
	einfo "and this may be set in ~/.Azureus/gentoo.config."
	echo
	ewarn "If you are upgrading, and the menu in azurues has entries like"
	ewarn "\"!MainWindow.menu.transfers!\" then you have a stray MessageBundle.properties file,"
	ewarn "and you may safely delete ~/.Azureus/MessagesBundle.properties"
	echo
	einfo "It's recommended to use sun-java in version 1.5 or later."
	einfo "If you'll notice any problems running azureus and you've"
	einfo "got older java, try to upgrade it"
	echo
}
