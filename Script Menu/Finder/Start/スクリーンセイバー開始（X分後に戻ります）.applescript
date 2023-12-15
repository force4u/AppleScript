#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　入力した文言でスクリーンセイバーが開始します
#	初回時のPLISTが無いケースに対応
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "IOKit"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set objFileManager to refMe's NSFileManager's defaultManager()


###選択肢レコード
set recordTimeInterval to {|１５分後|:0.25, |３０分後|:0.5, |４５分後|:0.75, |１時間後|:1, |１時間半後|:1.5, |２時間後|:2} as record
###DICTからallKeyでリストにする
set ocidTimeIntervalDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidTimeIntervalDict's setDictionary:(recordTimeInterval)
set ocidAllKeys to ocidTimeIntervalDict's allKeys()
set ocidSortedArray to ocidAllKeys's sortedArrayUsingSelector:("localizedStandardCompare:")
set listAllKeys to ocidSortedArray as list

##############################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set strTitle to "戻る時間" as text
set strPrompt to "『HH時mm分ごろ戻ります』になります" as text
try
	set listResponse to (choose from list listAllKeys with title strTitle with prompt strPrompt default items (item 5 of listAllKeys) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if listResponse = {} then
	return "何も選択していない"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strValue to (ocidTimeIntervalDict's valueForKey:(item 1 of listResponse)) as text
end if
set numValue to strValue as number
set intIntervalSec to ((60 * 60) * numValue) as integer
####ここがメッセージになります
set strResponse to doGetIntervalDate({"離席中HH時mm分ごろ戻ります", intIntervalSec})
#####################################
#####デバイスID取得から処理開始
#####################################

set strDeviceUUID to doGetDeviceUUID() as text

#####################################
######パス
#####################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidPlistFilePathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Application Support/com.apple.wallpaper/Store/Index.plist")

#####################################
######plist読み込み
#####################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listResults to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference)
set ocidPlistDict to item 1 of listResults
###
set ocidDataArray to ocidPlistDict's valueForKeyPath:("AllSpacesAndDisplays.Idle.Content.Choices.Configuration")
set ocidData to (ocidDataArray's firstObject())
#####################################
######バックアップ
#####################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Apple/com.apple.wallpaper/")
set ocidSaveFilePathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Apple/com.apple.wallpaper/backup.plist")
###保存先ディレクトリ生成
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###バックアップ保存
set listDone to ocidData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
#####################################
######入れ替えデータ作成
#####################################
set ocidConfigurationDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidModuleDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
##セットするAppexのURL
set strAppexFilePath to "/System/Library/ExtensionKit/Extensions/Computer Name.appex" as text
set ocidAppexFilePathStr to refMe's NSString's stringWithString:(strAppexFilePath)
set ocidAppexFilePath to ocidAppexFilePathStr's stringByStandardizingPath()
set ocidAppexFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppexFilePath) isDirectory:false)
set strAppexFilePathURL to ocidAppexFilePathURL's absoluteString() as text
##値をセット
ocidModuleDict's setValue:(strAppexFilePathURL) forKey:("relative")
##↑のDICTをセット
ocidConfigurationDict's setObject:(ocidModuleDict) forKey:("module")
###XML形式
set ocidBinplist to refMe's NSPropertyListBinaryFormat_v1_0
###PLISTに
set listSetPlistData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidConfigurationDict) format:(ocidBinplist) options:0 |error|:(reference)
set ocidSetPlistData to item 1 of listSetPlistData

#####################################
######データセットして保存
#####################################
set ocidAllSpacesAndDisplays to ocidPlistDict's objectForKey:("AllSpacesAndDisplays")
set ocidIdle to ocidAllSpacesAndDisplays's objectForKey:("Idle")
set ocidContent to ocidIdle's objectForKey:("Content")
set ocidChoices to ocidContent's objectForKey:("Choices")
set ocidItem0 to ocidChoices's firstObject()
ocidItem0's setValue:("com.apple.wallpaper.choice.screen-saver") forKey:("Provider")
ocidItem0's setObject:(ocidSetPlistData) forKey:("Configuration")
##
set ocidAllSpacesAndDisplays to ocidPlistDict's objectForKey:("SystemDefault")
set ocidIdle to ocidAllSpacesAndDisplays's objectForKey:("Idle")
set ocidContent to ocidIdle's objectForKey:("Content")
set ocidChoices to ocidContent's objectForKey:("Choices")
set ocidItem0 to ocidChoices's firstObject()
ocidItem0's setValue:("com.apple.wallpaper.choice.screen-saver") forKey:("Provider")
ocidItem0's setObject:(ocidSetPlistData) forKey:("Configuration")
##
set boolDone to ocidPlistDict's writeToURL:(ocidPlistFilePathURL) atomically:true
log boolDone

#####################################
######com.apple.ScreenSaver.Computer-Nameのパス
#####################################
set strPlistSubPath to "Containers/com.apple.ScreenSaver.Computer-Name/Data/Library/Preferences/ByHost/com.apple.ScreenSaver.Computer-Name." & strDeviceUUID & ".plist" as text

