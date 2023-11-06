#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#【留意事項】~を使ったHOME指定は、/User/someuser/形式に
# 変換されるので、自分環境専用となります
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()


##デフォルトクリップボードから
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
try
	set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
on error
	set ocidPasteboardStrings to "" as text
end try
set strDefaultAnswer to ocidPasteboardStrings as text
if strDefaultAnswer starts with "/" then
	set strURL to strDefaultAnswer as text
else if strDefaultAnswer starts with "~" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strDefaultAnswer)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
	set strURL to ocidFilePathURL's absoluteString() as text
else
	set strURL to ("/some/path/file/or/dir") as text
end if
################################
######ダイアログ
################################
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
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
try
	set strMes to ("ファイルパスを入力してください\n例：\n/some/path/file/or/dir\n~/Desktop") as text
	
	set recordResponse to (display dialog strMes with title "ファイルパスを入力してください" default answer strURL buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "キャンセルしました"
	return "キャンセルしました"
end if

if strResponse starts with "/" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strResponse)
	
else if strResponse starts with "~" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strResponse)
else
	return "ファイルパス専用です"
end if
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
set strURL to ocidFilePathURL's absoluteString() as text
###ファイル名を取得して拡張子を取っておく
set ocidBaseNamePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set strBaseFileName to (ocidBaseNamePathURL's lastPathComponent()) as text
###保存用のファイル名
set strSaveFileName to (strBaseFileName & ".fileloc") as text
###保存先はデスクトップ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
###PLIST用のURLの値
set strURL to (ocidFilePathURL's absoluteString()) as text
##############################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
###
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
###
set listDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)


