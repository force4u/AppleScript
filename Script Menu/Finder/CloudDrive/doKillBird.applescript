#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
try
	set strCommandText to ("/usr/bin/killall bird") as text
	do shell script strCommandText
on error
	return "コマンドがエラーで終了しました"
end try

return
