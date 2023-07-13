#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set listView to {"day view", "week view", "month view"} as list


set listResponce to (choose from list listView with title "表示を選ぶ" without multiple selections allowed and empty selection allowed) as list


if (item 1 of listResponce) is false then
	return "キャンセルしました"
end if

set strViewName to (item 1 of listResponce) as text


tell application "Calendar"
	activate
	tell application "System Events"
		keystroke "r" using command down
	end tell
end tell

tell application "Calendar"
	launch
	activate
	if strViewName contains "day" then
		tell front window
			switch view to day view
		end tell
	else if strViewName contains "week" then
		tell front window
			switch view to week view
		end tell
	else if strViewName contains "month" then
		tell front window
			switch view to month view
		end tell
	end if
	
end tell
