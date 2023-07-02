#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


####ダイアログで使うデフォルトロケーション
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDirPath to container of aliasPathToMe as alias
	set aliasDefaultLocation to (folder "Mobileconfig" of folder aliasContainerDirPath) as alias
end tell

####UTIリスト PDFのみ
set listUTI to {"com.apple.mobileconfig"}

set strMes to ("モバイルコンフィグファイルを選んでください") as text
set strPrompt to ("モバイルコンフィグファイルを選んでください") as text

####ダイアログを出す
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
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to POSIX path of aliasFilePath

tell application "System Settings" to launch

--システム環境設定が開くのを待つ
repeat 10 times
	set doLaunchApp to get running of application "System Settings"
	if doLaunchApp is false then
		delay 0.5
	else
		exit repeat
	end if
end repeat
try
	set strCommandText to "open -b com.apple.systempreferences \"/System/Library/PreferencePanes/Profiles.prefPane\"" as text
	do shell script strCommandText
on error
	tell application id "com.apple.systempreferences"
		activate
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
	end tell
end try
repeat 10 times
	tell application id "com.apple.systempreferences"
		activate
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
		tell current pane
			set strPaneID to id as text
			properties
		end tell
	end tell
	if strPaneID is "com.apple.settings.PrivacySecurity.extension" then
		exit repeat
	else
		delay 0.5
	end if
end repeat

tell application "Finder"
	set theCmdCom to ("open  \"" & strFilePath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
	do shell script theCmdCom
end tell
delay 3
tell application id "com.apple.systempreferences"
	activate
end tell
