#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application


set strBundleID to ("com.apple.systempreferences") as text

##CALL NEW systempreferences
tell application id strBundleID to quit
delay 1
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
appSharedWorkspace's openURL:(ocidAppPathURL)

tell application id "com.apple.systempreferences"
	activate
	set miniaturized of the settings window to false
end tell
tell application id "com.apple.finder"
	try
		open location "x-apple.systempreferences:com.apple.Profiles-Settings.extension?Main"
	end try
end tell
tell application id "com.apple.systempreferences"
	try
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
	end try
end tell


#choose from list
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listChooser to {"it-IT", "en-US", "ja-JP"} as list
set strTitle to ("choose lang") as text
set strPrompt to ("Please choose\rSi prega di scegliere") as text
try
	set objResponse to (choose from list listChooser with title strTitle with prompt strPrompt default items (item 1 of listChooser) OK button name "OK" cancel button name "cancel" with empty selection allowed without multiple selections allowed)
on error
	log "error"
	return "error"
end try
if (class of objResponse) is boolean then
	return "error A"
else if (class of objResponse) is list then
	if objResponse is {} then
		return "error B"
	else
		set strResponse to (item 1 of objResponse) as text
		set strPlistFileName to ("Lang_" & strResponse & ".mobileconfig") as text
	end if
end if

#path to mobileconfig
set aliasPathToMe to (path to me) as alias
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:(false)
set ocidPathToMeContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
set strSetPath to ("plist/" & strPlistFileName) as text
set ocidPlistFilePathURL to ocidPathToMeContainerDirPathURL's URLByAppendingPathComponent:(strSetPath) isDirectory:(false)
#Open URL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("x-apple.systempreferences")
ocidURLComponents's setPath:("com.apple.Profiles-Settings.extension")
ocidURLComponents's setQuery:("Main")
set ocidPaneFilePathURL to ocidURLComponents's |URL|()
#OPEN Panel
appSharedWorkspace's openURL:(ocidPaneFilePathURL)
#Open mobileconfig
appSharedWorkspace's openURL:(ocidPlistFilePathURL)
#After system event
delay 1
tell application "System Settings"
	tell front window
		set bounds to {0, 25, 720, 620}
	end tell
end tell
tell application "System Events"
	keystroke return
end tell
