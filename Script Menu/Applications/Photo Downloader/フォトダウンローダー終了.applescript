#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set strBundleID to ("com.adobe.photodownloader") as text

tell application id strBundleID
	quit
end tell
delay 2
tell application id strBundleID to quit
