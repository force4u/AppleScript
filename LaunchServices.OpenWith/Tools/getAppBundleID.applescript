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
set ocidUserApplicationDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserApplicationDirPathURL to ocidUserApplicationDirPathArray's firstObject()
set aliasApplicationDirPath to ocidUserApplicationDirPathURL's absoluteURL() as alias
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
set listUTI to {"com.apple.application-bundle"}
set strPromptText to "ファイルを選んで下さい。" as text
set strMesText to "bundle identifierを取得します" as text
set aliasFilePath to (choose file strMesText default location aliasApplicationDirPath with prompt strPromptText of type listUTI with invisibles without multiple selections allowed and showing package contents) as alias
try
	set aliasFilePath to result as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
if aliasFilePath is false then
	return "エラーしました"
end if

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
####UTIの取得
set ocidBunndle to refMe's NSBundle's bundleWithURL:(ocidFilePathURL)
set ocidBunndleID to ocidBunndle's bundleIdentifier()
set strBunndleID to (ocidBunndleID) as text
###missing value対策
if strBunndleID is "" then
	tell application "Finder"
		set objInfo to info for aliasFilePath
		set strBunndleID to bundle identifier of objInfo as text
	end tell
end if

####ダイアログに指定アプリのアイコンを表示する
###アイコン名をPLISTから取得
set ocidPlistPathURL to ocidFilePathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
###ICONのURLにして
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidFilePathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
###拡張子の有無チェック
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
##-->これがアイコンパス
log ocidIconFilePathURL's absoluteString() as text
###ICONファイルが実際にあるか？チェック
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
###ICONがみつかない時用にデフォルトを用意する
if boolExists is false then
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
else
	set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	set strIconPath to ocidIconFilePathURL's |path|() as text
end if

set strMes to ("bundle identifier 戻り値ですrIconPathr" & strIconPath) as text

set recordResult to (display dialog strMes with title "bundle identifier" default answer strBunndleID buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if

