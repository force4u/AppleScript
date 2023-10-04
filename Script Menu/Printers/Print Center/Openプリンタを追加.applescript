#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# プリンタ追加ユーティリティを開くのみ
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set strBundleID to ("com.apple.print.add") as text

tell application id strBundleID to launch
tell application id strBundleID to activate

return "処理終了"

repeat 5 times
	tell application id strBundleID to activate
	tell application id strBundleID
		### com.apple.print.addはフロントモストにならない
		set boolFrontMost to frontmost as boolean
	end tell
	if boolFrontMost = false then
		log "起動確認中"
		delay 0.5
	else
		log "起動確認OK"
		exit repeat
	end if
end repeat



tell application id strBundleID
	launch
	activate
end tell

tell application "Finder"
	set aliasAppApth to (application file id strBundleID) as alias
	
end tell
set strAppPath to (POSIX path of aliasAppApth) as text


