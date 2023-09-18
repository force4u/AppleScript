#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationSupportDirURL to ocidURLsArray's firstObject()
set ocidCameraRawDirPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/XMP/Metadata Templates")

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidCameraRawDirPathURL's |path|()) inFileViewerRootedAtPath:(ocidApplicationSupportDirURL's |path|())
###結果
log boolDone
if boolDone is false then
	set aliasCameraRawDirPathURL to (ocidCameraRawDirPathURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasCameraRawDirPathURL
	end tell
	return "エラーしました"
end if



