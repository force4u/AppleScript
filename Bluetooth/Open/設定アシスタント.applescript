#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

try
	tell application id "com.apple.BluetoothSetupAssistant"
		launch
		activate
	end tell
on error
	tell application "Finder"
		activate
		set theOpenAppPath to POSIX file "/System/Library/CoreServices/BluetoothSetupAssistant.app" as alias
		open theOpenAppPath
	end tell
end try