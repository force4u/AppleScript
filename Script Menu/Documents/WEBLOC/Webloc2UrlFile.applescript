#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#weblocファイルをWindow用のurlファイルに変換します
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set listUTl to {"com.apple.web-internet-location"} as list

###################################
#####入力ダイアログ
###################################
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

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDesktopPathURLArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDesktopPathURL to ocidUserDesktopPathURLArray's firstObject()
set aliasDefaultLocation to (ocidUserDesktopPathURL's absoluteURL()) as alias
### set listUTI to {"public.png", "public.jpeg"}
set strPromptText to "weblocファイルを選んでください" as text
set strMesText to "weblocファイルを選んでください" as text
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTl with invisibles and multiple selections allowed without showing package contents) as list

repeat with itemFilePath in listAliasFilePath
	##パス関連
	set aliasFilePath to itemFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	###保存先URL　拡張子取って
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	###拡張子　つける
	set ocidURLFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("url"))
	###リンク先URLを取得
	set ocidPlistDict to (refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL))
	set strValueURL to (ocidPlistDict's valueForKey:("URL")) as text
	#########################
	####URLファイルを作る
	set strShortCutFileString to ("[InternetShortcut]\r\nURL=" & strValueURL & "\r\n") as text
	set ocidShortCutFileString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
	(ocidShortCutFileString's setString:(strShortCutFileString))
	##保存
	set boolDone to (ocidShortCutFileString's writeToURL:(ocidURLFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
	log (item 1 of boolDone)
	
end repeat

