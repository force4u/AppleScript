#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
###ファイルマネージャー初期化
set appFileManager to refMe's NSFileManager's defaultManager()
###日付番号
set strDateno to (doGetDateNo("yyyyMMdd")) as text
####デスクトップフォルダURL
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
###デスクトップ＋日付で作成するフォルダのURL
set ocidMakeDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strDateno)
###有無チェック
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidMakeDirPath) isDirectory:(true)
###なければ作る
if boolDirExists = false then
	log "作成します"
	###フォルダを作成する
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	log (item 1 of listBoolMakeDir)
	if (item 1 of listBoolMakeDir) = false then
		display alert "デスクトップにフォルダ作れませんでした"
	else
		return "処理終了"
	end if
	###すでにあればアラート表示
else
	display alert "デスクトップにすでにあります"
	return "処理終了"
end if


####################################
##日付番号取得
####################################
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
