#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####システム設定を終了させる
try
	tell application id "com.apple.systempreferences" to quit
	tell application "System Settings" to quit
on error
	tell application "System Settings"
		activate
		tell application "System Events"
			tell process "System Settings"
				key code 53
			end tell
		end tell
	end tell
	delay 2
	
	tell application id "com.apple.systempreferences" to quit
end try

####必要なフォルダを作っておく
set aliasLibraryFolder to the path to library folder from user domain as alias
set strLibraryFolder to (POSIX path of aliasLibraryFolder) as text
set theComandText to ("/bin/mkdir -p \"" & strLibraryFolder & "Dictionaries/CoreDataUbiquitySupport\"") as text
do shell script theComandText
set theComandText to ("/bin/mkdir -p \"" & strLibraryFolder & "Dictionaries/JapaneseInputMethod\"") as text
do shell script theComandText
set theComandText to ("/bin/mkdir -p \"" & strLibraryFolder & "Spelling\"") as text
do shell script theComandText
set theComandText to ("/bin/mkdir -p \"$HOME/Documents/Apple/UserDictionary\"") as text
do shell script theComandText

try
	tell application id "com.apple.systempreferences" to launch
	tell application id "com.apple.systempreferences" to activate
on error
	tell application "System Settings" to launch
	tell application "System Settings" to activate
end try

--システム環境設定が開くのを待つ
repeat
	set doLaunchApp to get running of application "System Settings"
	if doLaunchApp is false then
		delay 0.5
	else
		exit repeat
	end if
end repeat

--com.apple.systempreferences

tell application id "com.apple.finder"
	open location "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?TextReplacements"
end tell

--アンカーを指定する
tell application id "com.apple.systempreferences"
	activate
	reveal anchor "TextReplacements" of pane id "com.apple.Keyboard-Settings.extension"
end tell
tell application "System Settings"
	activate
	tell application "System Events"
		tell process "System Settings"
			key code 53
		end tell
	end tell
end tell

tell application "System Settings"
	activate
	tell application "System Events"
		tell process "System Settings"
			click button 2 of group 3 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "キーボード"
		end tell
	end tell
end tell

tell application "System Settings"
	activate
end tell
delay 1
tell application "System Settings"
	tell application "System Events"
		tell process "System Settings"
			select scroll area 1 of group 1 of scroll area 1 of group 1 of sheet 1 of window "キーボード"
			keystroke "a" using command down
		end tell
	end tell
end tell

delay 1
tell application "System Settings"
	
	tell application "System Events"
		tell process "System Settings"
			keystroke "a" using command down
		end tell
	end tell
end tell
delay 1

tell application "System Settings"
	activate
	tell application "System Events"
		tell process "System Settings"
			set objSelect to select table 1 of scroll area 1 of group 1 of scroll area 1 of group 1 of sheet 1 of window "キーボード"
			tell objSelect
				perform action "AXShowMenu"
			end tell
		end tell
	end tell
end tell
