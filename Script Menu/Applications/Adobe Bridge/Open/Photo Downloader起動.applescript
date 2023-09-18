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


set strBundleID to ("com.adobe.photodownloader") as text

###################################
#####ãNìÆ
set ocidRunAppArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
if (count of ocidRunAppArray) ÅÇ 0 then
	log ocidRunApp's localizedName as text
	log "ãNìÆíÜÇ≈Ç∑"
else
	tell application id strBundleID to launch
	tell application id strBundleID to activate
end if
