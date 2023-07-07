#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

property strBundleID : "com.apple.ScriptEditor2" as text

set listSearchDir to {"homeDirectoryForUser", "homeDirectoryForCurrentUser", "temporaryDirectory"}

try
	###ダイアログを前面に出す
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
	set listResponse to (choose from list listSearchDir with title "選んでください" with prompt "URLsForDirectory" default items (item 1 of listSearchDir) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text

if strResponse is "homeDirectoryForUser" then
	set strInsertScript to "set appFileManager to refMe's NSFileManager's defaultManager()\rset ocidUserName to refMe's NSUserName()\rset ocidHomeDirURL to appFileManager's homeDirectoryForUser:(ocidUserName)" as text
else if strResponse is "homeDirectoryForCurrentUser" then
	set strInsertScript to "set appFileManager to refMe's NSFileManager's defaultManager()\rset ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()" as text
else if strResponse is "temporaryDirectory" then
	set strInsertScript to "set appFileManager to refMe's NSFileManager's defaultManager()\rset ocidTempDirURL to appFileManager's temporaryDirectory()" as text
end if




tell application id strBundleID
	tell the front document
		set strSelectedContents to the contents of selection
	end tell
end tell

set strSelectedContents to strSelectedContents & "\r" & strInsertScript & "\r" & "" as text

tell application id strBundleID
	tell the front document
		set contents of selection to strSelectedContents
		set selection to {}
	end tell
end tell
