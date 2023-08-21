#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 選択肢はVSCodeのCFBundleDocumentTypesから取得する方法
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()


set strBundleID to "com.microsoft.VSCode"

###################################
#####対象アプリの対応ContentTypesを取得
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppPathURL to appNSWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
#####CFBundleDocumentTypesの取得
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set ocidDocTypeArray to ocidPlistDict's objectForKey:"CFBundleDocumentTypes"
####リストにする
set listUTl to {} as list
repeat with itemDocTypeArray in ocidDocTypeArray
	set listContentTypes to (itemDocTypeArray's objectForKey:"LSItemContentTypes")
	if listContentTypes = (missing value) then
		set ocidExtensionArray to (itemDocTypeArray's objectForKey:"CFBundleTypeExtensions")
		repeat with itemExtensionArray in ocidExtensionArray
			set ocidContentTypes to (refMe's UTType's typeWithFilenameExtension:(itemExtensionArray))
			set strContentTypes to ocidContentTypes's identifier() as text
			set strContentTypes to ("" & strContentTypes & "") as text
			set end of listUTl to (strContentTypes)
		end repeat
	else
		repeat with itemContentTypes in listContentTypes
			set strContentTypes to ("" & itemContentTypes & "") as text
			set end of listUTl to (strContentTypes)
		end repeat
	end if
end repeat

###################################
#####入力ダイアログ
###################################
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
set ocidUserDesktopPathURLArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDesktopPathURL to ocidUserDesktopPathURLArray's firstObject()
set aliasDefaultLocation to (ocidUserDesktopPathURL's absoluteURL()) as alias
### set listUTI to {"public.png", "public.jpeg"}
set strPromptText to "ファイルを選んでください" as text
set strMesText to "ファイルを選んでください" as text
##
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTl with invisibles and showing package contents without multiple selections allowed) as list

set aliasFilePath to (item 1 of listAliasFilePath) as alias
set strFilePath to (POSIX path of aliasFilePath) as text


set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(strFilePath)
set ocidFilePathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidFilePathURLArray's insertObject:ocidFilePathURL atIndex:0

set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidOpenConfiguration's setActivates:(true as boolean)
ocidOpenConfiguration's setHides:(false as boolean)
ocidOpenConfiguration's setRequiresUniversalLinks:(false as boolean)
ocidOpenConfiguration's setCreatesNewApplicationInstance:(true as boolean)


set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppBundlePath to ocidAppBundle's bundlePath()
	set ocidAppPath to ocidAppBundlePath's stringByStandardizingPath
	set ocidAppPathURL to refNSURL's fileURLWithPath:(strAppPath)
else
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if

try
	set strCommandText to "/usr/bin/open \"vscode://file/" & strFilePaht & "\"" as text
	do shell script strCommandText
	log "Openコマンドで開きました"
on error
	appShardWorkspace's openURLs:(ocidFilePathURLArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfiguration) completionHandler:(missing value)
	log "NSWorkspaceで開きました"
end try
