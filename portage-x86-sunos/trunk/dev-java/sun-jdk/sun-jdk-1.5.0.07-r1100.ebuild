# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.06-r2.ebuild,v 1.2 2006/03/12 13:31:29 betelgeuse Exp $

inherit java eutils

MY_PVL=${PV%.*}_${PV##*.}
MY_PVA=${PV//./_}

amd64file="jdk-${MY_PVA}-linux-amd64.bin"
x86file="jdk-${MY_PVA}-linux-i586.bin"
x86sunfile="jdk-${MY_PVA}-solaris-i586.tar.Z"

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
SRC_URI="x86? ( $x86file ) amd64? ( $amd64file ) x86-sunos? ( $x86sunfile )
		jce? ( $jcefile )"
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

PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar jre/lib/javaws.jar jre/lib/deploy.jar"

# this is needed for proper operating under a PaX kernel without activated grsecurity acl
CHPAX_CONSERVATIVE_FLAGS="pemsv"

FETCH_SDK="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jdk-${MY_PVL}-oth-JPR&SiteId=JSC&TransactionId=noreg"
FETCH_JCE="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jce_policy-${PV%.*}-oth-JPR&SiteId=JSC&TransactionId=noreg"


pkg_nofetch() {
	local archtext=""

	if use x86; then
		archtext="Linux"
	elif use amd64; then
		archtext="Linux AMD64"
	elif use x86-sunos; then
		archtext="Solaris x86"
	fi

	einfo "Please download ${At} from:"
	einfo "${FETCH_SDK}"
	einfo "Select the ${archtext} self-extracting file"
	einfo "and move it to ${DISTDIR}"

	if use jce; then
		echo
		einfo "Also download ${jcefile} from:"
		einfo ${FETCH_JCE}
		einfo "Java(TM) Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files"
		einfo "and move it to ${DISTDIR}"
	fi

}

src_unpack() {
	UNPACK_CMD=gtar
	unpack ${A}
	#${S}/bin/java -client -Xshare:dump
}

src_install() {
	PKGS="SUNWj5cfg SUNWj5dev SUNWj5dmo SUNWj5jmp SUNWj5man SUNWj5rt"
	if ! pkginfo ${PKGS} >/dev/null ; then
		eerror "You must have these Solaris packages installed:"
		eerror "\t${PKGS}"
		die
	else
		for v in `pkginfo SUNWj5cfg SUNWj5dev SUNWj5dmo SUNWj5jmp SUNWj5man SUNWj5rt  | gawk '{print $NF}' | tr -d /\(\)/}`; do
			if [ ${v} != ${MY_PVA} ]; then
				eerror "Version $v is not expected version ${MY_PVA}, please upgrade packages"
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

	set_java_env ${FILESDIR}/${VMHANDLE}

}

pkg_postinst() {
	# Create files used as storage for system preferences.
	# Set as default VM if none exists
	java_pkg_postinst

}
