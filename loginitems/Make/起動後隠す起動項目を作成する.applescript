#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
##############################################
##設定項目
##############################################
##ディレクトリ名
set strDirName to ("Loginitems") as text
###オールドユーザーはこちらかな？
#	set strDirName to ("StartupItems") as text
###起動項目のバンドルID
set strBundleID to ("com.apple.FontBook") as text
set strAppFileName to (strBundleID & ".app") as text
###起動項目APPに隠すを入れるか？
set boolSetHide to true as boolean

#####################################
#####スクリプトメニューから実行させない
#####################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		set aliasPathToMe to path to me as alias
		tell application "Script Editor"
			open aliasPathToMe
		end tell
		return "中止しました"
	end tell
else
	tell current application
		activate
	end tell
end if
#####################################
##アプリケーション（起動項目用）を作成する
#####################################

###スクリプトパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
###Loginitems
set ocidLoginitemsDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Loginitems")
###フォルダを作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidLoginitemsDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存先
set ocidLoginitemsAppPathURL to ocidLoginitemsDirPathURL's URLByAppendingPathComponent:(strAppFileName)
set aliasAppFilePath to (ocidLoginitemsAppPathURL's absoluteURL()) as «class furl»



set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#\n(*\nログイン項目登録用\n起動時に起動後『隠す』処理\nファイル＞書き出す…からアプリケーションに書き出し\nログイン項目に登録する\n設定項目のバンドルIDは\nhttps://github.com/force4u/AppleScript/blob/main/Script%20Menu/Developer/Get/getAppBundleID.applescript\nを使って取得できます\n*)\n#com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse scripting additions\n###設定項目\nset strBundleID to (\"" & strBundleID & "\") as text\n###起動\ntell application id strBundleID\nlaunch\nend tell\ndelay 3\n###起動待ち　最大６０回\nrepeat 60 times\ntell application id strBundleID\nactivate\nset boolFrontMost to frontmost as boolean\nend tell\nif boolFrontMost is true then\nexit repeat\nelse\ndelay 0.25\nend if\nend repeat\n###名前の取得\ntell application id strBundleID\nset strAppName to name as text\nend tell\n###隠す処理\ntell application \"System Events\"\ntell application process strAppName\nset visible to false\nend tell\nend tell") as text


tell application "Script Editor"
	
	make new document with properties {contents:strScript}
	tell front document
		activate
		compile
	end tell
	save front document as "application" in aliasAppFilePath without run only, startup screen and stay open
	close front document saving no
end tell



#####################################
##アプリケーション（起動項目用）を作成する
#####################################

###バンドル
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidLoginitemsAppPathURL)
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
set strAppPath to (ocidLoginitemsAppPathURL's |path|()) as text
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
