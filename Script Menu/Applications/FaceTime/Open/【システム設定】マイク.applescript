#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#Privacy_Microphone:com.apple.settings.PrivacySecurity.extension
# ICON:/System/Library//CoreServices/ManagedClient.app/Contents/PlugIns/ConfigurationProfilesUI.bundle/Contents/Resources/SystemPrefApp.icns
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor "Privacy_Microphone" of pane id "com.apple.settings.PrivacySecurity.extension"
end tell
tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Microphone"
end tell
