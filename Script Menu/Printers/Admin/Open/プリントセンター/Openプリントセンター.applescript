#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set listBundleID to {"com.apple.printcenter", "com.apple.print.add"} as list

set strBundleID to ("com.apple.printcenter") as text

###################################
#####ãNìÆ
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	tell application id strBundleID
		try
			set numCntWindow to (count of every window) as integer
		on error
			set numCntWindow to 0
		end try
	end tell
else
	tell application id strBundleID to launch
	tell application id strBundleID to activate
end if
return



############################
###Å@com.apple.systemeventsâï˙
############################
set strBundleIDSystemEvent to ("com.apple.systemevents") as text
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleIDSystemEvent)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat

tell application "System Events" to quit
