#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#https://developer.apple.com/download/all/?q=PacketLogger
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

try
	tell application id "com.apple.PacketLogger"
		activate
	end tell
on error
	tell application "Finder"
		open location "https://developer.apple.com/download/all/?q=PacketLogger"
	end tell
	return "パケットロガーをインストールしてください"
end try


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Logs/Apple/BluetoothReporter")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
if (item 1 of listDone) is true then
	log "正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "フォルダ作成　エラーしました"
end if

set strDate to doGetDateNo("yyyyMMdd") as text
set strSaveFileName to (strDate & "-BluetoothReporter.pklg")
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
#
try
	set strCommandText to ("/usr/bin/sudo /System/Library/Frameworks/IOBluetooth.framework/Resources/BluetoothReporter --dumpPacketLog \"" & strSaveFilePath & "\"") as text
	do shell script strCommandText
on error
	return "コマンドでエラーしました"
end try
#
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
tell application "Finder"
	open file aliasFilePath
end tell
return


##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


