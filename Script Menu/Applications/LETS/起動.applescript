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


###################################
### URLスキームから起動させる方法
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("LETS")
set ocidAppURL to ocidURLComponents's |URL|

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidAppURL)
log boolDone
return

###################################
### SystemEventでチェックしてから起動させる方法

##バンドルID
set strBundleID to ("jp.co.fontworks.LETS") as text

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
