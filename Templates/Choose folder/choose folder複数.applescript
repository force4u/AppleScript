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

repeat with objAliasFolderPath in listAliasFolderPath
	set aliasFolderPath to objAliasFolderPath as alias
	
	log aliasFolderPath
end repeat

