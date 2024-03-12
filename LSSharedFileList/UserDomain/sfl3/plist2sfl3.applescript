#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
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
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
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
set listUTI to {"com.apple.property-list"} as list
set aliasFilePath to (choose file with prompt "plistファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
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
set strFileExtension to "sfl3"
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
# DICTに読み込んで
set listResponse to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
set ocidReadData to (item 1 of listResponse)
#アーカイブする
#
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidReadData) requiringSecureCoding:(false) |error|:(reference)
set ocidSfl3Data to (item 1 of listResponse)
if ocidSfl3Data = (missing value) then
	return "アーカイブに失敗しました"
end if


#ファイル保存
set listDone to ocidSfl3Data's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)

