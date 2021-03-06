# /lib/rcscripts/addons/dm-crypt-start.sh

# Setup mappings for an individual target/swap
# Note: This relies on variables localized in the main body below.
dm-crypt-execute-checkfs() {
	local dev ret mode
	# some colors
	local red='\x1b[31;01m' green='\x1b[32;01m' off='\x1b[0;0m'

	if [ -n "$target" ]; then
		# let user set options, otherwise leave empty
		: ${options:=' '}
	elif [ -n "$swap" ]; then
		target=${swap}
		# swap contents do not need to be preserved between boots, luks not required.
		# suspend2 users should have initramfs's init handling their swap partition either way.
		: ${options:='-c aes -h sha1 -d /dev/urandom'}
		: ${pre_mount:='mkswap ${dev}'}
	else
		return
	fi
	if [ -z "$source" ] && [ ! -e "$source" ]; then
		ewarn "source \"${source}\" for ${target} missing, skipping..."
		return
	fi

	if [[ -n ${loop_file} ]] ; then
		dev="/dev/mapper/${target}"
		ebegin "  Setting up loop device ${source}"
		/sbin/losetup ${source} ${loop_file}
	fi

	# cryptsetup:
	# luksOpen <device> <name>      # <device> is $source
	# create   <name>   <device>    # <name>   is $target
	local arg1="create" arg2="$target" arg3="$source" luks=0

	cryptsetup isLuks ${source} 2>/dev/null && { arg1="luksOpen"; arg2="$source"; arg3="$target"; luks=1; }

	if /bin/cryptsetup status ${target} | egrep -q '\<active:' ; then
		einfo "dm-crypt mapping ${target} is already configured"
		return
	fi
	# Handle keys
	if [ -n "$key" ]; then
		# Notes: sed not used to avoid case where /usr partition is encrypted.
		mode=${key/*:/} && ( [ "$mode" == "$key" ] || [ -z "$mode" ] ) && mode=reg
		key=${key/:*/}
		case "$mode" in
		gpg|reg)
			# handle key on removable device
			if [ -n "$remdev" ]; then
				# temp directory to mount removable device
				local mntrem=/mnt/remdev
				local c=0 ans
				for (( i = 0 ; i < 10 ; i++ ))
				do
					[ ! -d "$mntrem" ] && mkdir -p ${mntrem} 2>/dev/null >/dev/null
					if mount -n -o ro ${remdev} ${mntrem} 2>/dev/null >/dev/null ; then
						sleep 2
						# keyfile exists?
						if [ ! -e "${mntrem}${key}" ]; then
							umount -n ${mntrem} 2>/dev/null >/dev/null
							rmdir ${mntrem} 2>/dev/null >/dev/null
							einfo "Cannot find ${key} on removable media."
							echo -n -e " ${green}*${off}  Abort?(${red}yes${off}/${green}no${off})" >/dev/console	
							read ans </dev/console
							echo	>/dev/console
							[ "$ans" != "yes" ] && { i=0; c=0; } || return 
						else
							key="${mntrem}${key}"
							break
						fi
					else
						[ "$c" -eq 0 ] && einfo "Please insert removable device for ${target}"
						c=1
						sleep 2
						# let user abort
						if [ "$i" -eq 9 ]; then
							rmdir ${mntrem} 2>/dev/null >/dev/null
							einfo "Removable device for ${target} not present."
							echo -n -e " ${green}*${off}  Abort?(${red}yes${off}/${green}no${off})" >/dev/console
							read ans </dev/console
							echo  >/dev/console
							[ "$ans" != "yes" ] && { i=0; c=0; } || return
						fi
					fi
				done
			else    # keyfile ! on removable device
				if [ ! -e "$key" ]; then
					ewarn "${source} will not be decrypted ..."
					einfo "Reason: keyfile ${key} does not exist."
					return
				fi
			fi
			;;
		*)
			ewarn "${source} will not be decrypted ..."
			einfo "Reason: mode ${mode} is invalid."
			return
			;;
		esac
	else
		mode=none
	fi
	splash svc_input_begin checkfs
	ebegin "dm-crypt map ${target}"
	einfo "cryptsetup will be called with : ${options} ${arg1} ${arg2} ${arg3}"
	if [ "$mode" == "gpg" ]; then
		: ${gpg_options:='-q -d'}
		# gpg available ?
		if type -p gpg >/dev/null ; then
			for (( i = 0 ; i < 3 ; i++ ))
			do
				# paranoid, don't store key in a variable, pipe it so it stays very little in ram unprotected.
				# save stdin stdout stderr "values"
				exec 3>&0 4>&1 6>&2 # ABS says fd 5 is reserved
				exec &>/dev/console </dev/console
				gpg ${gpg_options} ${key} 2>/dev/null | cryptsetup ${options} ${arg1} ${arg2} ${arg3}
				ret="$?"
				# restore values and close file descriptors
				exec 0>&3 1>&4 2>&6
				exec 3>&- 4>&- 6>&-
				[ "$ret" -eq 0 ] && break
			done
			eend "${ret}" "failure running cryptsetup"
		else
			ewarn "${source} will not be decrypted ..."
			einfo "Reason: cannot find gpg application."     
			einfo "You have to install app-crypt/gnupg first."
			einfo "If you have /usr on its own partition, try copying gpg to /bin ."
		fi
	else
		if [ "$mode" == "reg" ]; then
			cryptsetup ${options} -d ${key} ${arg1} ${arg2} ${arg3} >/dev/console </dev/console
			ret="$?"
			eend "${ret}" "failure running cryptsetup"
		else
			cryptsetup ${options} ${arg1} ${arg2} ${arg3} >/dev/console </dev/console
			ret="$?"
			eend "${ret}" "failure running cryptsetup"
		fi
	fi
	if [ -d "$mntrem" ]; then
		umount -n ${mntrem} 2>/dev/null >/dev/null
		rmdir ${mntrem} 2>/dev/null >/dev/null
	fi
	splash svc_input_end checkfs

	if [[ ${ret} != 0 ]] ; then
		cryptfs_status=1
	else
		if [[ -n ${pre_mount} ]] ; then
			dev="/dev/mapper/${target}"
			ebegin "  Running pre_mount commands for ${target}"
			eval "${pre_mount}" > /dev/null
			ewend $? || cryptfs_status=1
		fi
	fi
}

