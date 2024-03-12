#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# LSSharedFileList を Plistに解凍します
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###################################
#####ファイル選択ダイアログ
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist") as text
set ocidDefaultLocationURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
set aliasDefaultLocation to (ocidDefaultLocationURL's absoluteURL()) as alias
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
set listUTI to {"public.item", "dyn.ah62d4rv4ge81g3xqgk", "dyn.ah62d4rv4ge81g3xqgq"} as list
set aliasFilePath to (choose file with prompt "sfl3ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
####入力ファイルパス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidPrefixName to ocidBaseFilePathURL's lastPathComponent()
###################################
#####保存先ダイアログ
###################################
###ファイル名
set strPrefixName to ocidPrefixName as text
###拡張子変える場合
set strFileExtension to "plist"
###ダイアログに出すファイル名
set strDefaultName to (strPrefixName & "." & strFileExtension) as text
set strPromptText to "名前を決めてください"
set strMesText to "名前を決めてください"
####
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias

####実在しない『はず』なのでas «class furl»で
set aliasSaveFilePath to (choose file name strMesText default location aliasDefaultLocation default name strDefaultName with prompt strPromptText) as «class furl»
####UNIXパス
set strSaveFilePath to POSIX path of aliasSaveFilePath as text
####ドキュメントのパスをNSString
set ocidSaveFilePath to refMe's NSString's stringWithString:strSaveFilePath
####ドキュメントのパスをNSURLに
set ocidSaveFilePathURL to refMe's NSURL's fileURLWithPath:ocidSaveFilePath
###拡張子取得
set strFileExtensionName to ocidSaveFilePathURL's pathExtension() as text
###ダイアログで拡張子を取っちゃった時対策
if strFileExtensionName is not strFileExtension then
	set ocidSaveFilePathURL to ocidSaveFilePathURL's URLByAppendingPathExtension:(strFileExtension)
end if

###################################
#####本処理
###################################
# NSDataに読み込んで
set ocidReadData to refMe's NSData's dataWithContentsOfURL:(ocidFilePathURL)
# unarchivedObjectOfClassで解凍する
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidReadData) |error|:(reference)
set ocidPlistDict to (item 1 of listResponse)
if ocidPlistDict = (missing value) then
	return "解凍に失敗しました"
end if
# 解凍したデータ＝DICTをPLISTで保存する
#XML形式
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
#NSPropertyListSerialization
set listResponst to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to (item 1 of listResponst)
#ファイル保存
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)

