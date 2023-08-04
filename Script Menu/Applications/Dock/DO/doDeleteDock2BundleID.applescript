#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#対象のバンドルIDがDockにあれば削除する
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
##削除するバンドルID
set strBundleID to ("us.zoom.xos") as text

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
####
################################
##PLISTをレコードで読み込み
set listReadPlistData to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
########################
###persistent-apps取出し
set ocidPersistentAppsArray to ocidPlistDict's objectForKey:("persistent-apps")
set numCntArray to (count of ocidPersistentAppsArray) as integer
log "現在の登録数：" & numCntArray
###Arrayの数だけ繰り返し
set numCntIndexArray to 0 as integer
set numTileIndex to (missing value)
repeat with itemAppsArray in ocidPersistentAppsArray
	set ocidTileDataDict to (itemAppsArray's objectForKey:("tile-data"))
	set ocidTileBundleID to (ocidTileDataDict's valueForKey:("bundle-identifier"))
	##対象のバンドルIDが登録されていたら
	if (ocidTileBundleID as text) is strBundleID then
		##ポジション位置＝ArrayのIndexを記憶
		set numTileIndex to numCntIndexArray as integer
	end if
	set numCntIndexArray to numCntIndexArray + 1 as integer
end repeat
##ポジション位置に値があるなら
if numTileIndex ≠ (missing value) then
	log "対象のアプリのポジション：" & numTileIndex
	##対象のポジションINDEXのオブジェクトを削除
	ocidPersistentAppsArray's removeObjectAtIndex:(numTileIndex)
else
	return "Dockの中に" & strBundleID & "が見つかりませんでした"
end if
delay 1

########################
###保存
##バイナリーモードで
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
##シリアライゼーションして
set listDoneSerialization to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidSavePlistData to (item 1 of listDoneSerialization)
##保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSavePlistData's writeToURL:(ocidPlistPathURL) options:(ocidOption) |error|:(reference)

########################
### Dock再起動
set strBundleID to "com.apple.dock" as text
log doRestartApp2BundleID(strBundleID)

return "処理終了"

################################
##	RestartApp 
##	対象のアプリケーションを終了させる
################################
to doRestartApp2BundleID(argBundleID)
	set strBundleID to argBundleID as text
	##起動中のアプリを取得して
	set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	####1以上ならアプリがあるって事なので
	if (count of ocidAppListArray) ≠ 0 then
		repeat with itemAppListArray in ocidAppListArray
			set booleDone to itemAppListArray's terminate()
		end repeat
	end if
	####起動チェック最大１０秒
	repeat 10 times
		delay 1
		set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
		###アプリケーションが無いなら
		if (count of ocidAppListArray) = 0 then
			### バンドルIDからアプリケーションのURLを取得
			set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
			###前面アプリ
			set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
			set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
			(ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true))
			try
				set boolDone to (activate (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
			on error
				tell application id strBundleID to launch
			end try
			return "手動で起動"
		else
			exit repeat
		end if
	end repeat
	return "起動"
end doRestartApp2BundleID


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
### バンドルIDからアプリケーション名
###################################
to doGetBundleID2AppName(argBundleID)
	set strBundleID to argBundleID as text
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
	if ocidAppBundle = (missing value) then
		set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
		set ocidAppBundle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
		set ocidLoalisedDict to ocidAppBundle's localizedInfoDictionary()
		set ocidAppName to ocidLoalisedDict's valueForKey:("CFBundleDisplayName")
	else
		set ocidLoalisedDict to ocidAppBundle's localizedInfoDictionary()
		set ocidAppName to ocidLoalisedDict's valueForKey:("CFBundleDisplayName")
	end if
	return ocidAppName
end doGetBundleID2AppName

###################################
### バンドルIDからアプリケーションURL
###################################
to doGetBundleID2AppURL(argBundleID)
	set strBundleID to argBundleID as text
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのURLを取得
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
