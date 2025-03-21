#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###################################
#####パス
###################################
set ocidHomeDirUrl to appFileManager's homeDirectoryForCurrentUser()
set ocidFilePathURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/CloudStorage/Dropbox"
set aliasFilePathURL to ocidFilePathURL as alias
###################################
#####開く
###################################
set boolResults to appShardWorkspace's openURL:ocidFilePathURL
if boolResults is false then
	tell application "Finder"
		make new Finder window to aliasFilePathURL
	end tell
end if