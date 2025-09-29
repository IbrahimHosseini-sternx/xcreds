#!/bin/bash -e

#thanks to Simon Andersen for crafting the core of this.

if [ ! -d "/Library/LaunchAgents" ]; then
	mkdir /Library/LaunchAgents
fi

if [ -e "/Library/LaunchAgents/local.trioX.plist" ]; then
	echo "/Library/LaunchAgents/local.trioX.plist already exists. exiting."
else
	/usr/libexec/PlistBuddy -c "Add :Label string local.trioX" /Library/LaunchAgents/local.trioX.plist
	/usr/libexec/PlistBuddy -c "Add :ProgramArguments array" /Library/LaunchAgents/local.trioX.plist
	/usr/libexec/PlistBuddy -c "Add :ProgramArguments:0 string /Applications/trioX.app/Contents/MacOS/trioX" /Library/LaunchAgents/local.trioX.plist
	/usr/libexec/PlistBuddy -c "Add :KeepAlive bool YES" /Library/LaunchAgents/local.trioX.plist

	echo "successfully set up trioX to launch at login for every user."
fi 
