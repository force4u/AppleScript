#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###スクリプトモニタ終了
set listUTI to {"com.apple.ScriptMonitor"}
repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat
###スクリプト終了
set strCommandText to ("/bin/ps -alx | grep osascript | grep -v grep| awk '{print $2}'")
set strPID to (do shell script strCommandText) as text
set strCommandText to ("/bin/kill -9 " & strPID & "") as text
try
	do shell script strCommandText
end try
###
#set ocidApp to (ocidRunningApplication's runningApplicationWithProcessIdentifier:(strPID))
#ocidApp's terminate()
