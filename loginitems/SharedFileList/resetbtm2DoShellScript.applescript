#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　要管理者権限
# 	dumpbtmで設定されている内容を　resetbtm　リセットします
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##### 
set strCommandText to "/usr/bin/sudo /usr/bin/sfltool resetbtm"
set strResponse to (do shell script strCommandText with administrator privileges) as text
###エラー発生時の検証が不要な場合は以下削除

tell application "TextEdit"
	activate
	properties
	make new document with properties {name:"dumpbtm", text:strResponse}
end tell
