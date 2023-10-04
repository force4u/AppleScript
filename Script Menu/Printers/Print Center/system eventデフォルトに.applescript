#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to ("com.apple.printcenter") as text

tell application "Print Center"
	tell application "System Events"
		tell process "Print Center"
			###選択中のプリンタをデフォルトに
			click menu item 2 of menu 1 of menu bar item "プリンタ" of menu bar 1
		end tell
	end tell
	
end tell


