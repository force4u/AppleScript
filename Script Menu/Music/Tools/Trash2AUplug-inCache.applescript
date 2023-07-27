#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
オーディオプラグインのキャッシュを削除してリセット
*)
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


###################################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
###################################
set strAlertMes to "AU plug-inのキャッシュを削除してリセットします\r\rキャンセルで中止" as text
try
	set recordResponse to (display alert ("【選んでください】\r" & strAlertMes) buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10) as record
on error
	log "エラーしました"
	return "キャンセルしました。処理を中止します。インストールが必要な場合は再度実行してください"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れです。処理を中止します。インストールが必要な場合は再度実行してください"
end if
set strBottonName to (button returned of recordResponse) as text
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPath to ocidUserLibraryPathArray's firstObject()
#######
set ocidGoToTrashURL to ocidUserLibraryPath's URLByAppendingPathComponent:("Caches/com.apple.audiounits.cache") isDirectory:true
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean
#######
set ocidGoToTrashURL to ocidUserLibraryPath's URLByAppendingPathComponent:("Preferences/com.apple.audio.InfoHelper.plist") isDirectory:false
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean
#######
set ocidGoToTrashURL to ocidUserLibraryPath's URLByAppendingPathComponent:("Caches/AudioUnitCache") isDirectory:true
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean
###################################
set ocidTemporaryDirPathURL to appFileManager's temporaryDirectory
#######
set ocidGoToTrashURL to ocidTemporaryDirPathURL's URLByAppendingPathComponent:("AudioComponentRegistrar") isDirectory:true
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean
###################################
set ocidTemporaryDirPathURL to appFileManager's temporaryDirectory
set ocidContainerDirURL to ocidTemporaryDirPathURL's URLByDeletingLastPathComponent()
set ocidCachesDirPathURL to ocidContainerDirURL's URLByAppendingPathComponent:("C") isDirectory:true
#######
set ocidGoToTrashURL to ocidCachesDirPathURL's URLByAppendingPathComponent:("AudioComponentRegistrar") isDirectory:true
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean
#######これは自分用
set ocidGoToTrashURL to ocidCachesDirPathURL's URLByAppendingPathComponent:("com.blackmagic-design.DaVinciResolve") isDirectory:true
set boolDone to appFileManager's trashItemAtURL:(ocidGoToTrashURL) resultingItemURL:(ocidGoToTrashURL) |error|:(reference)
log item 1 of boolDone as boolean

###################################
set strCommandText to "/usr/bin/killall -m cfprefsd" as text
try
	do shell script strCommandText
end try
