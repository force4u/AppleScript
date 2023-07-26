#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to ("com.microsoft.edgemac") as text

tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID does not contain strBundleID then
	###起動
	tell application id "com.microsoft.edgemac" to launch
end if
