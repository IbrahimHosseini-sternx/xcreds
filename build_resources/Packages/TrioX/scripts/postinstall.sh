#!/bin/bash

set -e
set -x


script_path="${0}"
package_path="${1}"
target_path="${2}"
target_volume="${3}"
trioX_login_script="${target_path}"/Applications/trioX.app/Contents/Resources/trioX_login.sh
plugin_path="${target_path}"/Applications/trioX.app/Contents/Resources/TrioXLoginPlugin.bundle
auth_backup_folder="${target_path}"/Library/"Application Support"/trioX
rights_backup_path="${auth_backup_folder}"/rights.bak


if [ ! -e  "${auth_backup_folder}" ]; then
	mkdir -p "${auth_backup_folder}"
fi

if [ ! -e "${rights_backup_path}" ]; then 
	security authorizationdb read system.login.console > "${rights_backup_path}"
fi

if [ -e  "${plugin_path}" ]; then
	if [ -e "${target_volume}"/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle ]; then
		rm -rf "${target_volume}"/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle
	fi
	cp -R "${plugin_path}" "${target_volume}"/Library/Security/SecurityAgentPlugins/
	chown -R root:wheel "${target_volume}"/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle
fi

if [ -e ${trioX_login_script} ]; then
	"${trioX_login_script}" -i 
else
	echo "could not find trioX_login_script tool"
	exit -1
fi

if /usr/bin/pgrep -q "Setup Assistant"; then
    # loginwindow hasn't been displayed yet - exit successfully
    /usr/bin/logger "trioX: authorization mechanic setup complete"
    echo "trioX: authorization mechanic setup complete"
    exit 0
fi

while [[ ! -f "/var/db/.AppleSetupDone" ]]; do
 sleep 1
 /usr/bin/logger "Waiting for Setup Assistant to complete"
 echo "Waiting for Setup Assistant to complete"
done

#if [ -e "${target_volume}"/Applications/trioX.app/Contents/MacOS/trioX ]; then
#
#	echo "briefly starting up trioX app to register CCID extension"
#	"${target_volume}"/Applications/trioX.app/Contents/MacOS/trioX -r
#
#fi

# if Finder is not loaded and override file doesn't exist, reload the loginwindow
if  /usr/bin/pgrep -q "Finder"  || [ -f /Users/Shared/.trioXPreventLoginWindowKill ]; then
	exit 0
else 
	/usr/bin/logger "trioX: Reload loginwindow"
	/usr/bin/killall -9 loginwindow
fi
