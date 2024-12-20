#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions


set strBundleID to ("com.apple.systempreferences") as text

##CALL NEW systempreferences
tell application id "com.apple.systempreferences"
	activate
	set miniaturized of the settings window to false
end tell
tell application id "com.apple.finder"
	try
		open location "x-apple.systempreferences:com.apple.Profiles-Settings.extension?Main"
	end try
end tell
tell application id "com.apple.systempreferences"
	try
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
	end try
end tell

#path to mobileconfig
set aliasPathToMe to (path to me) as alias
tell application "Finder"
	set aliasConteinerDirPath to (container of aliasPathToMe) as alias
	set aliasPlistPath to (file "Lang_ja-JP.mobileconfig" of folder "plist" of folder aliasConteinerDirPath) as alias
end tell

tell application "Finder"
	open file aliasPlistPath
end tell


#After system event
delay 1
tell application "System Settings"
	tell front window
		set bounds to {0, 25, 720, 620}
	end tell
end tell
tell application "System Events"
	keystroke return
end tell
