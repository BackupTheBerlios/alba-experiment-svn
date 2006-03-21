. /etc/make.conf
if [ -z "$PORTDIR_OVERLAY" ]; then
	echo PORTDIR_OVERLAY must be defined
fi
(cd /etc/ ; ln -s $PORTDIR_OVERLAY/profiles/default-sunos/x86/5.11 make.profile)
echo x86-sunos >> /usr/portage/profiles/arch.list

