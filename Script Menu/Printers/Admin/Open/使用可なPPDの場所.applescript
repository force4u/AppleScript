#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set aliasDir to POSIX file "/Library/Printers/PPDs/Contents/Resources" as alias
tell application "Finder"
	activate
	make new Finder window to aliasDir
end tell

