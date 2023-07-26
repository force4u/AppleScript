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
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()

###アプリケーションのバンドルID
set strBundleID to "com.microsoft.edgemac"
###エラー処理
tell application id strBundleID
	set numWindow to (count of every window) as integer
end tell
if numWindow = 0 then
	return "Windowが無いので処理できません"
end if


###URLとタイトルを取得
tell application "Microsoft Edge"
	tell front window
		tell active tab
			activate
			set strURL to URL as text
			set strTITLE to title as text
		end tell
	end tell
end tell
##########################################
### ホスト名 -->保存先ディレクトリ名
##########################################
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set ocidHostName to ocidURL's |host|()

##########################################
### タイトル→ファイル名
##########################################
###Stringsに格納して
set ocidTITLE to refMe's NSString's stringWithString:(strTITLE)
set numTitleLength to ocidTITLE's |length|() as integer
###ファイル名は１４文字にする例
if numTitleLength ≤ 13 then
	set strBaseFileName to doGetDateNo("yyyyMMddhhmmss")
else
	set ocidRange to refMe's NSMakeRange(0, 14)
	set ocidBaseFileName to ocidTITLE's substringWithRange:(ocidRange)
	set strBaseFileName to ocidBaseFileName as text
end if
###ファイル名
set strSaveFileName to (strBaseFileName & ".pdf") as text
##########################################
#### アプリケーションのパス
##########################################

set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if
set ocidAppBinPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/MacOS/Microsoft Edge")
set strAppBinPath to ocidAppBinPathURL's |path|() as text

##########################
### PDF保存先
##########################
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(ocidHostName)
###保存先作っておく
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
##########################
### 　PDFファイル
##########################
set ocidPdfFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
set strPdfFilePath to ocidPdfFilePathURL's |path|() as text


##########################################
####PDFをプリント
##########################################
set strCommandText to ("\"" & strAppBinPath & "\"  --headless   --disable-gpu --print-to-pdf=\"" & strPdfFilePath & "\" \"" & strURL & "\" --margin=0  --no-header --no-footer --no-margins  --page-size=A4")
do shell script strCommandText

set aliasSaveDirPath to (ocidSaveDirPathURL's absoluteURL()) as alias
###Finderで開く
tell application "Finder"
	open aliasSaveDirPath
end tell
###プレビューで開く
tell application id "com.apple.Preview"
	open (POSIX file strPdfFilePath as alias)
end tell


##########################################
####日付情報の取得
##########################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
