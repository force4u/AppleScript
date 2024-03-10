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

set strBundleID to "com.apple.Safari" as text

###全面のタブのURLを取得して
tell application "Safari"
	set numCntWindow to (count of every document) as integer
	if numCntWindow = 0 then
		return "ウィンドウがありません"
	end if
end tell
tell application "Safari"
	set numID to id of front window
	set objTab to current tab of window id numID
	
	tell window id numID
		tell objTab
			set strURL to URL
		end tell
	end tell
end tell

set ocidURLStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLStr)
set ocidHost to ocidURL's |host|()
set strHost to ocidHost as text
set ocidURLStr to refMe's NSString's stringWithString:(strHost)
set ocidHostArray to ocidURLStr's componentsSeparatedByString:(".")
set ocidRevEnuArray to ocidHostArray's reverseObjectEnumerator()
set ocidRevArray to ocidRevEnuArray's allObjects()
set ocidRevHost to ocidRevArray's componentsJoinedByString:(".")
set strRevHost to ocidRevHost as text
set strHostName to (strHost & "\r" & strRevHost) as text
##############
set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
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
####ダイアログに指定アプリのアイコンを表示する
###アイコン名をPLISTから取得
set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
###ICONのURLにして
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
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
end if

set recordResult to (display dialog "前面WEBページ戻り値です" with title "bundle identifier" default answer strHostName buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

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


