#!/usr/bin/env osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

set strBundleID to ("com.apple.ColorSyncCalibrator") as text

set ocidRunningApplication to current application's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat
delay 1

tell application id strBundleID to launch
tell application id strBundleID to activate

