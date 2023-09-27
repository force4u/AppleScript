#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###起動
tell application id "com.apple.systempreferences" to activate
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

set strPaneId to "com.apple.wifi-settings-extension" as text
set strAnchorName to "Advanced" as text



###アンカーで開く
tell application id "com.apple.systempreferences"
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell