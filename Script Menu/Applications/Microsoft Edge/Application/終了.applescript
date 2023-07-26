#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application
############################
### 設定
############################
####メインのバンドルID
set strBundleID to ("com.microsoft.edgemac") as text
###ヘルパーのバンドルID
set listHelperBundleID to {"com.microsoft.edgemac", "com.microsoft.edgespotlight", "com.microsoft.EdgeUpdater", "com.microsoft.edgemac.framework.AlertNotificationService", "com.microsoft.edgemac.helper", "com.microsoft.edgemac.helper.plugin", "com.microsoft.edgemac.helper.renderer"} as list
############################
###　本処理
############################
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	###終了
	tell application id "com.microsoft.edgemac" to quit
end if
delay 1
############################
###　半ゾンビ化対策
############################
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
delay 1
############################
###　ヘルパーの半ゾンビ化対策
############################
repeat with itemHelperBundleID in listHelperBundleID
	set strHelperBundleID to itemHelperBundleID as text
	#####
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strHelperBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
end repeat
