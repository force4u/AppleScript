#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# OS14対応
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###書類フォルダ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
##保存先
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Mobileconfig/Bakup")
##フォルダ作成
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###日付取得
set strDateNo to doGetDateNo("yyyyMMdd") as text
##
set strSaveFileName to (strDateNo & ".plist") as text
##
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
set appFileManager to refMe's NSFileManager's defaultManager()
##ファイルの有無チェック
set boolFileExists to (appFileManager's fileExistsAtPath:(ocidSaveFilePathURL's |path|) isDirectory:false)
if boolFileExists is true then
	###すでにある場合はゴミ箱に
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listResult to (appFileManager's trashItemAtURL:(ocidSaveFilePathURL) resultingItemURL:(ocidSaveFilePathURL) |error|:(reference))
	set strSaveFilePath to ocidSaveFilePathURL's |path| as text
else
	set strSaveFilePath to ocidSaveFilePathURL's |path| as text
end if
##ユーザー名取得
set ocidUserName to refMe's NSUserName()
set strUserName to ocidUserName as text
##コマンド整形
set strCommandText to ("/usr/bin/profiles show -user " & strUserName & " -type configuration -output \"" & strSaveFilePath & "\"") as text
###実行
set strResponse to (do shell script strCommandText) as text
###保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(strSaveFilePath) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())
###エラーならファインダーで開く
if boolDone is false then
	set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasCameraRawDirPathURL
	end tell
	return "エラーしました"
end if


#####
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
