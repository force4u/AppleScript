#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
###こちらの初期設定は廃止
/Users/ユーザー名/Library/Preferences/com.apple.archiveutility.plist
###現在の初期設定は
/Users/ユーザー名/Library/Containers/com.apple.archiveutility/Data/Library/Preferences/com.apple.archiveutility.plist
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###zip圧縮設定するか？ true or false
set boolSetting to false as boolean


###UTI
set strBundleID to "com.apple.archiveutility" as text

if boolSetting is true then
	##終了させる
	tell application id strBundleID to quit
	
	#############################
	###設定変更
	#############################
	
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility dearchive-into -string \".\"") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility archive-info -string \".\"") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility dearchive-move-after -string \"~/.Trash\"") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility archive-move-after -string \".\"") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility archive-format -string  \"zip\"") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility dearchive-recursively  -boolean true") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility archive-reveal-after -boolean true") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults write com.apple.archiveutility dearchive-reveal-after -boolean true") as text
	do shell script strCommandText
	
	#####CFPreferencesを再起動させて変更後の値をロードさせる
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
end if

tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
set listUTI to {"public.item"}
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

tell application id strBundleID to open aliasFilePath

##終了させる
try
	tell application id strBundleID to quit
end try
return
