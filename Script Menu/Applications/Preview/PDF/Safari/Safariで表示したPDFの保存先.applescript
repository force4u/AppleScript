#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
サファリで表示したPDFをプレビューで表示した時の保存先（テンポラリ）を開く
(テンポラリTディレクトリですので、再起動時に自動で削除されます）
WebKitPDFs-XXXXXX　と毎回フォルダ名が変わります
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidContainerDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:("com.apple.Safari") isDirectory:true
###コンテンツの収集
set listKeys to {(refMe's NSURLPathKey), (refMe's NSURLContentTypeKey)} as list
set ocidKeyArray to refMe's NSArray's alloc()'s initWithArray:(listKeys)
set listFileURLArray to appFileManager's contentsOfDirectoryAtURL:(ocidContainerDirPathURL) includingPropertiesForKeys:(ocidKeyArray) options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) |error|:(reference)
set ocidFileURLArray to (item 1 of listFileURLArray)

repeat with itemFileURLArray in ocidFileURLArray
	###フォルダ名がWebKitPDFsで始まるフォルダを見つけて
	set strDirName to (itemFileURLArray's lastPathComponent()) as text
	if strDirName starts with "WebKitPDFs" then
		log itemFileURLArray's |path|() as text
		set ocidPdfSaveDirPathURL to itemFileURLArray
	end if
end repeat
###Finderで開く
set aliasPdfSaveDirPath to (ocidPdfSaveDirPathURL's absoluteURL()) as alias
tell application id "com.apple.Finder"
	open folder aliasPdfSaveDirPath
end tell
