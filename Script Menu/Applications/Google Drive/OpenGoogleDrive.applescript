#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##########################################
###【１】ドキュメントのパスをNSString
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidPlistFilePathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.google.drivefs.settings.plist")

##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)

##########################################
### 【３】値の取得
set ocidStringValue to (ocidPlistDict's valueForKey:("PerAccountPreferences"))

##########################################
### 【４】DICTに読み込む
###NSDATAに
set ocidStringData to ocidStringValue's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###JSONSerialization
set ocidOption to refMe's NSJSONReadingMutableContainers
set listJSONSerialization to refMe's NSJSONSerialization's JSONObjectWithData:(ocidStringData) options:(ocidOption) |error|:(reference)
set ocidJsonData to item 1 of listJSONSerialization
##########################################
###ダイアログ用のリスト
set listAccount to {} as list
### 【５】複数アカウント
set ocidAccountArray to (ocidJsonData's valueForKeyPath:("per_account_preferences"))
###アカウントの数だけ繰り返し
repeat with itemAccountArray in ocidAccountArray
	###OS12以降は
	set ocidDirPath to (itemAccountArray's valueForKeyPath:("value.mount_point_path"))
	set ocidDirName to ocidDirPath's lastPathComponent()
	set end of listAccount to (ocidDirName as text)
	###OS12以前の場合はこちら
	set end of listAccount to (ocidDirPath as text)
	###リストにフォルダ名＝アカウント名を取得する
	
end repeat
##########################################
### 【６】ダイアログ
try
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	set listResponse to (choose from list listAccount with title "選んでください" with prompt "選んでください" default items (item 1 of listAccount) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strDirName to (item 1 of listResponse) as text

##########################################
### 【７】開く
###
if strDirName contains "/" then
	set strCoreStoragePath to (strDirName) as text
	set ocidGoogleDriveDirPathStr to refMe's NSString's stringWithString:(strCoreStoragePath)
	set ocidGoogleDriveDirPath to ocidGoogleDriveDirPathStr's stringByStandardizingPath()
	set ocidGoogleDriveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidGoogleDriveDirPath) isDirectory:false)
else
	set strCoreStoragePath to ("CloudStorage/" & strDirName) as text
	###NSURLにしておいて
	set ocidGoogleDriveDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:(strCoreStoragePath)
end if
##パスにして
set ocidGoogleDriveDirPath to ocidGoogleDriveDirPathURL's |path|()
###パスの有無を確認
set boolDirExists to appFileManager's fileExistsAtPath:(ocidGoogleDriveDirPath) isDirectory:(true)
if boolDirExists = true then
	###パスがあるなら開く
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	appSharedWorkspace's selectFile:(missing value) inFileViewerRootedAtPath:(ocidGoogleDriveDirPath)
else if boolDirExists = false then
	return "ディレクトリが見つかりません"
end if






