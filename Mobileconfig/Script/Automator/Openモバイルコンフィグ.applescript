#!/usr/bin/env osascript
(*ワークフロー用です
単体では動作しません
以下をダウンロードして使ってください
https://quicktimer.cocolog-nifty.com/icefloe/files/openmobileconfigv2.zip
*)
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

on run {argAliasFilePath}
	##システム設定を終了させてから
	tell application id "com.apple.systempreferences" to quit
	delay 1
	##起動させる（macOS14だとこの方法でないと上手くいかない場合があるため）
	tell application id "com.apple.systempreferences" to activate
	tell application "System Settings" to activate
	##システム環境設定が開くのを待つ
	repeat
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
	## OPENコマンドで開く
	tell application "Finder"
		set strFilePath to POSIX path of argAliasFilePath
		set theCmdCom to ("open  \"" & strFilePath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
		do shell script theCmdCom
	end tell
	
end run
