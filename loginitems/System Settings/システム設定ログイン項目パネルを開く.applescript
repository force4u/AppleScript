#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###起動
tell application id "com.apple.systempreferences"
	launch
end tell

##############################
#####ダイアログを前面に出す
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if


###起動待ち
tell application id "com.apple.systempreferences"
	###起動確認　最大１０秒
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell

set strPaneId to "com.apple.LoginItems-Settings.extension" as text
set strAnchorName to "startupItemsPref" as text

###アンカーで開く
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell
###アンカーで開くの待ち　最大１０秒
repeat 10 times
	tell application id "com.apple.systempreferences"
		tell pane id strPaneId
			set listAnchorName to name of anchors
		end tell
		if listAnchorName is missing value then
			delay 1
		else if listAnchorName is {strAnchorName} then
			exit repeat
		end if
	end tell
end repeat

return

tell application "Finder"
	
	set theCmdCom to ("open \"x-apple.systempreferences:" & strPaneId & "?" & strAnchorName & "\"") as text
	do shell script theCmdCom
end tell



