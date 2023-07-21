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
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()

set strBaseFileName to "名称未設定" as text

####テキストエディトの対応ドキュメントタイプ
set listUTI to {"public.rtf", "com.apple.rtfd", "public.html", "com.apple.webarchive", "org.oasis-open.opendocument.text", "org.oasis-open.opendocument.text-template", "org.openoffice.text", "org.openoffice.text-template", "org.openxmlformats.wordprocessingml.document", "com.microsoft.word.wordml", "com.microsoft.word.doc", "public.text", "public.plain-text", "com.apple.traditional-mac-plain-text", "public.data"} as list
###値格納用のDICT
set ocidUTIDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###UTIの数だけ繰り返し
repeat with itemUTI in listUTI
	set strUTI to itemUTI as text
	###UTIの対応拡張子を調べる
	set ocidExt to (appSharedWorkspace's preferredFilenameExtensionForType:(itemUTI))
	if ocidExt ≠ (missing value) then
		###DICTに格納
		(ocidUTIDict's setValue:(ocidExt) forKey:(itemUTI))
	end if
end repeat
set ocidAllKeys to ocidUTIDict's allKeys()
###ダイアログ用にリストにする
set ocidAllValues to ocidUTIDict's allValues()
set listAllValues to ocidAllValues as list


#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAllValues with title "短め" with prompt "長め" default items (last item of listAllValues) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
###ファイル名
set strFileName to (strBaseFileName & "." & strResponse) as text

###デスクトップフォルダ
set listResponse to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDesktopPathURL to (item 1 of listResponse)
###ファイルパスURL
set ocidSaveFilePathURL to ocidUserDesktopPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set ocidSaveFilePath to ocidSaveFilePathURL's |path|()
###ファイルの有無チェック
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveFilePath) isDirectory:(false)
###すでに同名がある場合は日付時間連番を付与
if boolDirExists is true then
	set strDateNo to doGetDateNo("yyyyMMddhhmmss")
	set strFileName to (strBaseFileName & "." & strDateNo & "." & strResponse) as text
	set ocidSaveFilePathURL to ocidUserDesktopPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
end if

set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
tell application "TextEdit"
	activate
	make new document with properties {name:strFileName, path:strSaveFilePath}
	tell document strFileName
		activate
		save in (POSIX file strSaveFilePath)
		close
	end tell
	open (POSIX file strSaveFilePath)
end tell



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
