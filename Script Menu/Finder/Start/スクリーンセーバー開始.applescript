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


set aliasIconPath to POSIX file "/System/Library/CoreServices/ScreenSaverEngine.app/Contents/Resources/AppIcon.icns" as alias
set strDefaultAnswer to "離席中です<すぐ戻ります" as text
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