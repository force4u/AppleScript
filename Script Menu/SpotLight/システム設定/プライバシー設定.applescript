#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor  "privacy" of pane id  "com.apple.Siri-Settings.extension"
end tell
