#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#バンドルIDのリスト順にドックに登録します
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
##対象のバンドルID
##自分用
#	set listBundleID to {"com.apple.clock", "com.apple.launchpad.launcher", "com.apple.exposelauncher", "com.apple.systempreferences", "com.apple.calculator", "com.apple.MobileSMS", "com.apple.iCal", "com.apple.AddressBook", "com.apple.Stickies", "com.apple.Notes", "com.apple.Safari", "com.apple.TextEdit", "com.apple.ScriptEditor2", "com.apple.FontBook", "com.apple.Preview", "com.apple.ActivityMonitor", "com.apple.Console", "com.apple.Terminal", "com.apple.DiskUtility", "com.apple.QuickTimePlayerX", "com.apple.archiveutility", "com.linearity.vn", "com.adobe.bridge13", "com.adobe.Reader", "com.microsoft.edgemac", "com.microsoft.teams", "com.blackmagic-design.DaVinciResolve", "cx.c3.theunarchiver", "com.google.Chrome", "org.mozilla.firefox", "jp.co.artman21.JeditOmega", "com.microsoft.VSCode", "com.coteditor.CotEditor", "com.skitch.skitch", "com.ridiculousfish.HexFiend", "com.johnhaney.mac.Backdrop"} as list
##MacOSデフォルトのみ
set listBundleID to {"com.apple.clock", "com.apple.launchpad.launcher", "com.apple.exposelauncher", "com.apple.systempreferences", "com.apple.calculator", "com.apple.MobileSMS", "com.apple.iCal", "com.apple.AddressBook", "com.apple.Stickies", "com.apple.Notes", "com.apple.Safari", "com.apple.TextEdit", "com.apple.ScriptEditor2", "com.apple.FontBook", "com.apple.Preview", "com.apple.ActivityMonitor", "com.apple.Console", "com.apple.Terminal", "com.apple.DiskUtility", "com.apple.QuickTimePlayerX", "com.apple.archiveutility"} as list


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
####設定
################################
set listReadPlistData to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
########################
###persistent-apps用のArrayを作成
set ocidPersistentAppsArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###順番に新規にDockの項目を作っていく
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	log strBundleID
	set ocidTileAppDict to doGetPersistentAppsDict(strBundleID)
	(ocidPersistentAppsArrayM's addObject:(ocidTileAppDict))
end repeat

##新しいArrayが出来上がったら
###persistent-apps を丸ごと削除
ocidPlistDict's removeObjectForKey:("persistent-apps")
###新しいArrayをセット
ocidPlistDict's setObject:(ocidPersistentAppsArrayM) forKey:("persistent-apps")


########################
###保存
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
set listDoneSerialization to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidSavePlistData to (item 1 of listDoneSerialization)
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSavePlistData's writeToURL:(ocidPlistPathURL) options:(ocidOption) |error|:(reference)

########################
### Dock再起動
set strBundleID to "com.apple.dock" as text
log doRestartApp2BundleID(strBundleID)

########################
### ランチパッド起動
## set strBundleID to ("com.apple.launchpad.launcher") as text
## log doLaunchApp2BundleID(strBundleID)

return "処理終了"
################################
#### RestartApp
################################
set strBundleID to "com.apple.dock" as text
to doRestartApp2BundleID(argBundleID)
	set strBundleID to argBundleID as text
	##起動中のアプリを取得して
	set ocidRunApp to refMe's NSRunningApplication
	set ocidAppListArray to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
	####1以上ならアプリがあるって事なので
	if (count of ocidAppListArray) ≠ 0 then
		##終了させる
		repeat with itemAppListArray in ocidAppListArray
			set booleDone to itemAppListArray's terminate()
		end repeat
	end if
	####起動チェック最大１０秒
	repeat 10 times
		delay 1
		set ocidRunApp to refMe's NSRunningApplication
		set ocidAppListArray to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
		###アプリケーションが無いなら
		if (count of ocidAppListArray) = 0 then
			###起動
			set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
			set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
			set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
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
#### LaunchApp
################################
to doLaunchApp2BundleID(argBundleID)
	set strBundleID to argBundleID as text
	##起動中のアプリを取得して
	set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	##数えて
	set numCntAppList to (count of ocidAppList) as integer
	if numCntAppList = 0 then
		##無ければ 起動
		tell application id strBundleID to launch
	else
		##あるならアクティブ
		tell application id strBundleID to activate
	end if
end doLaunchApp2BundleID

################################
####バンドルID から　persistent-appsDICT
################################
to doGetPersistentAppsDict(argBundleID)
	set strBundleID to argBundleID as text
	set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
	################################
	###file-data
	set ocidFileDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	##_CFURLStringType
	set ocidIntValue to refMe's NSNumber's numberWithInteger:(15)
	ocidFileDataDict's setValue:(ocidIntValue) forKey:("_CFURLStringType")
	##_CFURLString
	set ocidStrAppPathURL to ocidAppPathURL's absoluteString()
	ocidFileDataDict's setValue:(ocidStrAppPathURL) forKey:("_CFURLString")
	################################
	###tile-data
	set ocidTileDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidTileDataDict's setObject:(ocidFileDataDict) forKey:("file-data")
	## data BOOKMARK=エリアスデータ
	set ocidBookMarkData to doMakeBookmarkData2URL(ocidAppPathURL)
	ocidTileDataDict's setObject:(ocidBookMarkData) forKey:("book")
	## BOOL
	set ocidBoolValue to (refMe's NSNumber's numberWithBool:(false))
	ocidTileDataDict's setValue:(ocidBoolValue) forKey:("dock-extra")
	ocidTileDataDict's setValue:(ocidBoolValue) forKey:("is-beta")
	## INT
	set listDockAppID to {"com.apple.exposelauncher", "com.apple.launchpad.launcher", "com.apple.dock"} as list
	if strBundleID contains listDockAppID then
		set ocidIntValue to refMe's NSNumber's numberWithInteger:(169)
	else
		set ocidIntValue to refMe's NSNumber's numberWithInteger:(41)
	end if
	ocidTileDataDict's setValue:(ocidIntValue) forKey:("file-type")
	## STRINFS
	##バンドルIDからアプリケーションのURLを取得
	set ocidStringValue to doGetBundleID2AppName(strBundleID)
	ocidTileDataDict's setValue:(ocidStringValue) forKey:("file-label")
	#
	set ocidStringValue to refMe's NSString's stringWithString:(strBundleID)
	ocidTileDataDict's setValue:(ocidStringValue) forKey:("bundle-identifier")
	################################
	###ROOT
	set ocidTileAppDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidTileAppDict's setObject:(ocidTileDataDict) forKey:("tile-data")
	set ocidStringValue to refMe's NSString's stringWithString:("file-tile")
	ocidTileAppDict's setValue:(ocidStringValue) forKey:("tile-type")
	###Dictを戻す
	return ocidTileAppDict
end doGetPersistentAppsDict


###################################
### バンドルIDからアプリケーション名
###################################
to doGetBundleID2AppName(argBundleID)
	set strBundleID to argBundleID as text
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
	if ocidAppBundle = (missing value) then
		##bundleWithIdentifierが取れない場合はbundleWithURLを使う
		set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
		##アプリケーションのURLを取得して
		set ocidAppBundle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
	end if
	set ocidLoalisedDict to ocidAppBundle's localizedInfoDictionary()
	if ocidLoalisedDict = (missing value) then
		set ocidLoalisedDict to ocidAppBundle's infoDictionary()
		set ocidAppName to ocidLoalisedDict's valueForKey:("CFBundleDisplayName")
	else
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
				log "アプリケーションが見つかりませんでした"
				return (missing value)
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetBundleID2AppURL


###################################
### URLからブックマークdata
###################################
to doMakeBookmarkData2URL(argFilePathURL)
	set ocidBookMarkPathURL to argFilePathURL
	## NSURLBookmarkCreationOptions
	set ocidOption1 to (refMe's NSURLBookmarkCreationPreferFileIDResolution) as integer
	set ocidOption2 to (refMe's NSURLBookmarkCreationMinimalBookmark) as integer
	set ocidOption4 to (refMe's NSURLBookmarkCreationSuitableForBookmarkFile) as integer
	set ocidOption8 to (refMe's NSURLBookmarkCreationWithSecurityScope) as integer
	set ocidOption16 to (refMe's NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess) as integer
	set ocidOption256 to (refMe's NSURLBookmarkCreationWithoutImplicitSecurityScope) as integer
	## 戻り値が８ビットなので２５６で割る 
	set ocidOption8bit to (ocidOption1 + ocidOption2 + ocidOption8)
	set numOption to (ocidOption8bit / 256) as integer
	##ブックマークデータ作成
	set ocidBookMarkDataArray to (ocidBookMarkPathURL's bookmarkDataWithOptions:(numOption) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
	set ocidBookMarkData to item 1 of ocidBookMarkDataArray
	return ocidBookMarkData
end doMakeBookmarkData2URL


################################
#### 日付
################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:(strDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
