#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#改行に<BR />を挿入する
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("jp.co.artman21.JeditOmega") as text

##	set strBrCode to ("<br />") as text
set strBrCode to ("<br>") as text

########################################
### エラー制御
########################################

tell application id strBundleID
	set numCntOpenDoc to (count document) as integer
end tell
if numCntOpenDoc = 0 then
	set aliasIconPath to doGetIconPath(strBundleID)
	###ダイアログ
	#####ダイアログを前面に
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set strMes to "ドキュメントを開いていません"
	set strTitle to "エラー"
	display dialog strMes with title strTitle buttons {"OK"} default button "OK" giving up after 1 with icon aliasIconPath without hidden answer
	return strMes
end if
###選択中のテキスト格納
tell front document of application "Jedit Ω"
	activate
	set strSelectedText to selected text
end tell

set AppleScript's text item delimiters to "\n"
set listSelectedText to every text item of strSelectedText
set AppleScript's text item delimiters to ""

set strOutPutText to "" as text

repeat with itemSelectedText in listSelectedText
	set strOutPutText to (strOutPutText & itemSelectedText & "<br>") as text
	
end repeat


###選択中のテキストに日付を加えて戻す
tell front document of application "Jedit Ω"
	activate
	set selected text to strOutPutText
end tell




########################################
### アイコンパス
########################################
to doGetIconPath(argBundleID)
	##初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのインストール先を求める
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id argBundleID) as alias
				set strAppPath to POSIX path of aliasAppApth as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
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
	###ICONファイルが実際にあるか？チェック
	set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
	###ICONがみつかない時用にデフォルトを用意する
	if boolExists is false then
		set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
	else
		set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	end if
	return aliasIconPath as alias
end doGetIconPath
