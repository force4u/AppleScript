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

set listBundleID to {"com.vladidanila.vectornator", "com.linearity.vn", "iCloud.com.linearity.vn", "com.linearity.vn.home.show", "com.linearity.vn.document.edit", "com.linearity.vn.document.new", "com.linearity.vn.Thumbnails", "com.vectornator.item.layer", "com.vectornator.item.element"} as list


##2023.2.0.61611以前
set strBundleID to ("com.foxit-software.Foxit PDF Reader") as text
##2023.2.0.61611以降
set strBundleID to ("com.foxit-software.Foxit.PDF.Reader") as text

###################################
#####起動
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
###　com.apple.systemevents解放
############################
set strBundleIDSystemEvent to ("com.apple.systemevents") as text
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleIDSystemEvent)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat

tell application "System Events" to quit
