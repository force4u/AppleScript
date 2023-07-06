#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe

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

###lpadminを打ってCUPSに通知する
set strDeviceName to ocidDeviceName as text
set strCommandText to ("/usr/sbin/lpadmin  -d \"" & strDeviceName & "\"") as text
try
	do shell script strCommandText
end try

