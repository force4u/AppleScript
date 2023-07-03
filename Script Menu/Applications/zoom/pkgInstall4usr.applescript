#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#		セルフインストールのサンプル zoom
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##################################
##【１】CPUタイプのよる処理の分岐
set recordSysInfo to system info
set strCpuType to (CPU type of recordSysInfo) as text
if strCpuType contains "Intel" then
	set strPkgURL to "https://zoom.us/client/latest/Zoom.pkg?archType=arm64" as text
	log strCpuType
else if strCpuType contains "ARM" then
	set strPkgURL to "https://zoom.us/client/latest/Zoom.pkg?archType=arm64" as text
	log strCpuType
else
	return "不明なCUP処理終了"
end if

##################################
##【２】ダウンロード　
##起動時に削除する項目
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
##フォルダ名はUUIDを使う
set ocidConcreteUUID to refMe's NSUUID's UUID()
set ocidUUIDString to ocidConcreteUUID's UUIDString()
set ocidTempDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
##フォルダを777アクセス権で作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set boolDone to appFileManager's createDirectoryAtURL:(ocidTempDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
log boolDone
set strTempDirPath to (ocidTempDirPathURL's |path|()) as text
##ファイル名を取得
try
	set strCommandText to ("/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' \"" & strPkgURL & "\" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev") as text
	set strSaveFileName to (do shell script strCommandText) as text
on error
	try
		set strCommandText to ("/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' \"" & strPkgURL & "\"  --http1.1 --connect-timeout 20 | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev") as text
		set strSaveFileName to (do shell script strCommandText) as text
	on error
		set strSaveFileName to "install.pkg"
	end try
end try
##ダウンロード
try
	set strCommandText to "/usr/bin/curl -L -o  \"" & strTempDirPath & "/" & strSaveFileName & "\"  \"" & strPkgURL & "\" --connect-timeout 20" as text
	do shell script strCommandText
on error
	try
		set strCommandText to "/usr/bin/curl -L -o  \"" & strTempDirPath & "/" & strSaveFileName & "\"  \"" & strPkgURL & "\"  --http1.1 --connect-timeout 20" as text
		do shell script strCommandText
	on error
		return "インストーラーのダウンロードに失敗しました"
	end try
end try


##################################
##【３】インストール前準備
###Dockのポジションを記憶 "/Library/Managed Preferences" は考慮しない
set strFilePath to "~/Library/Preferences/com.apple.dock.plist" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set ocidPerAppsArray to ocidPlistDict's objectForKey:("persistent-apps")
set intArrayNo to (count of ocidPerAppsArray) as integer
set intCntNo to 0 as integer
repeat with itemerAppsArray in ocidPerAppsArray
	set ocidTitleDataDict to (itemerAppsArray's objectForKey:("tile-data"))
	set ocidFileDataDict to (ocidTitleDataDict's objectForKey:("file-data"))
	set ocidCFURLString to (ocidFileDataDict's valueForKey:("_CFURLString"))
	if (ocidCFURLString as text) contains ("zoom.us.app") then
		exit repeat
	end if
	set intCntNo to intCntNo + 1 as integer
end repeat
if intArrayNo = intCntNo then
	set intDocNo to (intArrayNo) as integer
	log "Dockに登録されていません。一番下を指定します"
else
	set intDocNo to (intCntNo) as integer
	log "Dockの " & intCntNo & "番目に登録されています"
end if

###アプリケーション終了
set listUTI to {"us.zoom.caphost", "us.zoom.xos", "us.zoom.CptHost", "us.zoom.Transcode", "us.zoom.ZMScreenshot"} as list
###通常終了
repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat
delay 2
###強制終了
repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
end repeat
###ユーザーアプリケーションディレクトリ700で
set ocidURLsPathArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppDirPathURL to ocidURLsPathArray's firstObject()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set boolDone to appFileManager's createDirectoryAtURL:(ocidAppDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
###ローカライズファイル
set ocidLocalizedPathURL to ocidAppDirPathURL's URLByAppendingPathComponent:(".localized")
set ocidLocalizedPath to ocidLocalizedPathURL's |path|()
set boolDone to appFileManager's createFileAtPath:(ocidLocalizedPath) |contents|:(missing value) attributes:(ocidAttrDict)
###ゴミ箱
set ocidURLsPathArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidTrashDirPathURL to ocidURLsPathArray's firstObject()

################################################
###クリーニング
################################################
to doGoToTrash(arg_strFilePath)
	set strFilePath to arg_strFilePath as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
	set appFileManager to refMe's NSFileManager's defaultManager()
	set boolDone to appFileManager's trashItemAtURL:(ocidFilePathURL) resultingItemURL:(ocidFilePathURL) |error|:(reference)
end doGoToTrash

doGoToTrash("/Applications/zoom.us.app")
doGoToTrash("/Applications/ZoomOutlookPlugin")
doGoToTrash("~/Applications/zoom.us.app")
delay 1 --> Dockからの削除待ち
doGoToTrash("~/Applications/ZoomOutlookPlugin")
doGoToTrash("~/Library/Caches/us.zoom.xos")
doGoToTrash("~/Library/WebKit/us.zoom.xos")
doGoToTrash("~/Library/Saved Application State/us.zoom.xos.savedState")
doGoToTrash("~/Library/Receipts/ZoomMacOutlookPlugin.pkg.plist")
doGoToTrash("~/Library/Receipts/ZoomMacOutlookPlugin.pkg.bom")
doGoToTrash("~/Library/Logs/ZoomPhone")
doGoToTrash("~/Library/Logs/zoom.us")
doGoToTrash("~/Library/HTTPStorages/us.zoom.xos.binarycookies")
doGoToTrash("~/Library/HTTPStorages/us.zoom.xos")

delay 1 --> Dockからの削除待ち

##################################
##【４】インストール本処理（ユーザーインストール）
###パッケージがあるか？確認
set strPkgPath to ("" & strTempDirPath & "/" & strSaveFileName & "") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set boolFileExist to appFileManager's fileExistsAtPath:(ocidFilePath) isDirectory:(false)
if boolFileExist = true then
	set strCommandText to "/usr/sbin/installer -pkg    \"" & strTempDirPath & "/" & strSaveFileName & "\" -target CurrentUserHomeDirectory -dumplog -allowUntrusted  -lang ja" as text
	do shell script strCommandText
else
	return "パッケージが見つかりません"
end if


##################################
##【５】後処理
##
###ユーザーインストールした場合のURL
set strAppPath to "~/Applications/zoom.us.app" as text
set ocidAppPathstr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathstr's stringByStandardizingPath()
set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:true
set coidAbsoluteStringPath to ocidAppPathURL's absoluteString()

################################
###PLIST 読み込み
set strFilePath to "~/Library/Preferences/com.apple.dock.plist" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidPlistPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set ocidPersistentArray to ocidPlistDict's objectForKey:"persistent-apps"

################################
####persistent-appsデータ生成
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###GUID実際はランダム番号だがNSFileSystemFileNumberを使う
set listPathAttar to appFileManager's attributesOfItemAtPath:(ocidAppPath) |error|:(reference)
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
set ocidAppBundle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
set ocidBundleID to ocidAppBundle's bundleIdentifier
set ocidStringValue to ocidBundleID's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("bundle-identifier")
####file-label"
set listAttributesDict to ocidAppPathURL's resourceValuesForKeys:({refMe's NSURLLocalizedNameKey}) |error|:(reference)
set ocidAttributesDict to (item 1 of listAttributesDict)
set ocidLocalizedName to (ocidAttributesDict's objectForKey:(refMe's NSURLLocalizedNameKey))
set ocidFileLabel to (ocidLocalizedName's stringByDeletingPathExtension())
set ocidStringValue to ocidFileLabel's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("file-label")
####file-mod-date
set listAttributesDict to ocidAppPathURL's resourceValuesForKeys:({refMe's NSURLContentModificationDateKey}) |error|:(reference)
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
set listBookMarkData to (ocidAppPathURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidkDataValue to item 1 of listBookMarkData
(ocidAddTitleDataDict's setObject:(ocidkDataValue) forKey:("book"))
####file-type
#	169		Launchpad とMission Control
#	41			それ以外はまぁ４１で間違いなさそう
set ocidIntValue to (refMe's NSNumber's numberWithInteger:41)
(ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("file-type"))
#########
set ocidAddFileDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
(ocidAddFileDataDict's setValue:(coidAbsoluteStringPath) forKey:("_CFURLString"))
####
#		0	/File/Path
#		15 file:// のURL形式
set ocidIntValue to (refMe's NSNumber's numberWithInteger:15)
(ocidAddFileDataDict's setValue:(ocidIntValue) forKey:("_CFURLStringType"))
#########
(ocidAddTitleDataDict's setObject:(ocidAddFileDataDict) forKey:("file-data"))
ocidAddDict's setObject:(ocidAddTitleDataDict) forKey:("tile-data")
####追加データを元のPLISTに戻す
ocidPersistentArray's insertObject:(ocidAddDict) atIndex:(intDocNo)
####保存
set boolDone to ocidPlistDict's writeToURL:(ocidPlistPathURL) atomically:true


###CFPreferencesを再起動
try
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
on error
	set strPlistPath to "/System/Library/LaunchAgents/com.apple.cfprefsd.xpc.agent.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
end try

########################
## Dock 再起動
########################

set strBundleID to "com.apple.dock"

########################
## 再起動
########################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##バンドルからアプリケーションのURLを取得
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
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
end if
##Dock終了
set ocidRunningApplication to refMe's NSRunningApplication
###起動中のすべてのリスト
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
###複数起動時も順番に終了
repeat with itemAppArray in ocidAppArray
	###終了
	itemAppArray's terminate()
end repeat
##１秒まって終了を確認
delay 1
##終了できない場合は強制終了
repeat with itemAppArray in ocidAppArray
	set boolTerminate to itemAppArray's terminated
	if boolTerminate = false then
		itemAppArray's forceTerminate()
	end if
end repeat

###起動
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
###コンフィグ
(ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true))
###起動
(appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value))

return "再起動"
