#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application




### 【１】XMLのURL
set strFilePath to ("/System/Library/AssetsV2/com_apple_MobileAsset_Font6/com_apple_MobileAsset_Font6.xml") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###【２】ダウンロード先確保
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:("Asset_Font6")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###
set aliasSaveDirPath to (ocidSaveDirPathURL's absoluteURL()) as alias
##実行
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveDirPathURL's |path|()) inFileViewerRootedAtPath:(ocidDownloadsDirPathURL's |path|())
###結果
log boolDone
if boolDone is false then
	set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasCameraRawDirPathURL
	end tell
	return "エラーしました"
end if

###【２】読み込み
set ocidPlistDictM to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
#Assets
set ocidAssetsArray to ocidPlistDictM's objectForKey:("Assets")
log (count of ocidAssetsArray) & "ファイルダウンロードします"

repeat with itemAssets in ocidAssetsArray
	##
	set strBaseURL to (itemAssets's valueForKey:("__BaseURL"))
	set ocidBaseURL to (refMe's NSURL's URLWithString:(strBaseURL))
	set strPath to (itemAssets's valueForKey:("__RelativePath"))
	set ocidURL to (ocidBaseURL's URLByAppendingPathComponent:(strPath))
	log ocidURL's absoluteString() as text
	##
	set ocidFileName to ocidURL's lastPathComponent()
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName))
	##
	set ocidOption to refMe's NSDataReadingMappedIfSafe
	set listDone to (refMe's NSData's dataWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference))
	set ocidData to item 1 of listDone
	##
	set ocidOption to refMe's NSDataWritingAtomic
	set listDone to (ocidData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	##
	
	
end repeat

return

set strBundleID to ("com.apple.archiveutility") as text

tell application "Finder"
	set listAliasFilePath to (every item of contents of aliasSaveDirPath) as list
end tell
repeat with itemAliasFilePath in listAliasFilePath
	tell application "Finder"
		set aliasFilePath to itemAliasFilePath as alias
	end tell
	
	tell application id strBundleID
		open file aliasFilePath
	end tell
end repeat
