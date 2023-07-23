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


set strCommandText to "/usr/bin/nettop -x -n" as text

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
		set size to {720, 270}
		set position to {360, 25}
		set origin to {360, 500}
		set frame to {360, 500, 1080, 875}
		set bounds to {360, 25, 1080, 295}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell



set strCommandText to "/usr/bin/nettop -m tcp" as text

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
		set size to {720, 300}
		set position to {360, 300}
		set origin to {360, 300}
		set frame to {360, 300, 1080, 600}
		set bounds to {360, 300, 1080, 600}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
set strCommandText to "/usr/bin/nettop -t wifi" as text

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
		set size to {720, 300}
		set position to {360, 600}
		set origin to {360, 0}
		set frame to {360, 0, 1080, 300}
		set bounds to {360, 600, 1080, 900}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell


set strCommandText to "/usr/bin/man -a nettop"

tell application "Terminal"
	set objTabWindows to do script "\n\n"
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	tell window id numWidowID
		activate
		set size to {360, 870}
		set position to {0, 25}
		set origin to {0, 0}
		set frame to {0, 0, 360, 875}
		set bounds to {0, 25, 360, 900}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
return
