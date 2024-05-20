#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
FinderWindowの位置を保存する
設定ファイルの場所を開くだけの単機能
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
#################################
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidCoreServiceDirPathURL to ocidURLsArray's firstObject()
set ocidSelectedFilePathURL to ocidCoreServiceDirPathURL's URLByAppendingPathComponent:("SystemUIServer.app")
###パスにして
set ocidCoreServiceDirPath to ocidCoreServiceDirPathURL's |path|()
set ocidSelectedFilePath to ocidSelectedFilePathURL's |path|()
##開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSelectedFilePath) inFileViewerRootedAtPath:(ocidCoreServiceDirPath)
###結果 NGだったらFinderでも試す
if boolDone is false then
	set aliasDirPath to (ocidCoreServiceDirPathURL's absoluteURL()) as alias
	set aliasSelectedFilePath to (ocidSelectedFilePathURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasDirPath
	end tell
	tell application "Finder"
		reveal aliasSelectedFilePath
	end tell
	return "エラーしました"
end if



