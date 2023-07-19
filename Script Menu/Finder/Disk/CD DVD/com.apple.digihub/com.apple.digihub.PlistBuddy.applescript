#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.digihub.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###設定内容チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:com.apple.digihub.blank.cd.appeared:action\"  \"" & strFilePath & "\"") as text
log strCommandText
try
	set numResponse to (do shell script strCommandText) as text
on error
	set numResponse to "0" as text
	###DICTを作って
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.blank.cd.appeared dict\"  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end try
	###値のタイプを確定（この場合はinteger)
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.blank.cd.appeared:action integer\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end try
if numResponse is not "100" then
	###値を入れる
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:com.apple.digihub.blank.cd.appeared:action 100\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end if




######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.digihub.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###設定内容チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:com.apple.digihub.blank.dvd.appeared:action\"  \"" & strFilePath & "\"") as text
log strCommandText
try
	set numResponse to (do shell script strCommandText) as text
on error
	set numResponse to "0" as text
	###DICTを作って
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.blank.dvd.appeared dict\"  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end try
	###値のタイプを確定（この場合はinteger)
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.blank.dvd.appeared:action integer\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end try
if numResponse is not "100" then
	###値を入れる
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:com.apple.digihub.blank.dvd.appeared:action 100\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end if


######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.digihub.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###設定内容チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:com.apple.digihub.cd.music.appeared:action\"  \"" & strFilePath & "\"") as text
log strCommandText
try
	set numResponse to (do shell script strCommandText) as text
on error
	set numResponse to "0" as text
	###DICTを作って
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.cd.music.appeared dict\"  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end try
	###値のタイプを確定（この場合はinteger)
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.cd.music.appeared:action integer\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end try
if numResponse is not "1" then
	###値を入れる
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:com.apple.digihub.cd.music.appeared:action 1\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end if



######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.digihub.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###設定内容チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:com.apple.digihub.cd.picture.appeared:action\"  \"" & strFilePath & "\"") as text
log strCommandText
try
	set numResponse to (do shell script strCommandText) as text
on error
	set numResponse to "0" as text
	###DICTを作って
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.cd.picture.appeared dict\"  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end try
	###値のタイプを確定（この場合はinteger)
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.cd.picture.appeared:action integer\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end try
if numResponse is not "1" then
	###値を入れる
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:com.apple.digihub.cd.picture.appeared:action 1\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end if

######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.digihub.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###設定内容チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:com.apple.digihub.dvd.video.appeared:action\"  \"" & strFilePath & "\"") as text
log strCommandText
try
	set numResponse to (do shell script strCommandText) as text
on error
	set numResponse to "0" as text
	###DICTを作って
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.dvd.video.appeared dict\"  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end try
	###値のタイプを確定（この場合はinteger)
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:com.apple.digihub.dvd.video.appeared:action integer\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end try
if numResponse is not "1" then
	###値を入れる
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:com.apple.digihub.dvd.video.appeared:action 1\"  \"" & strFilePath & "\"") as text
	do shell script strCommandText
end if


##最後に保存
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Save\"  \"" & strFilePath & "\"") as text
do shell script strCommandText



