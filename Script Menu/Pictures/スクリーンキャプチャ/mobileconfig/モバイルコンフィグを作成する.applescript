#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###UUIDを新規にするか？
set boolNewUUID to false as boolean

###GITから元データを取得
set strTempURL to "https://raw.githubusercontent.com/force4u/AppleScript/main/Script%20Menu/Pictures/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%AD%E3%83%A3%E3%83%95%E3%82%9A%E3%83%81%E3%83%A3/mobileconfig/com.apple.screencapture.mobileconfig" as text
set ocidTempURLStr to refMe's NSString's stringWithString:(strTempURL)
set ocidTempURL to refMe's NSURL's URLWithString:(ocidTempURLStr)
set ocidFileName to ocidTempURL's lastPathComponent()

##############################################
## 保存先
##############################################
set appFileManager to refMe's NSFileManager's defaultManager()
##書類フォルダに
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
##Mobileconfigフォルダを作って
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Mobileconfig") isDirectory:false
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###その中に保存先URLを指定
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false

##############################################
## PLISTから保存先設定を取得(Managed Preferencesは考慮しない)
##############################################
set strFilePath to "~/Library/Preferences/com.apple.screencapture.plist" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set ocidSaveLocation to ocidPlistDict's valueForKey:("location")
if (ocidSaveLocation as text) does not contain "/" then
	###値が無い場合は	
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
	set ocidSaveLocation to ocidPicturesDirPathURL's |path|()
end if
##############################################
## 本処理  ROOT 項目
##############################################
set strDateno to doGetDateNo("yyyyMMdd")
set ocidVerSionNo to (refMe's NSNumber's numberWithInteger:strDateno)'s intValue
####
set ocidPlistDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
set listReadPlistData to (refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidTempURL |error|:(reference))
set ocidReadDict to (item 1 of listReadPlistData)
(ocidPlistDict's setDictionary:ocidReadDict)
set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
log "現在のバージョン：" & numVerSion
###変更
(ocidPlistDict's setValue:ocidVerSionNo forKey:"PayloadVersion")
set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
log "変更後のバージョン：" & numVerSion
if boolNewUUID is true then
	####UUIDを変更して新規にする場合
	set ocidUUID to refMe's NSUUID's alloc()'s init()
	set ocidUUID to ocidUUID's UUIDString
	(ocidPlistDict's setValue:(ocidUUID) forKey:"PayloadUUID")
	####UUIDを変更して新規にする場合
	set ocidPayloadIdentifier to refMe's NSMutableString's stringWithString:("com.apple.screencapture.")
	ocidPayloadIdentifier's appendString:(ocidUUID)
	(ocidPlistDict's setValue:(ocidPayloadIdentifier) forKey:"PayloadIdentifier")
end if
##############################################
## 本処理  PayloadContent
##############################################
set ocidPayloadContentArray to (ocidPlistDict's objectForKey:"PayloadContent")
repeat with itemPayloadContentDict in ocidPayloadContentArray
	set numVerSion to (itemPayloadContentDict's valueForKey:"PayloadVersion") as integer
	log "現在のバージョン：" & numVerSion
	###変更
	(itemPayloadContentDict's setValue:(ocidVerSionNo) forKey:"PayloadVersion")
	set numVerSion to (itemPayloadContentDict's valueForKey:"PayloadVersion") as integer
	log "変更後のバージョン：" & numVerSion
	##保存先
	log "PLISTの保存先:" & (ocidSaveLocation as text)
	(itemPayloadContentDict's setValue:(ocidSaveLocation) forKey:"location")
	if boolNewUUID is true then
		####UUIDを変更して新規にする場合
		set ocidUUID to refMe's NSUUID's alloc()'s init()
		set ocidUUID to ocidUUID's UUIDString
		(itemPayloadContentDict's setValue:(ocidUUID) forKey:"PayloadUUID")
		####UUIDを変更して新規にする場合
		set ocidPayloadIdentifier to (refMe's NSMutableString's stringWithString:("com.apple.screencapture."))
		(ocidPayloadIdentifier's appendString:(ocidUUID))
		(itemPayloadContentDict's setValue:(ocidPayloadIdentifier) forKey:"PayloadIdentifier")
	end if
end repeat
##############################################
## 保存
##############################################
set ocidPlistType to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to (refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistDict format:ocidPlistType options:0 |error|:(reference))
set ocidPlisSaveData to item 1 of listPlistEditDataArray
set boolSaveDone to (ocidPlisSaveData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference))
log boolSaveDone as list

###登録実行
tell application id "com.apple.systempreferences" to launch
tell application id "com.apple.systempreferences"
	activate
	reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
end tell

###FinderのURL
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set strBundleID to "com.apple.finder" as text
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
###パネルのURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("x-apple.systempreferences")
ocidURLComponents's setPath:("com.apple.preferences.configurationprofiles")
set ocidOpenAppURL to ocidURLComponents's |URL|
set strOpenAppURL to ocidOpenAppURL's absoluteString() as text
###ファイルURLとパネルのURLをArrayにしておく
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenUrlArray's insertObject:(ocidSaveFilePathURL) atIndex:0
ocidOpenUrlArray's insertObject:(ocidOpenAppURL) atIndex:1
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	set theCmdCom to ("open \"" & strFilePath & "\" | open \"" & strOpenAppURL & "\"") as text
	do shell script theCmdCom
else
	###FinderでファイルとURLを同時に開く
	set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
	ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
	appShardWorkspace's openURLs:(ocidOpenUrlArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
end if


###保存ファイル表示
#選択状態で開く
set boolDone to appShardWorkspace's selectFile:(ocidSaveFilePathURL's |path|) inFileViewerRootedAtPath:(ocidDocumentDirPathURL's |path|)
log "【７】" & boolDone

###システム設定を前面に
set ocidRunningApp to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApp's runningApplicationsWithBundleIdentifier:("com.apple.systempreferences"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
set boolDone to ocidApp's active



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
