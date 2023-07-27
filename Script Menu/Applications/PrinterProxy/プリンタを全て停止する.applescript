#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application




##########################################
###PLISTからプリンター情報を取得する
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
set ocidKeyArray to ocidPrinterDict's allKeys()
set listKeyList to ocidKeyArray as list

repeat with itemKey in listKeyList
	###ダイアログの戻り値からデバイス名を取得
	set ocidDeviceName to (ocidDeviceNameDict's valueForKey:(itemKey))
	set strDeviceName to ocidDeviceName as text
	try
		set theComand to ("/usr/sbin/cupsreject \"" & strDeviceName & "\"") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
	try
		set theComand to ("/usr/sbin/cupsdisable \"" & strDeviceName & "\"") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
end repeat


return "処理終了"

##旧タイプのデバイス名取得方法
##############################
set thePrinterList to (do shell script "lpstat -e") as text
set AppleScript's text item delimiters to "\r"
set listPrinterList to every text item of thePrinterList as list
set AppleScript's text item delimiters to ""


repeat with objPrinterName in listPrinterList
	log objPrinterName
	try
		set theComand to ("/usr/sbin/cupsreject \"" & objPrinterName & "\"") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
	try
		set theComand to ("/usr/sbin/cupsdisable \"" & objPrinterName & "\"") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
	
end repeat
