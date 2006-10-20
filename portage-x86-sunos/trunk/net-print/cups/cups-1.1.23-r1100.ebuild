# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/cups-1.1.23-r7.ebuild,v 1.15 2006/04/02 16:30:27 flameeyes Exp $

inherit eutils flag-o-matic pam autotools

MY_P=${P/_/}
DESCRIPTION="The Common Unix Printing System"
HOMEPAGE="http://www.cups.org/"
SRC_URI="ftp://ftp2.easysw.com/pub/cups/test/${MY_P}-source.tar.bz2
ftp://ftp.easysw.com/pub/cups/test/${MY_P}-source.tar.bz2
ftp://ftp.funet.fi/pub/mirrors/ftp.easysw.com/pub/cups/test/${MY_P}-source.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd -x86-sunos"
IUSE="ssl slp pam samba nls gnutls preserve-original"

DEP="pam? ( virtual/pam )
	ssl? (
		!gnutls? ( >=dev-libs/openssl-0.9.6b )
		gnutls? ( net-libs/gnutls )
		)
	slp? ( >=net-libs/openslp-1.0.4 )
	>=media-libs/libpng-1.2.1
	>=media-libs/tiff-3.5.5
	>=media-libs/jpeg-6b"
DEPEND="${DEP}
	nls? ( sys-devel/gettext )"
RDEPEND="${DEP}
	nls? ( virtual/libintl )
	!virtual/lpr
	>=app-text/poppler-0.4.3-r1"
PDEPEND="samba? ( >=net-fs/samba-3.0.8 )"
PROVIDE="virtual/lpr"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/disable-strip.patch
	epatch ${FILESDIR}/cups-gcc4-amd64.patch #79791
	epatch ${FILESDIR}/cups-gentooalt.patch
	epatch ${FILESDIR}/${P}-bindnow.patch
	epatch ${FILESDIR}/cupsaddsmb.patch
	epatch ${FILESDIR}/${P}-respectldflags.patch
	eautoconf

	# disable builtin xpdf
	sed -i -e "s:pdftops::" Makefile
}

src_compile() {

	local myconf
	use amd64 && replace-flags -Os -O2

	use ssl && \
		myconf="${myconf} $(use_enable gnutls) $(use_enable !gnutls openssl)"

	econf \
		--with-cups-user=lp \
		--with-cups-group=lp \
		--localstatedir=/var \
		--with-bindnow=$(bindnow-flags) \
		$(use_enable pam) \
		$(use_enable ssl) \
		$(use_enable slp) \
		$(use_enable nls) \
		${myconf} \
		|| die "econf failed"

	emake || die "compile problem"
}

src_test() {
	# upstream includes an interactive test which is a nono for gentoo.
	# therefore, since the printing herd has bigger fish to fry, for now,
	# we just leave it out, even if FEATURES=test
	true
}

src_install() {
	dodir /var/spool /var/log/cups /etc/cups

	make \
	LOCALEDIR=${D}/usr/share/locale \
	DOCDIR=${D}/usr/share/cups/docs \
	REQUESTS=${D}/var/spool/cups \
	SERVERBIN=${D}/usr/$(get_libdir)/cups \
	DATADIR=${D}/usr/share/cups \
	INCLUDEDIR=${D}/usr/include \
	AMANDIR=${D}/usr/share/man \
	PMANDIR=${D}/usr/share/man \
	MANDIR=${D}/usr/share/man \
	SERVERROOT=${D}/etc/cups \
	LOGDIR=${D}/var/log/cups \
	SBINDIR=${D}/usr/sbin \
	PAMDIR=${D}/etc/pam.d \
	EXEC_PREFIX=${D}/usr \
	LIBDIR=${D}/usr/$(get_libdir) \
	BINDIR=${D}/usr/bin \
	bindir=${D}/usr/bin \
	INITDIR=${D}/etc \
	PREFIX=${D} \
	install || die "install problem"

	dodoc {CHANGES,CREDITS,ENCRYPTION,LICENSE,README}.txt
	dosym /usr/share/cups/docs /usr/share/doc/${PF}/html

	# cleanups
	rm -rf ${D}/etc/init.d ${D}/etc/pam.d ${D}/etc/rc* ${D}/usr/share/man/cat* \
		${D}/etc/cups/{certs,interfaces,ppd} ${D}/var

	sed -i -e "s:^#\(DocumentRoot\).*:\1 /usr/share/cups/docs:" \
		-e "s:^#\(SystemGroup\).*:\1 lp:" \
		-e "s:^#\(User\).*:\1 lp:" \
		-e "s:^#\(Group\).*:\1 lp:" \
		${D}/etc/cups/cupsd.conf

	pamd_mimic_system cups auth account

	newinitd ${FILESDIR}/cupsd.rc6 cupsd
	insinto /etc/xinetd.d ; newins ${FILESDIR}/cups.xinetd cups-lpd

	# allow raw printing
	dosed "s:#application/octet-stream:application/octet-stream:" /etc/cups/mime.types /etc/cups/mime.convs

	# install pdftops filter
	exeinto /usr/lib/cups/filter/
	newexe ${FILESDIR}/pdftops.pl pdftops
	dosed "s:/usr/local:/usr:" /usr/lib/cups/filter/pdftops

	# allow lppasswd, #107306
	fowners root /usr/bin/lppasswd

	#add Solaris Service Management Facility service
	case ${CHOST} in 
		*-solaris*)
					dodir /var/svc/manifest/application/print
					instinto /var/svc/manifest/application/print
					newins ${FILESDIR}/sol-svc-cups.xml cups.xml
					;;			
	esac
}

pkg_preinst() {
	# cleanups
	[ -n "${PN}" ] && rm -fR /usr/share/doc/${PN}-*

	# save original files
	if use preserve-original; then 
		einfo "Preserving original files..."
		for d in /usr/bin /usr/sbin; do
			cd ${D}/${d}
			for x in *; do
				if [ -f /${d}/${x} ]; then
					einfo "Saving ${d}/${x}"
					if [ -f /${d}/{x}.original ]; then 
						ewarn "${d}/${x}.original exists, skipping."
					else
						mv /${d}/${x} /${d}/${x}.original
					fi
				fi
			done
		done
	fi
}

pkg_postinst() {
	install -d -m0755 ${ROOT}/var/log/cups
	install -d -m0755 ${ROOT}/var/spool
	install -m0700 -o lp -d ${ROOT}/var/spool/cups
	install -m1700 -o lp -d ${ROOT}/var/spool/cups/tmp
	install -m0711 -o lp -d ${ROOT}/etc/cups/certs
	install -d -m0755 ${ROOT}/etc/cups/{interfaces,ppd}

	case ${CHOST} in 
		*-solaris*)
					einfo "Adding service 'cups' to SMF"
					svccfg import /var/svc/manifest/application/print/cups.xml
					einfo
					;;
	esac

	einfo "If you're using a USB printer, \"emerge coldplug; rc-update add"
	einfo "coldplug boot\" is something you should probably do. This"
	einfo "will allow any USB kernel modules (if present) to be loaded"
	einfo "automatically at boot."
	einfo
	einfo "For more information about installing a printer take a look at:"
	einfo "http://www.gentoo.org/doc/en/printing-howto.xml."

	einfo "You need to emerge ghostscript with the cups-USEflag turned on"

}
