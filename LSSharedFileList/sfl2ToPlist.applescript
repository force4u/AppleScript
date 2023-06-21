#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
## https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-2c5c04.html
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application



###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist") as text
set ocidDefaultLocationURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
set aliasDefaultLocation to (ocidDefaultLocationURL's absoluteURL()) as alias
##############################
#####ダイアログを前面に出す
##############################
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
####ダイアログを出す
set listUTI to {"public.item", "dyn.ah62d4rv4ge81g3xqgk"} as list
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
####入力ファイルパス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###保存先
set ocidSaveFilePathURL to ocidFilePathURL's URLByAppendingPathExtension:"plist"
##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidFilePathURL)
###解凍してDictに
set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
###保存
set boolDone to ocidArchveDict's writeToURL:(ocidSaveFilePathURL) atomically:true
###保存したファイル
set aliasSaveFile to (ocidSaveFilePathURL's absoluteURL()) as alias

###ファインダーで選択
tell application "Finder"
	set objNewWindow to make new Finder window
	tell objNewWindow
		select aliasSaveFile
	end tell
	activate
end tell
