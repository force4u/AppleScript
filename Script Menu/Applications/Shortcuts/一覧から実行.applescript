#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

tell application "Shortcuts Events"
	set listShortCut to every shortcut as list
end tell

set listShortCutName to {} as list

repeat with objShortCut in listShortCut
	tell application "Shortcuts Events"
		tell objShortCut
			set strShortCutName to name as text
			copy strShortCutName to end of listShortCutName
		end tell
	end tell
end repeat

try
	set objResponse to (choose from list listShortCutName with title "選んでください" with prompt "Shortcutsを実行します" default items (item 1 of listShortCutName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	log "キャンセルしました"
	return
end if
set strResponse to (objResponse) as text


tell application "Shortcuts Events"
	tell shortcut strResponse
		run
	end tell
end tell



