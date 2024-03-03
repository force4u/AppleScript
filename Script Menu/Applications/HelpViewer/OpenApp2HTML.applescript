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

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias

set strMes to ("アプリケーションを選んでください") as text
set strPrompt to ("アプリケーションを選んでください") as text
try
	
	set listUTI to {"com.apple.application-bundle"}
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles without multiple selections allowed and showing package contents) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
#
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
set ocidAppPlistFilePathURL to ocidFilePathURL's URLByAppendingPathComponent:("Contents/Info.plist")
#
set listAppPlistDict to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidAppPlistFilePathURL) |error|:(reference)
set ocidAppPlistDict to (item 1 of listAppPlistDict)
#
set ocidValue to (ocidAppPlistDict's valueForKey:("CFBundleHelpBookFolder"))
if ocidValue = (missing value) then
	return "ヘルプファイルはありません"
else
	set strValue to ocidValue as text
	set strSubPath to ("Contents/Resources/" & strValue) as text
	set ocidHelpFilePathURL to ocidFilePathURL's URLByAppendingPathComponent:(strSubPath)
end if
set ocidPlistFilePathURL to ocidHelpFilePathURL's URLByAppendingPathComponent:("Contents/Info.plist")
set listPlistDict to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference)
set ocidPlistDict to (item 1 of listPlistDict)
#
set ocidValue to (ocidPlistDict's valueForKey:("HPDBookAccessPath"))
if ocidValue = (missing value) then
	return "ヘルプファイルはありません"
else
	set strValue to ocidValue as text
end if
#
set ocidContentsDirPathURL to ocidHelpFilePathURL's URLByAppendingPathComponent:("Contents/Resources/")
#en.lproj
set strLangHtml to ("ja.lproj/" & strValue) as text
set ocidLangFilePathURL to ocidContentsDirPathURL's URLByAppendingPathComponent:(strLangHtml)
set ocidLangFilePath to ocidLangFilePathURL's |path|()

set boolFileExists to appFileManager's fileExistsAtPath:(ocidLangFilePath) isDirectory:(false)
if boolFileExists = true then
	log "ja.lprojがあります"
else if boolFileExists = false then
	log "ja.lprojがありません"
	set strLangHtml to ("en-US.lproj/" & strValue) as text
	set ocidLangFilePathURL to ocidContentsDirPathURL's URLByAppendingPathComponent:(strLangHtml)
	set ocidLangFilePath to ocidLangFilePathURL's |path|()
	set boolFileExists to appFileManager's fileExistsAtPath:(ocidLangFilePath) isDirectory:(false)
	if boolFileExists = true then
		log "en-US.lprojがあります"
	else if boolFileExists = false then
		log "en-US.lprojがありません"
		set strLangHtml to ("English.lproj/" & strValue) as text
		set ocidLangFilePathURL to ocidContentsDirPathURL's URLByAppendingPathComponent:(strLangHtml)
		set ocidLangFilePath to ocidLangFilePathURL's |path|()
		set boolFileExists to appFileManager's fileExistsAtPath:(ocidLangFilePath) isDirectory:(false)
		if boolFileExists = true then
			log "English.lprojがあります"
		else if boolFileExists = false then
			set strLangHtml to ("en.lproj/" & strValue) as text
			set ocidLangFilePathURL to ocidContentsDirPathURL's URLByAppendingPathComponent:(strLangHtml)
		end if
	end if
end if

set strLangFilePath to ocidLangFilePathURL's absoluteString() as text


tell application "Finder"
	open location strLangFilePath
end tell
