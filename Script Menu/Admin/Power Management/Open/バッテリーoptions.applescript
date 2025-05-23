#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# バッテリー オプション
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor "options" of pane id "com.apple.Battery-Settings.extension*BatteryPreferences"
end tell

tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.preference.battery?options"
end tell
