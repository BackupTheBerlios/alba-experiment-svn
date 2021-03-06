# /lib/rcscripts/addons/dm-crypt-stop.sh

# Try to remove any dm-crypt mappings
csetup=/bin/cryptsetup
if [ -f /etc/conf.d/cryptfs ] && [ -x "$csetup" ]
then
	einfo "Removing dm-crypt mappings"

	/bin/egrep "^(target|swap)" /etc/conf.d/cryptfs | \
	while read targetline
	do
		target=
		swap=

		eval ${targetline}

		[ -n "${swap}" ] && target=${swap}
		[ -z "${target}" ] && ewarn "Invalid line in /etc/conf.d/cryptfs: ${targetline}"

		ebegin "Removing dm-crypt mapping for: ${target}"
		${csetup} remove ${target}
		eend $? "Failed to remove dm-crypt mapping for: ${target}"
	done

	if [[ -n $(/bin/egrep -e "^(source=)./dev/loop*" /etc/conf.d/cryptfs) ]] ; then
		einfo "Taking down any dm-crypt loop devices"
		/bin/egrep -e "^(source)" /etc/conf.d/cryptfs | while read sourceline
		do
			source=
			eval ${sourceline}
			if [[ -n $(echo ${source} | grep /dev/loop) ]] ; then
				ebegin "   Taking down ${source}"
				/sbin/losetup -d ${source}
				eend $? "  Failed to remove loop"
			fi
		done
	fi
fi

# vim:ts=4
