#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

tell application "Finder"
	set listAliasFilePath to (get selection as alias list) as list
end tell
repeat with itemAliasFilePath in listAliasFilePath
	set aliasFilePath to itemAliasFilePath as alias
	tell application "Finder"
		set recordFileInfo to (info for aliasFilePath) as record
		set strFileName to (name of recordFileInfo) as text
	end tell
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	(appSharedWorkspace's showSearchResultsForQueryString:(strFileName))
end repeat
