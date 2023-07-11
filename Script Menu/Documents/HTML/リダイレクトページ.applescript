#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


set strHTML to "<!DOCTYPE html>\n<html lang=\"ja\">\n<head>\n<meta charset=\"UTF-8\" />\n<title>指定ページに移動（リダイレクト）します</title>\n<meta http-equiv=\"refresh\" content=\"0;URL=@LINK@\">\n<script>\nlocation.href='@LINK@';\n</script>\n</head>\n<body>\n<h1>リダイレクト</h1>\n<p>移動しました<br>\nジャンプしない場合は、以下のURLをクリックしてください。</p>\n<p><a href=\"@LINK@\">移転先のページ</a></p><br><p>@LINK@</p>\n</body>\n</html>" as text



set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias

###
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	set strReadString to (the clipboard as text)
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "https://" as text
	end if
end if
if strReadString starts with "http" then
	set strDefaultAnswer to strReadString as text
else
	set strDefaultAnswer to "http://" as text
end if

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

set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" as alias

try
	set recordResponse to (display dialog "URLをペーストしてください" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
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
###保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidForDirectoryArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirectoryArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
set strDefaultName to "名称未設定.html" as text
set strExtension to "html"
set strPromptText to "の名前を決めてください" as text
set strMesText to "名前を決めてください" as text
set aliasFilePath to (choose file name strMesText default location aliasDefaultLocation default name strDefaultName with prompt strPromptText) as «class furl»
######
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidSaveFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidFileName to ocidSaveFilePathURL's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
set ocidExtensionName to ocidSaveFilePathURL's pathExtension()
###空の文字列　if文用
set ocidEmptyString to refMe's NSString's alloc()'s init()
if ocidExtensionName = ocidEmptyString then
	###ダイアログで拡張子取っちゃった場合対策
	set ocidSaveFilePathURL to ocidFilePathURL's URLByAppendingPathExtension:(strExtension)
end if


###HTML内容生成
set ocidURL to refMe's NSString's stringWithString:(strResponse)
set ocidStringM to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidStringM's setString:(strHTML)

##文字列の置換
set ocidNSRange to ocidStringM's rangeOfString:(strHTML)
set ocidOptions to refMe's NSRegularExpressionSearch
ocidStringM's replaceOccurrencesOfString:("@LINK@") withString:(ocidURL) options:(ocidOptions) range:(ocidNSRange)

###保存
set ocidEnc to refMe's NSUTF8StringEncoding
set boolDone to ocidStringM's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(ocidEnc) |error|:(reference)



