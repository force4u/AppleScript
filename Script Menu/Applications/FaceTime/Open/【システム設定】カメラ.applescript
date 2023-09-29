#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#Privacy_Camera:com.apple.settings.PrivacySecurity.extension
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor "Privacy_Camera" of pane id "com.apple.settings.PrivacySecurity.extension"
end tell
tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Camera"
end tell
