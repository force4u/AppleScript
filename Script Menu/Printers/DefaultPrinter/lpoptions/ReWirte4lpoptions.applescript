#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
lpoptionsのプリンタ名を変更する
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##########################################
###PLISTからプリンター情報を取得する
##URL
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()
set ocidPlistPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Preferences/org.cups.printers.plist") isDirectory:false
###PLIST読み込み
set ocidPlistArray to refMe's NSMutableArray's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
###値を格納するためのレコード
set ocidPrinterDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidDeviceNameDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###PLISTの項目の数だけ繰り返し
repeat with itemArrayDic in ocidPlistArray
	###printer-info名を取得する
	set ocidPrinterName to (itemArrayDic's valueForKey:("printer-info"))
	###エラーよけ
	if (ocidPrinterName as text) is "" then
		set ocidPrinterName to (itemArrayDic's valueForKey:("printer-make-and-model"))
	end if
	###URIを格納
	set ocidDeviceUri to (itemArrayDic's valueForKey:("device-uri"))
	(ocidPrinterDict's setValue:(ocidDeviceUri) forKey:(ocidPrinterName))
	###デバイス名の取得
	set ocidDeviceName to (itemArrayDic's valueForKey:("printer-name"))
	(ocidDeviceNameDict's setValue:(ocidDeviceName) forKey:(ocidPrinterName))
end repeat
###ダイアログ用のALLkey
set ocidKeyList to ocidPrinterDict's allKeys()
set listKeyList to ocidKeyList as list
##########################################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listKeyList with title "選んでください" with prompt "デフォルトプリンタは？" default items (item 1 of listKeyList) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
###ダイアログ戻り値
set strNameKey to (item 1 of listResponse) as text
###ダイアログの戻り値からURIを取得
set ocidDeviceUri to ocidPrinterDict's valueForKey:(strNameKey)
###ダイアログの戻り値からデバイス名を取得
set ocidDeviceName to ocidDeviceNameDict's valueForKey:(strNameKey)
set strDeviceName to ocidDeviceName as text
###################################################
###lpoptionsを書換

##このままでも良いが念の為フルパスにしておく
set strFilePath to "~/.cups/lpoptions" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
##バックアップ先
set strbackUpDirPath to "~/.cups_backup" as text
set ocidbackUpDirPathStr to refMe's NSString's stringWithString:(strbackUpDirPath)
set ocidbackUpDirPath to ocidbackUpDirPathStr's stringByStandardizingPath()
set ocidbackUpDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidbackUpDirPath) isDirectory:false)
#保存先ディレクトリを作る 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
##フォルダ作って
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidbackUpDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
###バックアップファイル名には日付を入れる
set strDateno to doGetDateNo("yyyyMMdd") as text
set strBackupFileName to ("lpoptions" & strDateno) as text
set ocidbackUpFilePathURL to ocidbackUpDirPathURL's URLByAppendingPathComponent:(strBackupFileName) isDirectory:false
###バックアップ
set boolDone to appFileManager's copyItemAtURL:(ocidFilePathURL) toURL:(ocidbackUpFilePathURL) |error|:(reference)
###編集用テキスト
set ocidEditString to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
###lpoptionsを読み込んで
set listReadString to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
##改行で
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet()
###リスト化して
set ocidReadArray to (item 1 of listReadString)'s componentsSeparatedByCharactersInSet:(ocidChrSet)
repeat with itemArray in ocidReadArray
	set strItemArray to itemArray as text
	###置換する
	if strItemArray starts with "Default" then
		set strAddText to ("Default " & strDeviceName & "\n") as text
	else
		if strItemArray is "" then
			set strAddText to ("") as text
		else
			set strAddText to (strItemArray & "\n") as text
		end if
	end if
	(ocidEditString's appendString:(strAddText))
end repeat
###出来上がったテキストを保存
set booleDone to ocidEditString's writeToURL:(ocidFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
log booleDone
log ocidEditString as text

####日付情報の取得
to doGetDateNo(strDateFormat)
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
