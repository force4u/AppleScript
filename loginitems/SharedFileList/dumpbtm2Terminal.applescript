#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	　要管理者権限
#	dumpbtm の内容をターミナルで実行します
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##### 
set strCommandText to "/usr/bin/sudo /usr/bin/sfltool dumpbtm"

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
		set size to {520, 840}
		set position to {0, 25}
		set origin to {520, 840}
		set frame to {0, 25, 520, 840}
		set bounds to {0, 25, 520, 840}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
#
log ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
return ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"

