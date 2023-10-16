#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###OS13までと分岐する
set recordSystemInfo to system info
set strVersion to (system version of recordSystemInfo) as text
##XXより大きいの場合は数値で比較
set numVersion to strVersion as number
if numVersion ≥ 14 then
	tell application id "com.apple.BluetoothFileExchange"
		activate
	end tell
else
	tell application id "com.apple.BluetoothFileExchange"
		launch
		activate
	end tell
end if
###
tell application "Finder"
	activate
	set theOpenAppPath to POSIX file "/System/Applications/Utilities/Bluetooth File Exchange.app" as alias
	open theOpenAppPath
end tell
##
tell application id "com.apple.BluetoothFileExchange" to activate
