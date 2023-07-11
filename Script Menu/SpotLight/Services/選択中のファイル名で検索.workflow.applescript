#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#workflow用のapplescriptですこのままでは動作しません
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


on run {listAliasFilePath}
	
	repeat with itemAliasFilePath in listAliasFilePath
		set aliasFilePath to itemAliasFilePath as alias
		tell application "Finder"
			set recordFileInfo to (info for aliasFilePath) as record
			set strFileName to (name of recordFileInfo) as text
		end tell
		set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
		(appSharedWorkspace's showSearchResultsForQueryString:(strFileName))
	end repeat
	
end run
