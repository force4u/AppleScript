#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##############################
#####スクリプトメニューから実行させない
##############################
tell current application
	set strName to name as text
end tell

####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Script Editor" to launch
	tell application "Finder"
		activate
		set aliasPathToMe to path to me as alias
	end tell
	tell application "Script Editor" to activate
	tell application "Script Editor"
		open aliasPathToMe
	end tell
	return
else if strName is "Script Menu" then
	tell application "Script Editor" to launch
	tell application "Finder"
		set aliasPathToMe to path to me as alias
	end tell
	tell application "Script Editor" to activate
	tell application "Script Editor"
		open aliasPathToMe
	end tell
	return
else
	tell current application
		activate
	end tell
end if



set strURL to ""
set listURL to {} as list
repeat 50 times
	tell application id "com.microsoft.edgemac"
		tell front window
			tell active tab
				set strGetURL to URL as text
			end tell
		end tell
	end tell
	if strGetURL ≠ strURL then
		set strURL to strGetURL as text
		set end of listURL to strGetURL
		log listURL
		log strURL
	end if
	
	delay 0.1
end repeat

log listURL
log strURL
return listURL
