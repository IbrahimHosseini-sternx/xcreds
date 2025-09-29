#!/bin/bash

script_path="$0"
script_folder=$(dirname "${script_path}")
authrights_path="${script_folder}"/authrights
plugin_path="${script_folder}"/TrioXLoginPlugin.bundle
plugin_resources_path="${plugin_path}"/Contents/Resources
overlay_path="${script_folder}"/"TrioX Login Overlay.app"
overlay_resources_path="${overlay_path}"/Contents/Resources
auth_backup_folder=/Library/"Application Support"/trioX
rights_backup_path="${auth_backup_folder}"/rights.bak
launch_agent_config_name="so.trio.trioX-overlay.plist"
app_launch_agent_config_name="so.trio.trioX-launchagent.plist"
launch_agent_destination_path="/Library/LaunchAgents/"
launch_agent_source_path="${overlay_resources_path}"/"${launch_agent_config_name}"
app_launch_agent_source_path="${script_folder}"/"${app_launch_agent_config_name}"

autofill_path="${target_path}/Applications/trioX.app/Contents/Resources/TrioX Login Autofill.app/Contents/PlugIns/TrioX Login Password.appex"


f_install=0
f_remove=0
f_restore=0

remove_rights () {
    "${authrights_path}" -d  "TrioXLoginPlugin:UserSetup,privileged"
    "${authrights_path}" -r  "TrioXLoginPlugin:LoginWindow" "loginwindow:login" > /dev/null
    "${authrights_path}" -d  "TrioXLoginPlugin:PowerControl,privileged"
    "${authrights_path}" -d  "TrioXLoginPlugin:KeychainAdd,privileged"
    "${authrights_path}" -d  "TrioXLoginPlugin:CreateUser,privileged"
    "${authrights_path}" -d  "TrioXLoginPlugin:EnableFDE,privileged"
    "${authrights_path}" -d  "TrioXLoginPlugin:LoginDone"

}
while getopts ":ire" o; do
	case "${o}" in
		i)
			f_install=1
		;;
		r)
			f_remove=1
		;;
        e)
            f_restore=1
        ;;

	esac
done



if [ $(id -u) -ne 0 ]; then
	echo please run with sudo
	exit -1
fi


if [ $f_install -eq 1 ] && [ $f_remove -eq 1 ]; then
	echo "you can't specify both -i and -r"
	exit -1
fi

if [ $f_install -eq 1 ]; then
	
	if [ ! -e  "${auth_backup_folder}" ]; then
		mkdir -p "${auth_backup_folder}"
	fi
	
	if [ ! -e "${rights_backup_path}" ]; then 
		security authorizationdb read system.login.console > "${rights_backup_path}"
		
	fi

    if [ -e "${autofill_path}" ]; then
        /usr/bin/pluginkit -a "${autofill_path}"
    fi
	if [ -e  "${plugin_path}" ]; then
		
		cp -R "${plugin_path}" "${target_volume}"/Library/Security/SecurityAgentPlugins/
		chown -R root:wheel "${target_volume}"/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle
	fi
	#app_launch_agent_source_path


    if [ ! -e "${launch_agent_destination_path}"/"${app_launch_agent_config_name}" ]; then

        cp "${app_launch_agent_source_path}" "${launch_agent_destination_path}"
    fi


	if [ ! -e "${launch_agent_destination_path}"/"${launch_agent_config_name}" ]; then
	
		cp "${launch_agent_source_path}" "${launch_agent_destination_path}"
	fi

	if [ -e ${authrights_path} ]; then
         remove_rights

        "${authrights_path}" -b "loginwindow:login" "TrioXLoginPlugin:UserSetup,privileged"
        "${authrights_path}" -r "loginwindow:login" "TrioXLoginPlugin:LoginWindow"
        "${authrights_path}" -a  "TrioXLoginPlugin:LoginWindow" "TrioXLoginPlugin:PowerControl,privileged"
        "${authrights_path}" -a  "loginwindow:done" "TrioXLoginPlugin:KeychainAdd,privileged"
        "${authrights_path}" -a  "builtin:login-begin" "TrioXLoginPlugin:CreateUser,privileged"
        "${authrights_path}" -a  "loginwindow:done" "TrioXLoginPlugin:EnableFDE,privileged"
        "${authrights_path}" -a  "loginwindow:done" "TrioXLoginPlugin:LoginDone"

	else
		echo "could not find authrights tool"
		exit -1
	fi

	
elif [ $f_remove -eq 1 ]; then

    remove_rights

	if [ -e  "/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle" ]; then
		rm -rf "/Library/Security/SecurityAgentPlugins/TrioXLoginPlugin.bundle"
		
	fi
	
	if [ -e "${launch_agent_destination_path}"/"${launch_agent_config_name}" ]; then
		rm "${launch_agent_destination_path}"/"${launch_agent_config_name}"
	fi

     if [ -e "${launch_agent_destination_path}"/"${app_launch_agent_config_name}" ]; then
        rm "${launch_agent_destination_path}"/"${app_launch_agent_config_name}"
    fi


elif [ $f_restore -eq 1 ]; then
    if [ -e "${rights_backup_path}" ]; then
        security authorizationdb write system.login.console < "${rights_backup_path}"
    else
        echo "no backup found to restore at \"${rights_backup_path}\""
    fi



else 
	echo "you must specify -i (install right), -r (remove right), or -e (restore all rights from backup)."
	exit -1
	
fi
