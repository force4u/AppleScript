#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


set strFileName to "名称未設定.docx" as text


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
	set strFileName to "名称未設定." & strDateNo & ".docx"
	set ocidSaveFilePathURL to ocidUserDesktopPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
end if


set strSaveFilePath to ocidSaveFilePathURL's |path|() as text


tell application "TextEdit"
	activate
	make new document with properties {name:strFileName, path: strSaveFilePath}
	tell document strFileName
		activate
		save in (POSIX file strSaveFilePath)
	end tell
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
