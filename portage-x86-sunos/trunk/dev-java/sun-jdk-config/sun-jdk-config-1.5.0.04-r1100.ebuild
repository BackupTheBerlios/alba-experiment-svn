# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.06-r2.ebuild,v 1.2 2006/03/12 13:31:29 betelgeuse Exp $

inherit java eutils

MY_PVL=${PV%.*}_${PV##*.}
MY_PVA=${PV//./_}

jcefile="jce_policy-${MY_PVA%_*}.zip"

if use x86; then
	At=${x86file}
elif use amd64; then
	At=${amd64file}
elif use x86-sunos; then
	At=${x86sunfile}
fi

S="${WORKDIR}/jdk${MY_PVL}"
DESCRIPTION="Sun's J2SE Development Kit, version ${PV}"
HOMEPAGE="http://java.sun.com/j2se/1.5.0/"
SRC_URI=""
SLOT="1.5"
LICENSE="sun-bcla-java-vm"
KEYWORDS="-* ~amd64 ~x86 -x86-sunos"
RESTRICT="fetch nostrip stricter"
IUSE="X alsa doc browserplugin nsplugin jce mozilla examples"

#
DEPEND="sys-apps/sed
	jce? ( app-arch/unzip )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )
	X? ( || ( ( x11-libs/libICE
				x11-libs/libSM
		 		x11-libs/libX11
				x11-libs/libXau
				x11-libs/libXdmcp
				x11-libs/libXext
				x11-libs/libXi
				x11-libs/libXp
				x11-libs/libXt
				x11-libs/libXtst
			  )
				virtual/x11
			)
		)"

PROVIDE="virtual/jre
	virtual/jdk"

src_install() {

	PKGS="SUNWj5cfg SUNWj5dev SUNWj5dmo SUNWj5jmp SUNWj5man SUNWj5rt"
	if ! pkginfo ${PKGS} >/dev/null ; then
		eerror "You must have these Solaris packages installed:"
		eerror "\t${PKGS}"
		die
	else
		for v in `pkginfo SUNWj5cfg SUNWj5dev SUNWj5dmo SUNWj5jmp SUNWj5man SUNWj5rt  | gawk '{print $NF}' | tr -d /\(\)/}`; do
			if [ ${v} != ${MY_PVL} ]; then
				eerror "Actual version $v is not expected version ${MY_PVL}, please upgrade packages"
				die
			fi
		done
	fi

	#if use nsplugin ||       # global useflag for netscape-compat plugins
	   #use browserplugin ||  # deprecated but honor for now
	   #use mozilla; then     # wrong but used to honor it
		#local plugin_dir="ns7-gcc29"
		#if has_version '>=sys-devel/gcc-3' ; then
			#plugin_dir="ns7"
		#fi
#
		#if use x86 ; then
			#install_mozilla_plugin /opt/${P}/jre/plugin/i386/$plugin_dir/libjavaplugin_oji.so
		#else
			#eerror "No plugin available for amd64 arch"
		#fi
	#fi
#
	# install control panel for Gnome/KDE
	#sed -e "s/INSTALL_DIR\/JRE_NAME_VERSION/\/opt\/${P}\/jre/" \
		#-e "s/\(Name=Java\)/\1 Control Panel/" \
		#${D}/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
		#${T}/sun_java.desktop

	#domenu ${T}/sun_java.desktop
	sed -e "s/@MY_PVL@/${MY_PVL}/g" \
		< ${FILESDIR}/${VMHANDLE}-${ARCH}\
		> ${T}/sun-jdk-${PV}

	set_java_env ${T}/sun-jdk-${PV}

}

pkg_postinst() {
	# Create files used as storage for system preferences.
	# Set as default VM if none exists
	java_pkg_postinst

}