#####################################
######パス
#####################################
set ocidPathArray to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidPathArray's objectAtIndex:0
set ocidFilePathURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:(strPlistSubPath) isDirectory:false
#####################################
######ファイルの有無確認
#####################################
set ocidFilePath to ocidFilePathURL's |path|()
set boolFileExists to appFileManager's fileExistsAtPath:(ocidFilePath) isDirectory:(false)
if boolFileExists = true then
	log "Plistは存在するので処理を継続"
else if boolFileExists = false then
	log "Plistが存在しないのでエラー新規作成する"
	##ByHostフォルダをまずは作成
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidContainerDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
end if

#####################################
######plist読み込み
#####################################
set listResults to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
set ocidReadDict to item 1 of listResults
#####################################
######　値の変更 -->スクリーンセーバーのメッセージ
#####################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
if (ocidPlistDict = (missing value)) then
	log "Plist新規作成"
	ocidPlistDict's setValue:strResponse forKey:"MESSAGE"
else
	ocidPlistDict's setDictionary:(ocidReadDict)
	ocidPlistDict's setValue:strResponse forKey:"MESSAGE"
end if
log ocidPlistDict as record

#####################################
######　保存
#####################################
###書き込み用にバイナリPLISTデータに変換
set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
set ocidPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistDict format:ocidNSbplist options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray
set boolDone to ocidPlistEditData's writeToURL:ocidFilePathURL options:0 |error|:(reference)

#####CFPreferencesを再起動させて変更後の値をロードさせる
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText
#####反映待ち
delay 2
#####################################
### スクリーンセーバースタート macOS14対応
#####################################
try
	tell application id "com.apple.ScreenSaver.Engine"
		##	launch
		activate
	end tell
on error
	#####コマンド実行
	try
		set strCommandText to "/usr/bin/open \"/System/Library/CoreServices/ScreenSaverEngine.app\"" as text
		do shell script strCommandText
	on error
		###
		set aliasScreenSaverEngine to POSIX file "/System/Library/CoreServices/ScreenSaverEngine.app" as alias
		tell application "Finder"
			open aliasScreenSaverEngine
		end tell
	end try
end try




#####################################
######ファイル名の日付
#####################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


#####################################
######　デバイスUUID 取得
#####################################

to doGetDeviceUUID()
	
	set objFileManager to refMe's NSFileManager's defaultManager()
	
	#####################################
	######テンポラリフォルダ生成
	#####################################
	set ocidTemporaryDirectoryURL to objFileManager's temporaryDirectory()
	set ocidCleanupAtStartupURL to ocidTemporaryDirectoryURL's URLByAppendingPathComponent:"Cleanup At Startup" isDirectory:true
	####アクセス権777で作成
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
	objFileManager's createDirectoryAtURL:ocidCleanupAtStartupURL withIntermediateDirectories:true attributes:ocidAttrDict |error|:(reference)
	#####################################
	######Plist File Path
	#####################################
	set strDateNo to doGetDateNo("yyyyMMddhhmmss")
	set strFileName to strDateNo & ".plist"
	set ocidFilePathURL to ocidCleanupAtStartupURL's URLByAppendingPathComponent:strFileName
	set strFilePath to ocidFilePathURL's |path|() as text
	
	#####################################
	######コマンド実行
	#####################################
	set strCommandText to "/usr/sbin/ioreg -c IOPlatformExpertDevice -a >> \"" & strFilePath & "\"" as text
	do shell script strCommandText
	
	#####################################
	######plist読み込み
	#####################################
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	set ocidReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
	set ocidPlistDict to item 1 of ocidReadPlistData
	
	#####################################
	######　デバイスUUID 取得
	#####################################
	set ocidDeviceUUID to (ocidPlistDict's valueForKeyPath:"IORegistryEntryChildren.IOPlatformUUID")
	
	
	#####################################
	######　シリアル番号取得
	#####################################
	set ocidSerialNumber to (ocidPlistDict's valueForKeyPath:"IORegistryEntryChildren.IOPlatformSerialNumber")
	
	
	#####################################
	######　モデル番号
	#####################################
	set ocidEntryName to (ocidPlistDict's valueForKeyPath:"IORegistryEntryChildren.IORegistryEntryName")
	
	return ocidDeviceUUID
	
end doGetDeviceUUID







################################
#### X秒後= argIntervalSec の時間
################################
to doGetIntervalDate({argDateFormat, argIntervalSec})
	set strDateFormat to argDateFormat as text
	set intIntervalSec to argIntervalSec as integer
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	####インターバル指定
	set ocidIntervalDate to ocidDate's dateByAddingTimeInterval:(intIntervalSec)
	###日付のフォーマットを定義
	set ocidFormatterJP to current application's NSDateFormatter's alloc()'s init()
	###日本のカレンダー
	set ocidCalendarJP to current application's NSCalendar's alloc()'s initWithCalendarIdentifier:(current application's NSCalendarIdentifierJapanese)
	###東京タイムゾーン
	set ocidTimezoneJP to current application's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
	###日本語
	set ocidLocaleJP to current application's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
	ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
	ocidFormatterJP's setLocale:(ocidLocaleJP)
	ocidFormatterJP's setCalendar:(ocidCalendarJP)
	ocidFormatterJP's setDateFormat:("Gyy")
	ocidFormatterJP's setDateFormat:(strDateFormat)
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidIntervalDate)
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetIntervalDate