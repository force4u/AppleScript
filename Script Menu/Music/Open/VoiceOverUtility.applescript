#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to ("com.apple.VoiceOverUtility") as text
tell application id strBundleID to launch
tell application id strBundleID to activate


return
###パスを開く方法もある
tell application "Finder" to get application file id "com.apple.VoiceOverUtility"
tell application "Finder"
	open application file id "com.apple.VoiceOverUtility"
end tell


