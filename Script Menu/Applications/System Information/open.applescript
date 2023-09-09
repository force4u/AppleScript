#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.SystemProfiler") as text
###終了させてから
tell application id strBundleID to quit

####半ゾンビ化対策	
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat
delay 1
tell application id strBundleID to activate


repeat 5 times
	try
		tell application id strBundleID to activate
	end try
	tell application id strBundleID
		set boolFontmost to its frontmost
		log boolFontmost
	end tell
	if boolFontmost is false then
		delay 1
		tell application id strBundleID to activate
	else
		exit repeat
	end if
end repeat
delay 1
tell application id "com.apple.SystemProfiler" to activate
