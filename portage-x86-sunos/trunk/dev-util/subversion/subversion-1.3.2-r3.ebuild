# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/subversion/subversion-1.3.2-r3.ebuild,v 1.12 2006/10/20 21:15:11 kloeri Exp $

inherit elisp-common libtool python eutils bash-completion flag-o-matic depend.apache perl-module java-pkg-opt-2

DESCRIPTION="A compelling replacement for CVS"
HOMEPAGE="http://subversion.tigris.org/"
SRC_URI="http://subversion.tigris.org/downloads/${P/_rc/-rc}.tar.bz2"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ~ppc-macos ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-sunos"
IUSE="apache2 berkdb python emacs perl java nls nowebdav zlib ruby"
RESTRICT="test"

COMMONDEPEND="apache2? ( ${APACHE2_DEPEND} )
	>=dev-libs/apr-util-0.9.5
	python? ( >=dev-lang/python-2.0 )
	perl? ( >=dev-lang/perl-5.8.6-r6
		!=dev-lang/perl-5.8.7 )
	ruby? ( >=dev-lang/ruby-1.8.2 )
	!nowebdav? ( >=net-misc/neon-0.26 )
	berkdb? ( =sys-libs/db-4* )
	zlib? ( sys-libs/zlib )
	java? ( >=virtual/jdk-1.4 )
	emacs? ( virtual/emacs )"
RDEPEND="${COMMONDEPEND}
	java? ( >=virtual/jre-1.4 )"

DEPEND="${COMMONDEPEND}
	java? ( >=virtual/jdk-1.4 )
	>=sys-devel/autoconf-2.59"

S=${WORKDIR}/${P/_rc/-rc}

# Allow for custion repository locations.
# This can't be in pkg_setup because the variable needs to be available to
# pkg_config.
: ${SVN_REPOS_LOC:=/var/svn}

pkg_setup() {
	if use berkdb && has_version '<dev-util/subversion-0.34.0' && [[ -z ${SVN_DUMPED} ]]; then
		echo
		ewarn "Presently you have $(best_version subversion)"
		ewarn "Subversion has changed the repository filesystem schema from 0.34.0."
		ewarn "So you MUST dump your repositories before upgrading."
		ewarn
		ewarn 'After doing so call emerge with SVN_DUMPED=1 emerge !*'
		ewarn
		ewarn "More details on dumping:"
		ewarn "http://svn.collab.net/repos/svn/trunk/notes/repos_upgrade_HOWTO"
		echo
		die "Ensure that you dump your repository first"
	fi
	java-pkg-opt-2_pkg_setup
}

src_unpack() {
	unpack $A
	cd ${S}

	epatch ${FILESDIR}/subversion-db4.patch
	epatch ${FILESDIR}/subversion-1.1.1-perl-vendor.patch
	epatch ${FILESDIR}/subversion-hotbackup-config.patch
	epatch ${FILESDIR}/subversion-1.3.1-neon-config.patch
	epatch ${FILESDIR}/subversion-apr_cppflags.patch
	# rapidsvn developers work with 1.3.2
	epatch ${FILESDIR}/subversion-1.3.1-neon-0.26.patch

	export WANT_AUTOCONF=2.5
	autoconf
	(cd apr; autoconf)
	(cd apr-util; autoconf)
	sed -i -e 's,\(subversion/svnversion/svnversion.*\)\(>.*svn-revision.txt\),echo "exported" \2,' Makefile.in

	elibtoolize

	use emacs && cp ${FILESDIR}/vc-svn.el ${S}/contrib/client-side/vc-svn.el
}

src_compile() {
	local myconf
	myconf="--with-apr=/usr --with-apr-util=/usr"

	use apache2 && myconf="${myconf} --with-apxs=${APXS2}"
	use apache2 || myconf="${myconf} --without-apxs"

	myconf="${myconf} $(use_enable java javahl)"
	use java && myconf="${myconf} --without-jikes --with-jdk=${JAVA_HOME}"

	if use python || use perl || use ruby; then
		myconf="${myconf} --with-swig"
	else
		myconf="${myconf} --without-swig"
	fi

	if use nowebdav; then
		myconf="${myconf} --without-neon"
	else
		myconf="${myconf} --with-neon=/usr"
	fi

	append-flags `/usr/bin/apr-config --cppflags`

	econf ${myconf} \
		$(use_with berkdb berkeley-db) \
		$(use_with zlib) \
		$(use_with python) \
		$(use_enable nls) \
		--with-apr=/usr \
		--with-apr-util=/usr \
		--disable-experimental-libtool \
		--disable-mod-activation || die "econf failed"

	# Respect the user LDFLAGS
	export EXTRA_LDFLAGS="${LDFLAGS}"

	# Build subversion, but do it in a way that is safe for parallel builds.
	# Also apparently the included apr has a libtool that doesn't like -L flags.
	# So not specifying it at all when not building apache modules and only
	# specify it for internal parts otherwise.
	( emake external-all && emake LT_LDFLAGS="-L${D}/usr/$(get_libdir)" local-all ) || die "make of subversion failed"

	if use python; then
		# Building fails without the apache apr-util as includes are wrong.
		emake swig-py || die "subversion python bindings failed"
	fi

	if use perl; then
		# Work around a buggy Makefile.PL, bug 64634
		mkdir -p subversion/bindings/swig/perl/native/blib/arch/auto/SVN/{_Client,_Delta,_Fs,_Ra,_Repos,_Wc}
		emake swig-pl || die "Perl library building failed"
	fi

	if use ruby; then
		emake swig-rb || die "Ruby library building failed"
	fi

	if use java; then
		# ensure that the destination dir exists, else some compilation fails
		mkdir -p ${S}/subversion/bindings/java/javahl/classes
		# Compile javahl
		emake JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl || die "Compilation failed"
	fi

	if use emacs; then
		einfo "compiling emacs support"
		elisp-compile ${S}/contrib/client-side/psvn/psvn.el || die "emacs modules failed"
		elisp-compile ${S}/contrib/client-side/vc-svn.el || die "emacs modules failed"
	fi

	# svn-config isn't quite built correctly; it contains references to
	# @SVN_DB_LIBS@ and @SVN_DB_INCLUDES@.  It appears the best thing is to remove that.  #64634
	sed -i 's/@SVN_DB_[^@]*@//g' svn-config || die "sed failed"
}


