#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidLibraryPathURL to ocidURLsArray's firstObject()
set ocidFilePathURL to ocidLibraryPathURL's URLByAppendingPathComponent:("ScriptingAdditions/Digital Hub Scripting.osax")

set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias

tell application "Script Editor"
	activate
	open aliasFilePath
end tell
