#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
(*  MDM
https://developer.apple.com/documentation/devicemanagement/dock?language=objc
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

################################
####設定項目
################################

###Plist=設定ファイルのバックアップファイルを作る？
###True＝作る false =作らない
set boolMakeBackup to false as boolean

################################
####設定ファイル
################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidPlistPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.apple.dock.plist")
################################
####バックアップ
################################
if boolMakeBackup is true then
	set strDateno to (doGetDateNo("yyyyMMdd-hhmmss")) as text
	set strBackupPath to ("Preferences/com.apple.dock.plist.backup." & strDateno) as text
	set ocidBackupPlistPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:(strBackupPath)
	set listDone to appFileManager's copyItemAtURL:(ocidPlistPathURL) toURL:(ocidBackupPlistPathURL) |error|:(reference)
end if
################################
####設定の内容　確認　変更
################################
set listReadPlistData to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData

set ocidBoolValue to (refMe's NSNumber's numberWithBool:(false))
ocidPlistDict's setValue:(ocidBoolValue) forKey:("autohide")
ocidPlistDict's setValue:(ocidBoolValue) forKey:("launchanim")
set ocidBoolValue to (refMe's NSNumber's numberWithBool:(true))
ocidPlistDict's setValue:(ocidBoolValue) forKey:("mouse-over-hilite-stack")
ocidPlistDict's setValue:(ocidBoolValue) forKey:("expose-group-apps")
ocidPlistDict's setValue:(ocidBoolValue) forKey:("show-process-indicators")
ocidPlistDict's setValue:(ocidBoolValue) forKey:("minimize-to-application")

### Possible Values: bottom, left, right
set ocidStringValue to refMe's NSString's stringWithString:("right")
ocidPlistDict's setValue:(ocidStringValue) forKey:("orientation")
### Possible Values: genie, scale
set ocidStringValue to refMe's NSString's stringWithString:("scale")
ocidPlistDict's setValue:(ocidStringValue) forKey:("mineffect")

###
set ocidLocation to refMe's NSLocale's currentLocale()
set ocidLocalID to ocidLocation's localeIdentifier()
set ocidContryCode to ocidLocation's objectForKey:(refMe's NSLocaleCountryCode)

#set ocidStringValue to refMe's NSString's stringWithString:("ja_JP:(null)")
set ocidStringValue to refMe's NSString's stringWithString:(ocidLocalID)
ocidPlistDict's setValue:(ocidStringValue) forKey:("loc")
set ocidStringValue to refMe's NSString's stringWithString:(ocidContryCode)
ocidPlistDict's setValue:(ocidStringValue) forKey:("region")

##Minimum Value: 16 Maximum Value: 128
set ocidIntValue to refMe's NSNumber's numberWithInteger:(52)
ocidPlistDict's setValue:(ocidIntValue) forKey:("tilesize")
set ocidIntValue to refMe's NSNumber's numberWithInteger:(128)
ocidPlistDict's setValue:(ocidIntValue) forKey:("largesize")
###
(*
0 = No Action 未設定
1 = No Action　何もしない
2 = Mission Control　ミッションコントロール
3 = Application Windows　
4 = Desktop　デスクトップ
5 = Start Screen Saver　スクリーンセイバー
6 = Disable Screen Saver　スクリーンセイバー不要
7 = Dashboard 旧：ダッシュボード
10 = Put Display to Sleep スリープ
11 = Launchpad ランチパッド
12 = Notification Center　通知センター
13 = Lock Screen　スクリーンロック
14 = Quick Note クイックメモ
*)
set ocidIntValue to refMe's NSNumber's numberWithInteger:(1)
ocidPlistDict's setValue:(ocidIntValue) forKey:("wvous-tr-corner")
set ocidIntValue to refMe's NSNumber's numberWithInteger:(1)
ocidPlistDict's setValue:(ocidIntValue) forKey:("wvous-tl-corner")
set ocidIntValue to refMe's NSNumber's numberWithInteger:(1)
ocidPlistDict's setValue:(ocidIntValue) forKey:("wvous-br-corner")
set ocidIntValue to refMe's NSNumber's numberWithInteger:(14)
ocidPlistDict's setValue:(ocidIntValue) forKey:("wvous-bl-corner")


########################
###保存
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
set listDoneSerialization to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidSavePlistData to (item 1 of listDoneSerialization)
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSavePlistData's writeToURL:(ocidPlistPathURL) options:(ocidOption) |error|:(reference)

################################
####Dock再起動
################################
set strBundleID to "com.apple.dock" as text
##起動中のアプリを取得して
set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
####1以上ならアプリがあるって事なので
if (count of ocidAppListArray) ≠ 0 then
	repeat with itemAppListArray in ocidAppListArray
		set booleDone to itemAppListArray's terminate()
	end repeat
end if
repeat 10 times
	####３秒まって
	delay 1
	set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	###アプリケーションが無いなら
	if (count of ocidAppListArray) = 0 then
		###起動
		set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
		tell current application
			set strName to name as text
		end tell
		set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
		(ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true))
		if strName is "osascript" then
			set boolDone to (run script (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
		else
			set boolDone to (activate (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
		end if
		log "手動で起動"
	else
		###起動が確認できたら処理終了
		exit repeat
	end if
end repeat

################################
####ランチパッド起動
################################
set strBundleID to ("com.apple.launchpad.launcher") as text
##起動中のアプリを取得して
set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
##数えて
set numCntAppList to (count of ocidAppList) as integer
if numCntAppList = 0 then
	set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
	set aliasAppPath to (ocidAppPathURL's absoluteURL()) as alias
	tell application "Finder"
		open aliasAppPath
	end tell
end if



################################
####バックアップ用の日付
################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
###################################
### バンドルIDからアプリケーションURL
###################################
to doGetBundleID2AppURL(argBundleID)
	set strBundleID to argBundleID as text
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのURLを取得
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
				set strAppPath to (POSIX path of aliasAppApth) as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetBundleID2AppURL