src_install () {
	python_version
	PYTHON_DIR=/usr/$(get_libdir)/python${PYVER}

	emake DESTDIR=${D} install || die "Installation of subversion failed"

#	This might not be necessary with the new install
#	if [[ -e ${D}/usr/$(get_libdir)/apache2 ]]; then
#		if [ "${APACHE2_MODULESDIR}" != "/usr/$(get_libdir)/apache2/modules" ]; then
#			mkdir -p ${D}/`dirname ${APACHE2_MODULESDIR}`
#			mv ${D}/usr/$(get_libdir)/apache2/modules ${D}/${APACHE2_MODULESDIR}
#			rmdir ${D}/usr/$(get_libdir)/apache2 2>/dev/null
#		fi
#	fi


	dobin svn-config
	if use python; then
		emake install-swig-py DESTDIR=${D} DISTUTIL_PARAM=--prefix=${D}  LD_LIBRARY_PATH="-L${D}/usr/$(get_libdir)" || die "Installation of subversion python bindings failed"

		# move python bindings
		mkdir -p ${D}${PYTHON_DIR}/site-packages
		mv ${D}/usr/$(get_libdir)/svn-python/svn ${D}${PYTHON_DIR}/site-packages
		mv ${D}/usr/$(get_libdir)/svn-python/libsvn ${D}${PYTHON_DIR}/site-packages
		rmdir ${D}/usr/$(get_libdir)/svn-python
	fi
	if use perl; then
		emake DESTDIR=${D} install-swig-pl || die "Perl library building failed"
		fixlocalpod
	fi
	if use ruby; then
		emake DESTDIR=${D} install-swig-rb || die "Installation of subversion ruby bindings failed"
	fi
	if use java; then
		emake DESTDIR="${D}" install-javahl || die "installation failed"
		java-pkg_regso ${D}/usr/$(get_libdir)/libsvnjavahl*.so
		java-pkg_dojar ${D}/usr/$(get_libdir)/svn-javahl/svn-javahl.jar
		rm -r ${D}/usr/$(get_libdir)/svn-javahl/*.jar
	fi

	# Install apache module config
	if useq apache2; then
		MOD="${APACHE2_MODULESDIR/${APACHE2_BASEDIR}\//}"
		mkdir -p ${D}/${APACHE2_MODULES_CONFDIR}
		cat <<EOF >${D}/${APACHE2_MODULES_CONFDIR}/47_mod_dav_svn.conf
<IfDefine SVN>
	<IfModule !mod_dav_svn.c>
		LoadModule dav_svn_module	${MOD}/mod_dav_svn.so
	</IfModule>
	<Location /svn/repos>
		DAV svn
		SVNPath ${SVN_REPOS_LOC}/repos
		AuthType Basic
		AuthName "Subversion repository"
		AuthUserFile ${SVN_REPOS_LOC}/conf/svnusers
		Require valid-user
	</Location>
	<IfDefine SVN_AUTHZ>
		<IfModule !mod_authz_svn.c>
			LoadModule authz_svn_module	${MOD}/mod_authz_svn.so
		</IfModule>
	</IfDefine>
</IfDefine>
EOF
	fi

	# Bug 43179 - Install bash-completion if user wishes
	dobashcompletion tools/client-side/bash_completion subversion

	# Install hot backup script, bug 54304
	newbin tools/backup/hot-backup.py svn-hot-backup

	# The svn_load_dirs script is installed by Debian and looks like a good
	# candidate for us to install as well
	newbin contrib/client-side/svn_load_dirs.pl svn-load-dirs

	# Install svnserve init-script and xinet.d snippet, bug 43245
	exeinto /etc/init.d ; newexe ${FILESDIR}/svnserve.initd svnserve
	insinto /etc/conf.d ; newins ${FILESDIR}/svnserve.confd svnserve
	insinto /etc/xinetd.d ; newins ${FILESDIR}/svnserve.xinetd svnserve

	# Install documentation

	dodoc BUGS COMMITTERS COPYING HACKING INSTALL README
	dodoc CHANGES
	dodoc tools/xslt/svnindex.css tools/xslt/svnindex.xsl
	find contrib tools -name \*.in -print0 | xargs -0 rm -f
	mkdir -p ${D}/usr/share/doc/${PF}/
	cp -r tools/{client-side,examples,hook-scripts} ${D}/usr/share/doc/${PF}/
	cp -r contrib/hook-scripts ${D}/usr/share/doc/${PF}/

	docinto notes
	for f in notes/*
	do
		[[ -f ${f} ]] && dodoc ${f}
	done

	# Install emacs lisps
	if use emacs; then
		insinto /usr/share/emacs/site-lisp/subversion
		doins contrib/client-side/psvn/psvn.el*
		doins contrib/client-side/vc-svn.el*

		elisp-site-file-install ${FILESDIR}/70svn-gentoo.el
	fi
}

src_test() {
	ewarn "Testing does not work for subversion"
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use perl && perl-module_pkg_postinst

	einfo "Subversion Server Notes"
	einfo "-----------------------"
	einfo

	einfo "If you intend to run a server, a repository needs to be created using"
	einfo "svnadmin (see man svnadmin) or the following command to create it in"
	einfo "/var/svn:"
	einfo
	einfo "    emerge --config =${CATEGORY}/${PF}"
	einfo
	einfo "If you upgraded from an older version of berkely db and experience"
	einfo "problems with your repository then run the following commands as root:"
	einfo "    db4_recover -h ${SVN_REPOS_LOC}/repos"
	einfo "    chown -Rf apache:apache ${SVN_REPOS_LOC}/repos"
	einfo
	einfo "Subversion has multiple server types, take your pick:"
	einfo
	einfo " - svnserve daemon: "
	einfo "   1. edit /etc/conf.d/svnserve"
	einfo "   2. start daemon: /etc/init.d/svnserve start"
	einfo "   3. make persistent: rc-update add svnserve default"
	einfo
	einfo " - svnserve via xinetd:"
	einfo "   1. edit /etc/xinetd.d/svnserve (remove disable line)"
	einfo "   2. restart xinetd.d: /etc/init.d/xinetd restart"
	einfo
	einfo " - svn over ssh:"
	einfo "   1. Fix the repository permissions:"
	einfo "        groupadd svnusers"
	einfo "        chown -R root:svnusers /var/svn/repos/"
	einfo "        chmod -R g-w /var/svn/repos"
	einfo "        chmod -R g+rw /var/svn/repos/db"
	einfo "        chmod -R g+rw /var/svn/repos/locks"
	einfo "   2. create an svnserve wrapper in /usr/local/bin to set the umask you"
	einfo "      want, for example:"
	einfo "         #!/bin/bash"
	einfo "         umask 002"
	einfo "         exec /usr/bin/svnserve \"\$@\""
	einfo

	if use apache2 >/dev/null; then
		einfo " - http-based server:"
		einfo "   1. edit /etc/conf.d/apache2 to include both \"-D DAV\" and \"-D SVN\""
		einfo "   2. create an htpasswd file:"
		einfo "      htpasswd2 -m -c ${SVN_REPOS_LOC}/conf/svnusers USERNAME"
		einfo
	fi

	einfo "If you intend to use svn-hot-backup, you can specify the number of"
	einfo "backups to keep per repository by specifying an environment variable."
	einfo "If you want to keep e.g. 2 backups, do the following:"
	einfo "echo '# hot-backup: Keep that many repository backups around' > /etc/env.d/80subversion"
	einfo "echo 'SVN_HOTBACKUP_NUM_BACKUPS=2' >> /etc/env.d/80subversion"
	einfo ""
}

pkg_postrm() {
	has_version virtual/emacs && elisp-site-regen
	use perl && perl-module_pkg_postrm
}

pkg_config() {
	if [[ ! -x /usr/bin/svnadmin ]]; then
		die "You seem to only have built the subversion client"
	fi

	einfo ">>> Initializing the database in ${SVN_REPOS_LOC}..."
	if [[ -e ${SVN_REPOS_LOC}/repos ]]; then
		echo "A subversion repository already exists and I will not overwrite it."
		echo "Delete ${SVN_REPOS_LOC}/repos first if you're sure you want to have a clean version."
	else
		mkdir -p ${SVN_REPOS_LOC}/conf
		einfo ">>> Populating repository directory ..."
		# create initial repository
		/usr/bin/svnadmin create ${SVN_REPOS_LOC}/repos

		einfo ">>> Setting repository permissions ..."
		chown -Rf apache:apache ${SVN_REPOS_LOC}/repos
		chmod -Rf 755 ${SVN_REPOS_LOC}/repos
	fi
}
