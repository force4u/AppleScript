#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##############################
###現在の設定を調べる
set strCommandText to ("/usr/bin/defaults read NSGlobalDomain NSAppSleepDisabled -boolean") as text

set strCommandResponse to (do shell script strCommandText) as text
if strCommandResponse is "1" then
	set strPrompt to "現在：TRUE= NSAppSleepしない設定です" as text
	set numPosision to 1 as integer
	set listAppNapp to {"NSAppSleepをONにする", "NSAppSleepをOFFにする"}
else
	set strPrompt to "現在：FALSE= NSAppSleepする設定です" as text
	set numPosision to 1 as integer
	set listAppNapp to {"NSAppSleepをOFFにする", "NSAppSleepをONにする"}
end if

##############################
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
try
	set listResponse to (choose from list listAppNapp with title "選んでください" with prompt strPrompt default items (item numPosision of listAppNapp) OK button name "設定する" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
###戻り値で分岐
if strResponse is "NSAppSleepをONにする" then
	set strCommandText to ("/usr/bin/defaults write NSGlobalDomain NSAppSleepDisabled -boolean FALSE") as text
else if strResponse is "NSAppSleepをOFFにする" then
	set strCommandText to ("/usr/bin/defaults write NSGlobalDomain NSAppSleepDisabled -boolean TRUE") as text
end if
###設定変更する
set strCommandResponse to (do shell script strCommandText) as text
delay 1
try
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
end try
return



