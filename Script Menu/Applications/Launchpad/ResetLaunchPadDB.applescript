#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# ランチパッドのDBをゴミ箱に入れる事で完全リセット
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString

set objFileManager to refMe's NSFileManager's defaultManager()


################################
####設定項目
################################
###行Rows 
set numCntRows to 5 as integer
###列Columns
set numCntColumns to 7 as integer
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
set strDateno to (doGetDateNo("yyyyMMdd-hhmmss")) as text
set strBackupPath to ("Preferences/com.apple.dock.plist.backup." & strDateno) as text
set ocidBackupPlistPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:(strBackupPath)
if boolMakeBackup is true then
	set listDone to appFileManager's copyItemAtURL:(ocidPlistPathURL) toURL:(ocidBackupPlistPathURL) |error|:(reference)
end if
################################
####設定の内容　確認　変更
################################
##set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set listReadPlistData to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
###行Rows 
log "行Rows変更前：" & (ocidPlistDict's valueForKey:("springboard-rows"))
###列Columns
log "列Columns変更前：" & (ocidPlistDict's valueForKey:("springboard-columns"))
########################
###行Rows 
set ocidIntRows to refMe's NSNumber's numberWithInteger:(numCntRows)
ocidPlistDict's setValue:(ocidIntRows) forKey:("springboard-rows")
###列Columns
set ocidIntColumns to refMe's NSNumber's numberWithInteger:(numCntColumns)
ocidPlistDict's setValue:(ocidIntColumns) forKey:("springboard-columns")
###並び順リセット
set ocidBool to (refMe's NSNumber's numberWithBool:(true))
ocidPlistDict's setValue:(ocidBool) forKey:("ResetLaunchPad")
log "#####変更処理実行"
###行Rows 
log "行Rows変更後：" & (ocidPlistDict's valueForKey:("springboard-rows"))
###列Columns
log "列Columns変更後：" & (ocidPlistDict's valueForKey:("springboard-columns"))
###保存
##set boolDone to ocidPlistDict's writeToURL:(ocidPlistPathURL) atomically:(true)
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
set listDoneSerialization to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidSavePlistData to (item 1 of listDoneSerialization)
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSavePlistData's writeToURL:(ocidPlistPathURL) options:(ocidOption) |error|:(reference)
################################
####LaunchPadDBをゴミ箱に入れる
################################
set ocidTemporaryDirPathURL to objFileManager's temporaryDirectory()
set ocidTemporaryDirPathURL to ocidTemporaryDirPathURL's URLByDeletingLastPathComponent()
set ocidGo2TrashURL to ocidTemporaryDirPathURL's URLByAppendingPathComponent:("0/com.apple.dock.launchpad") isDirectory:(true)
set listDone to (appFileManager's trashItemAtURL:(ocidGo2TrashURL) resultingItemURL:(missing value) |error|:(reference))

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


return
