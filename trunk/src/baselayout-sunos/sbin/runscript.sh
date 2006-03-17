#!/bin/bash
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Common functions
[[ ${RC_GOT_FUNCTIONS} != "yes" ]] && source /sbin/functions.sh

# User must be root to run most script stuff (except status)
if [[ ${EUID} != 0 ]] && ! [[ $2 == "status" && $# -eq 2 ]] ; then
	eerror "$0: must be root to run init scripts"
	exit 1
fi

myscript="$1"
if [[ -L $1 && ! -L "/etc/init.d/${1##*/}" ]] ; then
	myservice="$(readlink "$1")"
else
	myservice="$1"
fi

myservice="${myservice##*/}"
export SVCNAME="${myservice}"

# Stop init scripts from working until sysinit completes
if [[ -e /dev/.rcsysinit ]] ; then
	eerror "ERROR:  cannot run ${myservice} until sysinit completes"
	exit 1
fi

svc_trap() {
	trap 'eerror "ERROR:  ${myservice} caught an interrupt"; exit 1' \
		INT QUIT TSTP
}

# Setup a default trap
svc_trap

# State variables
svcpause="no"
svcrestart="no"

# Functions to handle dependencies and services
[[ ${RC_GOT_SERVICES} != "yes" ]] && source "${svclib}/sh/rc-services.sh"
# Functions to control daemons
[[ ${RC_GOT_DAEMON} != "yes" ]] && source "${svclib}/sh/rc-daemon.sh"

# Set $IFACE to the name of the network interface if it is a 'net.*' script
if [[ ${myservice%%.*} == "net" && ${myservice#*.} != "${myservice}" ]] ; then
	IFACE="${myservice#*.}"
	NETSERVICE="yes"
else
	IFACE=
	NETSERVICE=
fi

# Source configuration files.
# (1) Source /etc/conf.d/net if it is a net.* service
# (2) Source /etc/conf.d/${myservice} to get initscript-specific
#     configuration (if it exists).
# (3) Source /etc/rc.conf to pick up potentially overriding
#     configuration, if the system administrator chose to put it
#     there (if it exists).
if [[ ${NETSERVICE} == "yes" ]] ; then
	conf="$(add_suffix /etc/conf.d/net)"
	[[ -e ${conf} ]] && source "${conf}"
fi
conf="$(add_suffix "/etc/conf.d/${myservice}")"
[[ -e ${conf} ]] && source "${conf}"
conf="$(add_suffix /etc/rc.conf)"
[[ -e ${conf} ]] && source "${conf}"

mylevel="${SOFTLEVEL}"
[[ ${SOFTLEVEL} == "${BOOTLEVEL}" \
	|| ${SOFTLEVEL} == "reboot" || ${SOFTLEVEL} == "shutdown" ]] \
	&& mylevel="${DEFAULTLEVEL}"

# Call svc_quit if we abort AND we have obtained a lock
service_started "${myservice}"
svcstarted="$?"
service_inactive "${myservice}"
svcinactive="$?"
svc_quit() {
	eerror "ERROR:  ${myservice} caught an interrupt"
	if service_inactive "${myservice}" || [[ ${svcinactive} == 0 ]] ; then
		mark_service_inactive "${myservice}"
	elif [[ ${svcstarted} == 0 ]] ; then
		mark_service_started "${myservice}"
	else
		mark_service_stopped "${myservice}"
	fi
	exit 1
}

usage() {
	local IFS="|"
	myline="Usage: ${myservice} { $* "
	echo
	eerror "${myline}}"
	eerror "       ${myservice} without arguments for full help"
}

stop() {
	# Return success so the symlink gets removed
	return 0
}

start() {
	eerror "ERROR:  ${myservice} does not have a start function."
	# Return failure so the symlink doesn't get created
	return 1
}

restart() {
	svc_restart
}

status() {
	# Dummy function
	return 0
}

svc_schedule_start() {
	local service="$1" start="$2"
	[[ ! -d "${svcdir}/scheduled/${service}" ]] \
		&& mkdir -p "${svcdir}/scheduled/${service}"
	[[ ! -e "${svcdir}/scheduled/${service}/${start}" ]] \
		&& ln -snf "/etc/init.d/${service}" \
			"${svcdir}/scheduled/${service}/${start}"
}

svc_start_scheduled() {
	[[ ! -d "${svcdir}/scheduled/${myservice}" ]] && return
	local x= services=

	for x in $(dolisting "${svcdir}/scheduled/${myservice}/") ; do
		services="${services} ${x##*/}"
	done
		
	for x in ${services} ; do
		service_stopped "${x}" && start_service "${x}"
		rm -f "${svcdir}/scheduled/${myservice}/${x}"
	done

	rmdir "${svcdir}/scheduled/${myservice}"
}

svc_stop() {
	local x= mydep= mydeps= retval=0
	local -a servicelist=()

	# Do not try to stop if it had already failed to do so
	if is_runlevel_stop && service_failed "${myservice}" ; then
		return 1
	elif service_stopped "${myservice}" ; then
		ewarn "WARNING:  ${myservice} has not yet been started."
		return 0
	fi
	if ! mark_service_stopping "${myservice}" ; then
		eerror "ERROR:  ${myservice} is already stopping."
		return 1
	fi
	
	# Ensure that we clean up if we abort for any reason
	trap "svc_quit" INT QUIT TSTP

	mark_service_starting "${myservice}"
	service_message "Service ${myservice} stopping"

	if in_runlevel "${myservice}" "${BOOTLEVEL}" && \
	   [[ ${SOFTLEVEL} != "reboot" && ${SOFTLEVEL} != "shutdown" && \
	      ${SOFTLEVEL} != "single" ]] ; then
		ewarn "WARNING:  you are stopping a boot service."
	fi
	
	if [[ ${svcpause} != "yes" ]] ; then
		if [[ ${NETSERVICE} == "yes" ]] ; then
			# A net.* service
			if in_runlevel "${myservice}" "${BOOTLEVEL}" || \
			   in_runlevel "${myservice}" "${mylevel}" ; then
				# Only worry about net.* services if this is the last one
				# running or if RC_NET_STRICT_CHECKING is set ...
				! is_net_up && mydeps="net"
			fi
			mydeps="${mydeps} ${myservice}"
		else
			mydeps="${myservice}"
		fi
	fi

	# Save the IN_BACKGROUND var as we need to clear it for stopping depends
	local ib_save="${IN_BACKGROUND}"
	unset IN_BACKGROUND

	for mydep in ${mydeps} ; do
		for x in $(needsme "${mydep}") ; do
			# Service not currently running, continue
			if service_started "${x}" ; then
				stop_service "${x}"
				service_list=( "${service_list[@]}" "${x}" )
			fi
		done
	done

	for x in "${service_list[@]}" ; do
		# We need to test if the service has been marked stopped
		# as the fifo may still be around if called by custom code
		# such as postup from a net script.
		service_stopped "${mynetservice}" && continue
		
		wait_service "${x}"
		if ! service_stopped "${x}" ; then
			retval=1
			break
		fi
	done

	IN_BACKGROUND="${ib_save}"

	if [[ ${retval} != 0 ]] ; then
		eerror "ERROR:  problems stopping dependent services."
		eerror "        ${myservice} is still up."
	else
		# Now that deps are stopped, stop our service
		( 
		exit() {
			RC_QUIET_STDOUT="no"
			eerror "DO NOT USE EXIT IN INIT.D SCRIPTS"
			eerror "This IS a bug, please fix your broken init.d"
			unset -f exit
			exit "$@"
		}
		# Stop einfo/ebegin/eend from working as parallel messes us up
		[[ ${RC_PARALLEL_STARTUP} == "yes" ]] && RC_QUIET_STDOUT="yes"
		stop
		)
		retval="$?"

		# If a service has been marked inactive, exit now as something
		# may attempt to start it again later
		if service_inactive "${myservice}" ; then
			svcinactive=0
			return 0
		fi
	fi

	if [[ ${retval} != 0 ]] ; then
		# Did we fail to stop? create symlink to stop multible attempts at
		# runlevel change.  Note this is only used at runlevel change ...
		is_runlevel_stop && mark_service_failed "${myservice}"
		
		# If we are halting the system, do it as cleanly as possible
		if [[ ${SOFTLEVEL} == "reboot" || ${SOFTLEVEL} == "shutdown" ]] ; then
			mark_service_stopped "${myservice}"
		else
			if [[ ${svcinactive} == 0 ]] ; then
				mark_service_inactive "${myservice}"
			else
				mark_service_started "${myservice}"
			fi
		fi

		service_message "eerror" "ERROR:  ${myservice} failed to stop"
	else
		svcstarted=1
		if service_inactive "${myservice}" ; then
			svcinactive=0
		else
			mark_service_stopped "${myservice}"
		fi
		service_message "Service ${myservice} stopped"
	fi

	# Reset the trap
	svc_trap
	
	return "${retval}"
}

svc_start() {
	local x= y= retval=0 startfail= startinactive=

	# Do not try to start if i have done so already on runlevel change
	if is_runlevel_start && service_failed "${myservice}" ; then
		return 1
	elif service_started "${myservice}" ; then
		ewarn "WARNING:  ${myservice} has already been started."
		return 0
	elif service_inactive "${myservice}" ; then
		if [[ ${IN_BACKGROUND} != "true" ]] ; then
			ewarn "WARNING:  ${myservice} has already been started."
			return 0
		fi
	fi

	if ! mark_service_starting "${myservice}" ; then
		if service_stopping "${myservice}" ; then
			eerror "ERROR:  ${myservice} is already stopping."
		else
			eerror "ERROR:  ${myservice} is already starting."
		fi
		return 1
	fi

	# Ensure that we clean up if we abort for any reason
	trap "svc_quit" INT QUIT TSTP

	service_message "Service ${myservice} starting"

	# Save the IN_BACKGROUND var as we need to clear it for starting depends
	local ib_save="${IN_BACKGROUND}"
	unset IN_BACKGROUND

	local startupservices="$(ineed "${myservice}") $(valid_iuse "${myservice}")"
	local netservices=
	for x in $(dolisting "/etc/runlevels/${BOOTLEVEL}/net.*") \
		$(dolisting "/etc/runlevels/${mylevel}/net.*") ; do
		netservices="${netservices} ${x##*/}"
	done

	# Start dependencies, if any.
	if ! is_runlevel_start ; then
		for x in ${startupservices} ; do
			if [[ ${x} == "net" && ${NETSERVICE} != "yes" ]] && ! is_net_up ; then
				for y in ${netservices} ; do
					service_stopped "${y}" && start_service "${y}"
				done
			elif [[ ${x} != "net" ]] ; then
				if service_stopped "${x}" ; then
					start_service "${x}"
				fi	
			fi
		done
	fi

	# We also wait for any services we're after to finish incase they
	# have a "before" dep but we don't dep on them.
	if is_runlevel_start ; then
		startupservices="${startupservices} $(valid_iafter "${myservice}")"
	fi

	if [[ " ${startupservices} " == *" net "* ]] ; then
		startupservices=" ${startupservices} "
		startupservices="${startupservices/ net / ${netservices} }"
		startupservices="${startupservices// net /}"
	fi

	# Wait for dependencies to finish.
	for x in ${startupservices} ; do
		service_started "${x}" && continue
		wait_service "${x}"
		if ! service_started "${x}" ; then
			# A 'need' dependency is critical for startup
			if ineed -t "${myservice}" "${x}" >/dev/null \
				|| net_service "${x}" && ineed -t "${myservice}" net \
				&& ! is_net_up ; then
				if service_inactive "${x}" || service_wasinactive "${x}" || \
				[[ -n $(ls "${svcdir}"/scheduled/*/"${x}" 2>/dev/null) ]] ; then
					svc_schedule_start "${x}" "${myservice}"
					startinactive="${x}"
				else
					startfail="${x}"
				fi
				break
			fi
		fi
	done
	
	if [[ -n ${startfail} ]] ; then
		eerror "ERROR:  Problem starting needed service ${startfail}"
		eerror "        ${myservice} was not started."
		retval=1
	elif [[ -n ${startinactive} ]] ; then
		ewarn "WARNING:  ${myservice} is scheduled to start when ${startinactive} has started."
		retval=1
	elif broken "${myservice}" ; then
		eerror "ERROR:  Some services needed are missing.  Run"
		eerror "        './${myservice} broken' for a list of those"
		eerror "        services.  ${myservice} was not started."
		retval=1
	else
		IN_BACKGROUND="${ib_save}"
		(
		exit() {
			RC_QUIET_STDOUT="no"
			eerror "DO NOT USE EXIT IN INIT.D SCRIPTS"
			eerror "This IS a bug, please fix your broken init.d"
			unset -f exit
			exit "$@"
		}

		# Apply any ulimits if defined
		[[ -n ${RC_ULIMIT} ]] && ulimit ${RC_ULIMIT}
		
		# Stop einfo/ebegin/eend from working as parallel messes us up
		[[ ${RC_PARALLEL_STARTUP} == "yes" ]] && RC_QUIET_STDOUT="yes"
		
		start
		)
		retval="$?"
		
		# If a service has been marked inactive, exit now as something
		# may attempt to start it again later
		if service_inactive "${myservice}" ; then
			svcinactive=0
			service_message "ewarn" "WARNING:  ${myservice} has started but is inactive"
			return 1
		fi
	fi

	if [[ ${retval} != 0 ]] ; then
		if [[ ${svcinactive} == 0 ]] ; then
			mark_service_inactive "${myservice}"
		else
			mark_service_stopped "${myservice}"
		fi

		if [[ -z ${startinactive} ]] ; then
			is_runlevel_start && mark_service_failed "${myservice}"
			service_message "eerror" "ERROR:  ${myservice} failed to start"
		fi
	else
		svcstarted=0
		mark_service_started "${myservice}"
		service_message "Service ${myservice} started"
	fi

	# Reset the trap
	svc_trap
	
	return "${retval}"
}

svc_restart() {
	if ! service_stopped "${myservice}" ; then
		svc_stop || return "$?"
	fi
	svc_start
}

svc_status() {
	# The basic idea here is to have some sort of consistent
	# output in the status() function which scripts can use
	# as an generic means to detect status.  Any other output
	# should thus be formatted in the custom status() function
	# to work with the printed " * status:  foo".
	local efunc="" state=""

	# If we are effectively root, check to see if required daemons are running
	# and update our status accordingly
	[[ ${EUID} == 0 ]] && update_service_status "${myservice}"

	if service_stopping "${myservice}" ; then
		efunc="eerror"
		state="stopping"
	elif service_starting "${myservice}" ; then
		efunc="einfo"
		state="starting"
	elif service_inactive "${myservice}" ; then
		efunc="ewarn"
		state="inactive"
	elif service_started "${myservice}" ; then
		efunc="einfo"
		state="started"
	else
		efunc="eerror"
		state="stopped"
	fi
	[[ ${RC_QUIET_STDOUT} != "yes" ]] \
		&& ${efunc} "status:  ${state}"

	status
	# Return 0 if started, otherwise 1
	[[ ${state} == "started" ]]
}

rcscript_errors="$(bash -n "${myscript}" 2>&1)" || {
	[[ -n ${rcscript_errors} ]] && echo "${rcscript_errors}" >&2
	eerror "ERROR:  ${myscript} has syntax errors in it; aborting ..."
	exit 1
}

# set *after* wrap_rcscript, else we get duplicates.
opts="start stop restart"

source "${myscript}"

# make sure whe have valid $opts
if [[ -z ${opts} ]] ; then
	opts="start stop restart"
fi

svc_homegrown() {
	local x arg="$1"
	shift

	# Walk through the list of available options, looking for the
	# requested one.
	for x in ${opts} ; do
		if [[ ${x} == "${arg}" ]] ; then
			if typeset -F "${x}" &>/dev/null ; then
				# Run the homegrown function
				"${x}"

				return $?
			fi
		fi
	done
	x=""

	# If we're here, then the function wasn't in $opts.
	[[ -n $* ]] && x="/ $* "
	eerror "ERROR: wrong args ( "${arg}" ${x})"
	# Do not quote this either ...
	usage ${opts}
	exit 1
}

shift
if [[ $# -lt 1 ]] ; then
	eerror "ERROR: not enough args."
	usage ${opts}
	exit 1
fi
for arg in $* ; do
	case "${arg}" in
	--quiet)
		RC_QUIET_STDOUT="yes"
		;;
# We check this in functions.sh ...
#	--nocolor)
#		RC_NOCOLOR="yes"
#		;;
	--verbose)
		RC_VERBOSE="yes"
		;;
	esac
done

retval=0
for arg in $* ; do
	case "${arg}" in
	stop)
		if [[ -e "${svcdir}/scheduled/${myservice}" ]] ; then
			rm -Rf "${svcdir}/scheduled/${myservice}"
		fi

		# Stoped from the background - treat this as a restart so that
		# stopped services come back up again when started.
		if [[ ${IN_BACKGROUND} == "true" ]] ; then
			rm -rf "${svcdir}/snapshot/$$"
			mkdir -p "${svcdir}/snapshot/$$"
			cp -pP "${svcdir}"/started/* "${svcdir}/snapshot/$$/"
			rm -f "${svcdir}/snapshot/$$/${myservice}"
		fi
	
		svc_stop
		retval="$?"
		
		if [[ ${IN_BACKGROUND} == "true" ]] ; then
			for x in $(dolisting "${svcdir}/snapshot/$$/") ; do
				if service_stopped "${x##*/}" ; then
					svc_schedule_start "${myservice}" "${x##*/}"
				fi
			done
		else
			rm -f "${svcdir}"/scheduled/*/"${myservice}"
		fi

		;;
	start)
		svc_start
		retval="$?"
		service_started "${myservice}" && svc_start_scheduled
		;;
	needsme|ineed|usesme|iuse|broken)
		trace_dependencies "-${arg}"
		;;
	status)
		svc_status
		retval="$?"
		;;
	zap)
		einfo "Manually resetting ${myservice} to stopped state."
		mark_service_stopped "${myservice}"
		;;
	restart)
		svcrestart="yes"

        # We don't kill child processes if we're restarting
		# This is especically important for sshd ....
		RC_KILL_CHILDREN="no"				
		
		# Create a snapshot of started services
		rm -rf "${svcdir}/snapshot/$$"
		mkdir -p "${svcdir}/snapshot/$$"
		cp -pP "${svcdir}"/started/* "${svcdir}/snapshot/$$/"
		rm -f "${svcdir}/snapshot/$$/${myservice}"

		# Simple way to try and detect if the service use svc_{start,stop}
		# to restart if it have a custom restart() funtion.
		if [[ -n $(egrep '^[[:space:]]*restart[[:space:]]*()' "/etc/init.d/${myservice}") ]] ; then
			if [[ -z $(egrep 'svc_stop' "/etc/init.d/${myservice}") || \
			      -z $(egrep 'svc_start' "/etc/init.d/${myservice}") ]] ; then
				echo
				ewarn "Please use 'svc_stop; svc_start' and not 'stop; start' to"
				ewarn "restart the service in its custom 'restart()' function."
				ewarn "Run ${myservice} without arguments for more info."
				echo
				svc_restart
			else
				restart
			fi
		else
			restart
		fi
		retval="$?"

		[[ -e "${svcdir}/scheduled/${myservice}" ]] \
			&& rm -Rf "${svcdir}/scheduled/${myservice}"
	
		# Restart dependencies as well
		for x in $(dolisting "${svcdir}/snapshot/$$/") ; do
			if service_stopped "${x##*/}" ; then
				if service_inactive "${myservice}" \
					|| service_wasinactive "${myservice}" ; then
					svc_schedule_start "${myservice}" "${x##*/}"
					ewarn "WARNING:  ${x##*/} is scheduled to start when ${myservice} has started."
				elif service_started "${myservice}" ; then
					start_service "${x##*/}"
				fi
			fi
		done
		rm -rf "${svcdir}/snapshot/$$"
	
		service_started "${myservice}" && svc_start_scheduled

		# Wait for services to come up
		[[ ${RC_PARALLEL_STARTUP} == "yes" ]] && wait

		svcrestart="no"
		;;
	pause)
		svcpause="yes"
		svc_stop
		retval="$?"
		svcpause="no"
		;;
	--quiet|--nocolor)
		;;
	help)
		exec "${svclib}"/sh/rc-help.sh "${myscript}" help
		;;
	*)
		# Allow for homegrown functions
		svc_homegrown ${arg}
		retval="$?"
		;;
	esac
done

exit "${retval}"

# vim:ts=4
