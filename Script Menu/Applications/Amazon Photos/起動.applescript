#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


## set strBundleID to ("amazon.photos.desktop") as text
set strBundleID to ("com.amazon.clouddrive.mac") as text



###################################
#####起動
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	##起動しているなら
	###ウィンドウの数を数えて
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	###ウィンドウの数が3以下の場合
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
