#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# このスクリプトを『アプリケーション』登録用
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set boolSetHide to true as boolean

set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appFileManager to refMe's NSFileManager's defaultManager()
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set listUTI to {"com.apple.application-bundle"}
###アプリケーションディレクトリ
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppDirPathURL to ocidUserLibraryPathArray's firstObject()
set aliaAppDirPath to (ocidAppDirPathURL's absoluteURL()) as alias
###
set aliasAppPath to (choose file with prompt "対象のアプリケーションを選んでください" default location (aliaAppDirPath) of type listUTI with invisibles without showing package contents and multiple selections allowed) as alias
###パス
set strAppPath to POSIX path of aliasAppPath
set ocidAppPathStr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()
set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:true)
###バンドル
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
###基本情報を取得
set ocidInfoDict to ocidAppBundle's infoDictionary
set ocidBundleName to ocidInfoDict's valueForKey:("CFBundleName")
set ocidBundleDisplayName to ocidInfoDict's valueForKey:("CFBundleDisplayName")
###ローカライズ名を取得する
set ocidBundleDisplayNameLocalizable to ocidAppBundle's localizedStringForKey:("CFBundleDisplayName") value:("") table:("InfoPlist")
if (ocidBundleDisplayNameLocalizable as text) is "CFBundleDisplayName" then
	set ocidBundleDisplayNameLocalizable to ocidBundleDisplayName
end if
if (ocidBundleDisplayNameLocalizable as text) is "" then
	set ocidBundleDisplayNameLocalizable to ocidBundleName
end if

set strAppName to ocidBundleDisplayNameLocalizable as text
log "strAppPath:" & strAppPath
log "strAppName:" & strAppName

tell application "System Events"
	if boolSetHide is true then
		set recordProperties to {name:strAppName, path:strAppPath, class:login item, kind:"アプリケーション", hidden:true}
	else
		set recordProperties to {name:strAppName, path:strAppPath, class:login item, kind:"アプリケーション", hidden:false}
	end if
end tell

####ログインアイテム 設定開始時
log "設定前："
tell application "System Events"
	set listLoginItem to every login item
	set listOutPut to {} as list
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set recordProperties to properties
			set end of listOutPut to recordProperties
		end tell
	end repeat
end tell

####ログインアイテム 設定
log "設定："


tell application "System Events"
	make login item at end with properties recordProperties
end tell


####ログインアイテム 設定後
log "設定後："
tell application "System Events"
	set listLoginItem to every login item
	set listOutPut to {} as list
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set recordProperties to properties
			set end of listOutPut to recordProperties
		end tell
	end repeat
end tell

###ログイン項目を開く
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor "startupItemsPref" of pane id "com.apple.LoginItems-Settings.extension"
end tell
