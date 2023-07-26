#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 起動時に削除される項目にHTMLを生成してそこで表示している
#
#
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
###アプリケーションのバンドルID
set strBundleID to "com.microsoft.edgemac"
###エラー処理
tell application id strBundleID
	set numWindow to (count of every window) as integer
end tell
if numWindow = 0 then
	return "Windowが無いので処理できません"
end if
tell application "Microsoft Edge"
	tell front window
		tell active tab
			activate
			set strURL to URL as text
		end tell
	end tell
end tell

###URLをNSStringに
set ocidURLStrings to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLStrings)
set strHostName to ocidURL's |host|() as text
##デコード
set ocidArgTextEncoded to ocidURLStrings's stringByRemovingPercentEncoding
set strArgTextEncoded to ocidArgTextEncoded as text


#######API各項目
###BASE URL
set theApiUrl to "https://chart.googleapis.com/chart?" as text
set theCht to "qr" as text
set theChs to "540x540" as text
set theChoe to "UTF-8" as text
set theChld to "Q" as text
###URLを整形
set strOpenUrl to ("" & theApiUrl & "&cht=" & theCht & "&chs=" & theChs & "&choe=" & theChoe & "&chld=" & theChld & "&chl=" & strURL & "") as text

##表示用URL
set strHTML to ("<!DOCTYPE html>\n<html lang=\"ja\">\n<head>\n<meta charset=\"UTF-8\" />\n<title>[QR]chart.googleapis.com</title>\n</head>\n<body>\n<p>" & strArgTextEncoded & "</p>\n<p>" & strURL & "</p>\n<p><a href=\"" & strOpenUrl & "\" target=\"_parent\"><img src=\"" & strOpenUrl & "\" id=\"qrImage\"></a></p>\n<p></body>\n</html>") as text

set ocidHTML to refMe's NSString's stringWithString:(strHTML)

###保存先 ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###ディレクトリ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###保存先ファイルパス
set strFileName to (strHostName & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set boolDone to ocidHTML's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
log boolDone

set theOpenUrl to ocidSaveFilePathURL's absoluteString() as text
##set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias

###Edgeに渡す
tell application "Microsoft Edge"
	activate
	tell front window
		set objNewTab to make new tab
		tell objNewTab to set URL to theOpenUrl
	end tell
end tell


set ocidURLString to refMe's NSString's stringWithString:(theOpenUrl)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLString)
set aliasFilePath to (ocidURL's absoluteURL()) as alias
set ocidContainerDirURL to ocidURL's URLByDeletingLastPathComponent()
set aliasDirPath to (ocidContainerDirURL's absoluteURL()) as alias

tell application "Finder"
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasDirPath
	set selection to aliasFilePath
end tell


------------------------------文字の置き換え
to doReplace(theText, orgStr, newStr)
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to orgStr
	set tmpList to every text item of theText
	set AppleScript's text item delimiters to newStr
	set tmpStr to tmpList as text
	set AppleScript's text item delimiters to oldDelim
	return tmpStr
end doReplace




