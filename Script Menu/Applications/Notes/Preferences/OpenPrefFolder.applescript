#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#		com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidNoteDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Containers/com.apple.Notes/")
set ocidPrefDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Containers/com.apple.Notes/Data/Library/Preferences")
set ocidNoteDirPath to ocidNoteDirPathURL's |path|()
set ocidPrefDirPath to ocidPrefDirPathURL's |path|()

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidPrefDirPath) inFileViewerRootedAtPath:(ocidNoteDirPath)

