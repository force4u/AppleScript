#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##### airport -s
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s"
tell application "Terminal"
	launch
	activate
	set objTabWindows to do script "\n\n"
	tell objTabWindows
		activate
	end tell
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	
	tell window id numWidowID
		set size to {980, 320}
		set position to {0, 25}
		set origin to {360, 515}
		set frame to {0, 560, 980, 875}
		set bounds to {0, 25, 980, 320}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
##### airport -I
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I"
tell application "Terminal"
	launch
	activate
	set objTabWindows to do script "\n\n"
	tell objTabWindows
		activate
	end tell
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	
	tell window id numWidowID
		set size to {697, 305}
		set position to {0, 321}
		set origin to {0, 80}
		set frame to {0, 80, 580, 580}
		set bounds to {0, 321, 580, 820}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell

