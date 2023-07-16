#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　入力した文言でスクリーンセイバーが開始します
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
######設定の変更
#####################################
set strPlistSubPath to "Preferences/ByHost/com.apple.screensaver." & strDeviceUUID & ".plist" as text

#####################################
######パス
#####################################
set ocidPathArray to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidPathArray's objectAtIndex:0
set ocidFilePathURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:(strPlistSubPath) isDirectory:false

#####################################
######plist読み込み
#####################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listResults to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of listResults

set strModuleName to (ocidPlistDict's valueForKeyPath:"moduleDict.moduleName") as text

if strModuleName is not "Computer Name" then
	#####################################
	######　値を変更して
	#####################################
	ocidPlistDict's setValue:"Computer Name" forKeyPath:"moduleDict.moduleName"
	ocidPlistDict's setValue:"/System/Library/Frameworks/ScreenSaver.framework/PlugIns/Computer Name.appex" forKeyPath:"moduleDict.path"
	ocidPlistDict's setValue:0 forKeyPath:"moduleDict.type"
	#####################################
	######　保存
	#####################################
	###書き込み用にバイナリPLISTデータに変換
	set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
	set ocidPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistDict format:ocidNSbplist options:0 |error|:(reference)
	set ocidPlistEditData to item 1 of ocidPlistEditDataArray
	set boolDone to ocidPlistEditData's writeToURL:ocidFilePathURL options:0 |error|:(reference)
end if

set ocidPlistDict to ""

#####################################
######メッセージの変更
#####################################
set strPlistSubPath to "Containers/com.apple.ScreenSaver.Computer-Name/Data/Library/Preferences/ByHost/com.apple.ScreenSaver.Computer-Name." & strDeviceUUID & ".plist" as text

#####################################
######パス
#####################################
set ocidPathArray to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidPathArray's objectAtIndex:0
set ocidFilePathURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:(strPlistSubPath) isDirectory:false

#####################################
######plist読み込み
#####################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listResults to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of listResults

#####################################
######　値の変更 -->スクリーンセーバーのメッセージ
#####################################
ocidPlistDict's setValue:strResponse forKeyPath:"MESSAGE"

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
#####コマンド実行
set strCommandText to "/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine" as text
do shell script strCommandText

return
###参考
set aliasScreenSaverEngine to POSIX file "/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine" as alias

tell application "Finder"
	open aliasScreenSaverEngine
end tell





set strCommandText to "open /System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine" as text
do shell script strCommandText





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
