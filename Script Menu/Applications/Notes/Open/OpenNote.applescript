#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions



set listAccountName to {} as list

tell application "Notes"
	set listAccount to every account as list
	set numAccount to (count of listAccount) as number
	repeat with objAccount in listAccount
		tell objAccount
			set objAccountID to id
			set strAccountName to name as text
		end tell
		copy "" & strAccountName & "" to end of listAccountName
	end repeat
end tell

if listAccount is {} then
	return "アカウントがありません"
end if

#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

try
	set strTitle to ("アカウントを選択してください") as text
	set strPrompt to ("アカウントを選択してください") as text
	set objResponse to (choose from list listAccountName with title strTitle with prompt strPrompt default items (item 1 of listAccountName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set strAccount to objResponse as text


tell application "Notes"
	##	show account strAccount with separately
	tell account strAccount
		set listFolderName to name of every folder
	end tell
end tell
if listFolderName is {} then
	return "フォルダがありません"
end if
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strTitle to ("フォルダを選択してください") as text
	set strPrompt to ("フォルダを選択してください") as text
	set objResponse to (choose from list listFolderName with title strTitle with prompt strPrompt default items (item 1 of listFolderName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set strFolderName to objResponse as text
(*
tell application "Notes"
	##	show account strAccount with separately
	tell account strAccount
		show folder strFolderName with separately
		properties
		tell folder strFolderName
			properties
		end tell
	end tell
end tell
*)

tell application "Notes"
	##	show account strAccount with separately
	tell account strAccount
		tell folder strFolderName
			set listNoteName to name of every note
		end tell
	end tell
end tell

if listNoteName is {} then
	return "ノートがありません"
end if

#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strTitle to ("ノートを選択してください") as text
	set strPrompt to ("ノートを選択してください") as text
	set objResponse to (choose from list listNoteName with title strTitle with prompt strPrompt default items (item 1 of listNoteName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set strNoteName to objResponse as text



tell application "Notes"
	show account strAccount with separately
	tell account strAccount
		show with separately
		tell folder strFolderName
			show with separately
			##	show note strNoteName with separately
			tell note strNoteName
				#		show with separately
				##	show
			end tell
		end tell
	end tell
end tell
