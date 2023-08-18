#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

#################################
###システム設定起動
#################################
tell application id "com.apple.systempreferences"
	launch
end tell
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

#################################
###ソフトウェアアップデート
#################################

tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.Software-Update-Settings.extension?action=showAutoUpdates"
end tell
#################################
###ベータ（要設定）
#################################
tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.Software-Update-Settings.extension?client=bau"
end tell
