#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#General_Main:com.apple.wifi-settings-extension
# ICON:/System/Library//CoreServices/ManagedClient.app/Contents/PlugIns/ConfigurationProfilesUI.bundle/Contents/Resources/SystemPrefApp.icns
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###�N��
tell application id "com.apple.systempreferences" to activate
delay 0.5
###�N���҂�
tell application id "com.apple.systempreferences"
	###�N���m�F�@�ő�P�O�b
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell
tell application id "com.apple.systempreferences" to activate
tell application id "com.apple.systempreferences"
reveal anchor "General_Join" of pane id "com.apple.wifi-settings-extension"
end tell
tell application id "com.apple.finder"
open location "x-apple.systempreferences:com.apple.wifi-settings-extension?General_Join"
end tell
