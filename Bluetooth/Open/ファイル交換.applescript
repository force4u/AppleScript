#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

try
		tell application id "com.apple.BluetoothFileExchange"
		launch
		activate
	end tell

on error
		tell application "Finder"
		activate
		set theOpenAppPath to POSIX file "/System/Applications/Utilities/Bluetooth File Exchange.app" as alias
		open theOpenAppPath
	end tell

end try