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
##NSURLにして
set ocidContainersDirURL to ocidLibraryURL's URLByAppendingPathComponent:("Containers") isDirectory:true
set ocidOpenRootDirURL to ocidContainersDirURL's URLByAppendingPathComponent:("com.apple.TextEdit") isDirectory:true
set ocidOpenDirURL to ocidOpenRootDirURL's URLByAppendingPathComponent:("Data/Documents") isDirectory:true
##パスにして
set ocidOpenDirPath to ocidOpenDirURL's |path|()
set ocidContainersDirPath to ocidOpenRootDirURL's |path|()
###開く

run script (appSharedWorkspace's selectFile:(ocidOpenDirPath) inFileViewerRootedAtPath:(ocidContainersDirPath))
return
try
	set aliasOpenDirURL to (ocidOpenDirURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasOpenDirURL
	end tell
on error
	run script (appSharedWorkspace's selectFile:(ocidOpenDirPath) inFileViewerRootedAtPath:(ocidContainersDirPath))
end try
tell application "Finder" to activate
