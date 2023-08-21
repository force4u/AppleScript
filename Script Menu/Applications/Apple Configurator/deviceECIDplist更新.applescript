#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# "実行後しばらく時間がかかります３０秒"
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set strBundleID to "com.apple.configurator.ui" as text

set strFilePath to ("/Applications/Apple Configurator.app/Contents/MacOS/cfgutil") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
##ファイルの有無
set appFileManager to refMe's NSFileManager's defaultManager()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidFilePath) isDirectory:(false)

if boolDirExists = true then
	log boolDirExists & "インストール済みなので処理へ進む"
else if boolDirExists = false then
	log boolDirExists & "未インストールなのでインストール画面へ"
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
	
	set strAlertMes to "Apple Configurator.appを\rインストールしてください" as text
	set recordResponse to (display alert ("【インストールが必要です】\r" & strAlertMes) buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10) as record
	set strBottonName to (button returned of recordResponse) as text
	if "OK" is equal to (strBottonName) then
		set strURL to ("https://apps.apple.com//jp/app/apple-store/id1037126344?mt=12&ls=0") as text
		tell application "Finder"
			open location strURL
		end tell
	else
		return "キャンセルしました。処理を中止します。インストールが必要な場合は再度実行してください"
	end if
end if


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirURL to ocidURLsArray's firstObject()
###PLIST保存先　ディレクトリ
set strDirName to ("Apple/Apple Configurator/") as text
set ocidSaveDirPathURL to ocidDocumentDirURL's URLByAppendingPathComponent:(strDirName)
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###PLIST保存　ファイル
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("CNFGdeviceECIDs.plist")
###
set strFilePath to (ocidSaveFilePathURL's |path|()) as text


log "実行後しばらく時間がかかります３０秒"

set strCommandText to "'/Applications/Apple Configurator.app/Contents/MacOS/cfgutil' --format plist -f get name ECID installedApps > \"" & strFilePath & "\"" as text
try
	set strResponse to (do shell script strCommandText) as text
on error number 1
	display alert "【エラー】デバイスを有線接続してから実行してください"
	return "デバイス未接続"
end try
delay 2
###AppKit
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:({ocidSaveDirPathURL})
