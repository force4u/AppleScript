#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.MakePDF") as text

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidSupportDirPathURL to ocidURLsArray's firstObject()
set ocidOppenDirPathURL to ocidSupportDirPathURL's URLByAppendingPathComponent:("Apple/MakePDF")


set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's openURL:(ocidOppenDirPathURL)
