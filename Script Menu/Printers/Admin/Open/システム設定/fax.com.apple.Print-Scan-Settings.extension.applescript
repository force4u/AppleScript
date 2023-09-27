#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#fax:com.apple.Print-Scan-Settings.extension
# ICON:/System/Library//CoreServices/ManagedClient.app/Contents/PlugIns/ConfigurationProfilesUI.bundle/Contents/Resources/SystemPrefApp.icns
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions
tell application id "com.apple.systempreferences" to activate
tell application id "com.apple.systempreferences"
	reveal anchor "fax" of pane id "com.apple.Print-Scan-Settings.extension"
end tell
tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.Print-Scan-Settings.extension?fax"
end tell
