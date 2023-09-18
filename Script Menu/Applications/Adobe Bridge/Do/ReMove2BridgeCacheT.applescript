#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	旧バージョンのBridgeキャッシュ
#	BridgeCacheとBridgeCacheTを削除します
#	選択したフォルダの最下層まで処理します
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
##############################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strMes to "フォルダを選んでください" as text
	set strPrompt to "旧バージョンのBridgeキャッシュrBridgeCacheとBridgeCacheTを削除しますrフォルダを選択してください" as text
	set aliasTargetDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
#####
set strTargetDirPath to (POSIX path of aliasTargetDirPath) as text
set ocidTargetDirPathStr to refMe's NSString's stringWithString:(strTargetDirPath)
set ocidTargetDirPath to ocidTargetDirPathStr's stringByStandardizingPath()
set ocidTargetDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTargetDirPath) isDirectory:false)
#########################
##EMUモードでファイル収集
set ocidPropertyKeys to {(refMe's NSURLNameKey), (refMe's NSURLPathKey)}
set ocidOption to refMe's NSDirectoryEnumerationSkipsPackageDescendants
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidTargetDirPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) errorHandler:(reference))
set ocidEmuFileURLArray to ocidEmuDict's allObjects()

repeat with itemEmuPathURL in ocidEmuFileURLArray
	set listResult to (itemEmuPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(reference))
	set strFileName to (item 2 of listResult) as text
	log strFileName
	if strFileName contains ".BridgeCache" then
		###ゴミ箱に入れる
		set listResult to (appFileManager's trashItemAtURL:(itemEmuPathURL) resultingItemURL:(missing value) |error|:(reference))
		###ゴミ箱に入る時にエラーになった物は削除
		if (item 1 of listResult) is false then
			set listResult to (appFileManager's removeItemAtURL:(itemEmuPathURL) |error|:(reference))
		end if
	else if strFileName is ".DS_Store" then
		##DS_Storeの削除をしない場合はコメントアウト
		set listResult to (appFileManager's trashItemAtURL:(itemEmuPathURL) resultingItemURL:(missing value) |error|:(reference))
	end if
end repeat

## 通常キャッシュを削除しない場合はここにreturnを
# return
#########################
##
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCachesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidCachesDirURL to ocidURLsArray's firstObject()
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("com.adobe.bridge13")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("com.adobe.bridge14")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2024")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
###
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationSupportDirURL to ocidURLsArray's firstObject()
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/logs")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/CT Font Cache")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))

set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/logs")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2024/CT Font Cache")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
