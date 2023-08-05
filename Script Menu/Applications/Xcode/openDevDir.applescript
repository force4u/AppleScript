#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###パス関連
set strDirPath to "~/Library/Developer/Xcode" as text
set ocidDirPathStr to refMe's NSString's stringWithString:(strDirPath)
set ocidDIrPath to ocidDirPathStr's stringByStandardizingPath()
set ocidUserDataPath to ocidDIrPath's stringByAppendingPathComponent:("UserData")
##保存先を選択状態で開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's selectFile:(ocidUserDataPath) inFileViewerRootedAtPath:(ocidDIrPath)
###Finderを前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
