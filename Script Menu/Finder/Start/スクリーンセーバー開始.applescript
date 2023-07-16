#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　入力した文言でスクリーンセイバーが開始します
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "IOKit"
use scripting additions

property refMe : a reference to current application
set objFileManager to refMe's NSFileManager's defaultManager()


set aliasIconPath to POSIX file "/System/Library/CoreServices/ScreenSaverEngine.app/Contents/Resources/ScreenSaverEngine.icns" as alias
set strDefaultAnswer to "離席中です<<すぐ戻ります" as text
try
	set recordResponse to (display dialog "スクリーンセイバーに表示する文字列" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 30 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if

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