# Run any post_mount commands for an individual mount
#
# Note: This relies on variables localized in the main body below.
dm-crypt-execute-localmount() {
	local mount_point

	[ -z "$target" ] && [ -z "$post_mount" ] && return

	if ! /bin/cryptsetup status ${target} | egrep -q '\<active:' ; then
		ewarn "Skipping unmapped target ${target}"
		cryptfs_status=1
		return
	fi

	mount_point=$(grep "/dev/mapper/${target}" /proc/mounts | cut -d' ' -f2)
	if [[ -z ${mount_point} ]] ; then
		ewarn "Failed to find mount point for ${target}, skipping"
		cryptfs_status=1
	fi

	if [[ -n ${post_mount} ]] ; then
		ebegin "Running post_mount commands for target ${target}"
		eval "${post_mount}" >/dev/null
		eend $? || cryptfs_status=1
	fi
}

local cryptfs_status=0
local gpg_options key loop_file target targetline options pre_mount post_mount source swap remdev

if [[ -f /etc/conf.d/cryptfs ]] && [[ -x /bin/cryptsetup ]] ; then
	ebegin "Setting up dm-crypt mappings"

	while read targetline ; do
		# skip comments and blank lines
		[[ ${targetline}\# == \#* ]] && continue

		# check for the start of a new target/swap
		case ${targetline} in
			target=*|swap=*)
				# If we have a target queued up, then execute it
				dm-crypt-execute-${myservice}

				# Prepare for the next target/swap by resetting variables
				unset gpg_options key loop_file target options pre_mount post_mount source swap remdev
				;;

			gpg_options=*|remdev=*|key=*|loop_file=*|options=*|pre_mount=*|post_mount=*|source=*)
				if [[ -z ${target} && -z ${swap} ]] ; then
					ewarn "Ignoring setting outside target/swap section: ${targetline}"
					continue
				fi
				;;

			*)
				ewarn "Skipping invalid line in /etc/conf.d/cryptfs: ${targetline}"
				;;
		esac

		# Queue this setting for the next call to dm-crypt-execute-${myservice}
		eval "${targetline}"
	done < /etc/conf.d/cryptfs

	# If we have a target queued up, then execute it
	dm-crypt-execute-${myservice}

	ewend ${cryptfs_status} "Failed to setup dm-crypt devices"
fi

# vim:ts=4
