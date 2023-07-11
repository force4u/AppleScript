#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# プリンタ追加ユーティリティを開くのみ
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

tell application id "com.apple.print.add"
	launch
end tell
tell application id "com.apple.print.add" to activate

