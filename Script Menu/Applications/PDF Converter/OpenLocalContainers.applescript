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
set strBundleID to ("com.pdfgear.pdfconverter") as text

set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##ライブラリ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()
##Mobile Documents
set ocidMobileDocDirURL to ocidLibraryURL's URLByAppendingPathComponent:("Containers") isDirectory:true
##
set ocidRootedAtDirURL to ocidMobileDocDirURL's URLByAppendingPathComponent:("com.pdfgear.pdfconverter/Data/Documents") isDirectory:true
set ocidOpenDirURL to ocidMobileDocDirURL's URLByAppendingPathComponent:("com.pdfgear.pdfconverter/Data/Documents/PDF") isDirectory:true

set ocidOpenDirPath to ocidOpenDirURL's |path|()
set ocidMobileDocDirPath to ocidMobileDocDirURL's |path|()
set aliasDirPath to (ocidOpenDirURL's absoluteURL()) as alias

###開く
set boolDone to (run script (appSharedWorkspace's selectFile:(ocidOpenDirPath) inFileViewerRootedAtPath:(ocidRootedAtDirURL)))
log boolDone
if boolDone = false then
	set aliasDirPath to (ocidOpenDirURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasDirPath
	end tell
end if

