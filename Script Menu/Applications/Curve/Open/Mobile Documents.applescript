#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##ライブラリ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()
##Mobile Documents
set ocidMobileDocDirURL to ocidLibraryURL's URLByAppendingPathComponent:("Mobile Documents") isDirectory:true
##TextEdit
set ocidOpenDirURL to ocidMobileDocDirURL's URLByAppendingPathComponent:("iCloud~com~linearity~vn/Documents") isDirectory:true
set ocidOpenDirPath to ocidOpenDirURL's |path|()
set ocidMobileDocDirPath to ocidMobileDocDirURL's |path|()
###開く
activate (appSharedWorkspace's selectFile:(ocidOpenDirPath) inFileViewerRootedAtPath:(ocidMobileDocDirPath))
