#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#input:com.apple.Sound-Settings.extension
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor "input" of pane id "com.apple.Sound-Settings.extension"
end tell
tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.Sound-Settings.extension?input"
end tell
