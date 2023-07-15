#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

tell application "AppleScript Utility"
	if not Script menu enabled then
		set Script menu enabled to true
		set application scripts position to top
		set show Computer scripts to false
	end if
end tell

