#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.ScriptMenuApp") as text

tell application id strBundleID to launch

tell application "System Events"
	set listProcessName to (bundle identifier of every process) as list
end tell

repeat 5 times
	if listProcessName contains strBundleID then
		exit repeat
	else
		tell application id strBundleID to launch
		delay 0.2
	end if
end repeat
