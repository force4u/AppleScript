#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####
tell application "System Events"
	set listLoginItem to every login item
	set listOutPut to {} as list
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set recordProperties to properties
			set end of listOutPut to recordProperties
		end tell
	end repeat
end tell
log listOutPut
return listOutPut
