#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions

property refMe : a reference to current application

####################################
###アプリケーションのバンドルID 設定項目
set strBundleID to "org.filezilla-project.filezilla"

###################################
### 登録するアプリケーションのURL
###################################
set ocidAppFileURL to doGetBundleID2AppURL(strBundleID)
set ocidAppFilePath to ocidAppFileURL's |path| as text
################################
####Plist読み込み
################################
set appFileManager to refMe's NSFileManager's defaultManager()
###URL
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLArray's firstObject()
set ocidPlistPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences/com.apple.dock.plist")
###読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
################################
####インサート位置
################################
set ocidPersistentArray to ocidPlistDict's objectForKey:"persistent-apps"
##最下層
set numCntArray to ocidPersistentArray's |count|() as integer
################################
####persistent-appsデータ生成
################################
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###GUID実際はランダム番号だがNSFileSystemFileNumberを使う
set listPathAttar to appFileManager's attributesOfItemAtPath:(ocidAppFilePath) |error|:(reference)
set ocidAttar to item 1 of listPathAttar
set numGUID to ocidAttar's valueForKey:(refMe's NSFileSystemFileNumber)
set ocidIntValue to (refMe's NSNumber's numberWithInteger:(numGUID))
ocidAddDict's setValue:(numGUID) forKey:("GUID")
###
set ocidStringValue to (refMe's NSString's stringWithString:("file-tile"))
ocidAddDict's setValue:(ocidStringValue) forKey:("tile-type")
################################
set ocidAddTitleDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####dock-extra
set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
ocidAddTitleDataDict's setValue:(ocidBoolValue) forKey:("dock-extra")
####dock-extra
set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
ocidAddTitleDataDict's setValue:(ocidBoolValue) forKey:("is-beta")
####bundle-identifier
set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(ocidAppFileURL))
set ocidBunndleID to ocidAppBunndle's bundleIdentifier
set ocidStringValue to ocidBunndleID's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("bundle-identifier")
####file-label"
set listAttributesDict to ocidAppFileURL's resourceValuesForKeys:({refMe's NSURLLocalizedNameKey}) |error|:(reference)
set ocidAttributesDict to (item 1 of listAttributesDict)
set ocidLocalizedName to (ocidAttributesDict's objectForKey:(refMe's NSURLLocalizedNameKey))
set ocidFileLabel to (ocidLocalizedName's stringByDeletingPathExtension())
set ocidStringValue to ocidFileLabel's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("file-label")
####file-mod-date
set listAttributesDict to ocidAppFileURL's resourceValuesForKeys:({refMe's NSURLContentModificationDateKey}) |error|:(reference)
set ocidAttributesDict to (item 1 of listAttributesDict)
set ocidModificationDate to (ocidAttributesDict's objectForKey:(refMe's NSURLContentModificationDateKey))
set ocidModDate to ocidModificationDate's timeIntervalSince1970
set ocidIntValue to ocidModDate's intValue()
ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("file-mod-date")
####parent-mod-date
set ocidNow to refMe's NSDate's now
set ocidNowNo to ocidNow's timeIntervalSince1970
set ocidIntValue to ocidNowNo's intValue
ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("parent-mod-date")
####book
set listBookMarkData to (ocidAppFileURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidkDataValue to item 1 of listBookMarkData
(ocidAddTitleDataDict's setObject:(ocidkDataValue) forKey:("book"))
####file-type
#	169		Launchpad とMission Control
#	41			それ以外はまぁ４１で間違いなさそう
set ocidIntValue to (refMe's NSNumber's numberWithInteger:41)
(ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("file-type"))
################################
set ocidAddFileDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set coidAbsoluteStringPath to ocidAppFileURL's absoluteString()
(ocidAddFileDataDict's setValue:(coidAbsoluteStringPath) forKey:("_CFURLString"))
####
#		0	/File/Path
#		15 file:// のURL形式
set ocidIntValue to (refMe's NSNumber's numberWithInteger:15)
(ocidAddFileDataDict's setValue:(ocidIntValue) forKey:("_CFURLStringType"))
################################
(ocidAddTitleDataDict's setObject:(ocidAddFileDataDict) forKey:("file-data"))
ocidAddDict's setObject:(ocidAddTitleDataDict) forKey:("tile-data")
################################
####追加データを元のPLISTに戻す
################################
ocidPersistentArray's insertObject:(ocidAddDict) atIndex:(numCntArray)
################################
####保存
################################
set boolDone to ocidPlistDict's writeToURL:(ocidPlistPathURL) atomically:true

################################
###CFPreferencesを再起動
################################
##
delay 1
#####CFPreferencesを再起動させて変更後の値をロードさせる
try
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
end try
delay 1
try
	####プレビューの半ゾンビ化対策	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.dock")
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
on error
	tell application id "com.apple.dock" to quit
	set strCommandText to ("/usr/bin/killall Dock")
	do shell script strCommandText
end try




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


return "終了"

