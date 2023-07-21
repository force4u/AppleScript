#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

################################
##### パス関連
################################
##ベースファイル名
set strBaseFileName to "クリップボード" as text
##デスクトップ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()

################################
######ペーストボードを取得
################################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
####タイプを取得
set ocidPastBoardTypeArray to ocidPasteboard's types()
###タイプをリストに
set listType to {} as list
repeat with itemPastBoardTypeArray in ocidPastBoardTypeArray
	set strPastBoardTypeArray to (itemPastBoardTypeArray) as text
	if strPastBoardTypeArray is "public.utf16-external-plain-text" then
		log "UTF16はスキップ"
	else if strPastBoardTypeArray contains "public" then
		set end of listType to strPastBoardTypeArray
	end if
end repeat
if listType = {} then
	return "書き出し出来ない"
end if
################################
######ペーストボードを取得
################################
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
	set listResponse to (choose from list listType with title "選んでください" with prompt "フォーマットを選んでください" default items (item 1 of listType) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
################################
##### 本処理
################################
if strResponse is "public.tiff" then
	set strBaseFileName to strBaseFileName & "TIFF"
	set ocidSaveData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeTIFF)
	set strExtension to "tiff"
	set strFileName to (strBaseFileName & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
	set boolTextEdit to false as boolean
else if strResponse is "public.png" then
	set strBaseFileName to strBaseFileName & "PNG"
	set ocidSaveData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypePNG)
	set strExtension to "png"
	set strFileName to (strBaseFileName & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
	set boolTextEdit to false as boolean
else if strResponse is "public.rtf" then
	set strBaseFileName to strBaseFileName & "RTF"
	set ocidSaveData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeRTF)
	set strExtension to "rtf"
	set strFileName to (strBaseFileName & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
	set boolTextEdit to true as boolean
else if strResponse is "public.html" then
	set strBaseFileName to strBaseFileName & "HTML"
	set ocidSaveData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeHTML)
	set strExtension to "html"
	set strFileName to (strBaseFileName & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
	set boolTextEdit to true as boolean
else if strResponse is "public.utf8-plain-text" then
	set strBaseFileName to strBaseFileName & "TEXT"
	set ocidSaveData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeString)
	set strExtension to "txt"
	set strFileName to (strBaseFileName & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
	set boolTextEdit to true as boolean
else
	return "この処理では処理しない"
end if
set ocidSaveFilePath to ocidSaveFilePathURL's |path|()
###ファイルの有無チェック
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveFilePath) isDirectory:(false)
###すでに同名がある場合は日付時間連番を付与
if boolDirExists is true then
	set strDateNo to doGetDateNo("yyyyMMddhhmmss")
	set strFileName to (strBaseFileName & "." & strDateNo & "." & strExtension) as text
	set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
end if

################################
##### 保存
################################
####ファイルに書き出し
set boolFileWrite to (ocidSaveData's writeToURL:(ocidSaveFilePathURL) atomically:true)
################################
##### open
################################
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
if boolTextEdit is true then
	tell application "TextEdit"
		activate
		open file aliasSaveFilePath
	end tell
else
	tell application id "com.apple.Preview"
		activate
		open file aliasSaveFilePath
	end tell
end if
################################
##### 日付
################################
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
