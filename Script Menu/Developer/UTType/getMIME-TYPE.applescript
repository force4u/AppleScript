#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##############################
###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDesktopPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDesktopPathURL to ocidUserDesktopPathArray's firstObject()
set aliasUserDesktopPath to ocidUserDesktopPathURL's absoluteURL() as alias
##############################
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
#####ファイルを選択
set listUTI to {"public.item"}
set strPromptText to "ファイルを選んで下さい。" as text
set strMesText to "MIME-TYPEを取得します" as text
set aliasFilePath to (choose file strMesText default location aliasUserDesktopPath with prompt strPromptText of type listUTI with invisibles without multiple selections allowed) as alias

######ファイルURL
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

####UTIの取得
set listResponse to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
set ocidContentType to (item 2 of listResponse)
set ocidTagDict to (ocidContentType's tags)

log ocidTagDict as record
##MIME-TYPEの取得
set ocidMimeType to ocidTagDict's valueForKey:"public.mime-type"
###tagにmimeが含まれていなかったら
if ocidMimeType = (missing value) then
	set theCommandText to ("/usr/bin/file --mime-type  \"" & strFilePath & "\" | cut -f 2 -d ':'") as text
	log theCommandText
	set strMimeType to (do shell script theCommandText) as text
else
	###tagにmimeがあればそのまま値を利用する
	set strMimeType to (ocidContentType's preferredMIMEType()) as text
end if

###ダイアログ
set strIconPath to "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
set aliasIconPath to POSIX file strIconPath as alias
set recordResult to (display dialog "MiMETypeの戻り値です" with title "MiMEType" default answer strMimeType buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
