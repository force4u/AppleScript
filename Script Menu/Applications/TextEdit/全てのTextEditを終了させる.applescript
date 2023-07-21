#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#   com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set strBundleID to "com.apple.TextEdit" as text

set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
delay 0.5
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
set numCntArray to ocidAppArray count
if numCntArray ≠ 0 then
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
else if numCntArray = 0 then
	return "全プロセス終了しました1"
end if
delay 0.5
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
set numCntArray to ocidAppArray count
if numCntArray = 0 then
	return "全プロセス終了しました2"
else
	delay 1
	itemAppArray's forceTerminate()
end if

return
