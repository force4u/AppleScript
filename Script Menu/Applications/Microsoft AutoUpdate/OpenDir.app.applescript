#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###アプリケーションのバンドルID
set strBundleID to "com.microsoft.autoupdate2"
################################################
###### インストール済みのパージョン
################################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##バンドルからアプリケーションのURLを取得
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
##予備（アプリケーションのURL）
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
end if

set ocidContainerDirPathURL to ocidAppPathURL's URLByDeletingLastPathComponent()

################################################
###### Finder表示
################################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's selectFile:(ocidAppPathURL's |path|()) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|())




