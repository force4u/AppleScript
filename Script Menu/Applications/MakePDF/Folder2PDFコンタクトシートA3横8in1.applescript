#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.MakePDF") as text

####終了させてから処理させる
tell application id strBundleID
	quit
end tell
####半ゾンビ対策	
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat

####開く時の設定を書き換える
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidPlistFilePathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.apple.MakePDF.plist")
set ocidLayoutDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Application Support/Apple/MakePDF")
set ocidLayoutDirPath to ocidLayoutDirPathURL's |path|()
###PLIST読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
ocidPlistDict's setValue:(ocidLayoutDirPath) forKey:("lastOpenedDirectory")
###MakePDFlayout
set ocidLayoutDict to ocidPlistDict's objectForKey:("MakePDFlayout")
###設定
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:0) forKey:("defaultBorder")
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:0) forKey:("screenRes")
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithBool:false) forKey:("imagesGetCropped")
ocidLayoutDict's setValue:(refMe's NSString's stringWithString:("A3横8in1")) forKey:("layoutName")
##用紙サイズ
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:1191) forKey:("pageWidth")
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:842) forKey:("pageHeight")
##集約内容のコマサイズ
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:297) forKey:("defaultImageWide")
ocidLayoutDict's setValue:(refMe's NSNumber's numberWithInteger:421) forKey:("defaultImageHigh")
###保存
set boolDone to ocidPlistDict's writeToURL:(ocidPlistFilePathURL) atomically:true

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
###ダイアログを前面に出す
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

############
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
############
set strMes to "フォルダを選んでください" as text
set strPrompt to "フォルダを選択してください" as text
try
	set listAliasFolderPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation with multiple selections allowed without invisibles and showing package contents)
on error
	log "エラーしました"
	return "エラーしました"
end try


tell application id strBundleID to launch
tell application id strBundleID to activate


repeat with objAliasFolderPath in listAliasFolderPath
	set aliasFolderPath to objAliasFolderPath as alias
	
	tell application id strBundleID to open aliasFolderPath
	
end repeat



