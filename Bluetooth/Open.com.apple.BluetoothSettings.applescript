#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to "com.apple.systempreferences" as text

###システム設定を開く
set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidSystemPreferencesURL to refMe's NSURL's URLWithString:"x-apple.systempreferences:com.apple.BluetoothSettings"
appWorkspace's openURL:(ocidSystemPreferencesURL)


###システム設定を前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.systempreferences"))
set ocidApp to ocidAppArray's firstObject()
log ocidApp's |localizedName|() as text
set boolDone to ocidApp's activateWithOptions:(refMe's NSApplicationActivateIgnoringOtherApps)
log boolDone
###アクティブ待ち　最大１０秒
repeat 10 times
	set boolActive to ocidApp's active
	log boolActive as boolean
	if boolActive = (refMe's NSNumber's numberWithBool:true) then
		exit repeat
	else
		delay 0.5
		set boolDone to ocidApp's activateWithOptions:(refMe's NSApplicationActivateIgnoringOtherApps)
	end if
end repeat
###アクティブ待ち　最大１０秒
repeat 10 times
	tell application id strBundleID
		set boolFrontMost to frontmost as boolean
	end tell
	if boolFrontMost = true then
		exit repeat
	else
		delay 0.5
	end if
end repeat

