#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###イジェクトメニュー有効化
set strFilePath to ("/System/Library/CoreServices/Menu Extras/Eject.menu") as text
tell application "Finder"
	set aliasFilePath to POSIX file strFilePath as alias
	open aliasFilePath
end tell


######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.systemuiserver.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###すでに設定済みか？チェック　項目名にスペースがある場合はシングルクオトに入れる
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:'NSStatusItem Visible com.apple.menuextra.eject'\" \"" & strFilePath & "\"") as text
try
	set boolChk to (do shell script strCommandText) as boolean
on error
	##エラーしたら項目が無いって事なので判定用のあたいを入れておく
	set boolChk to false as boolean
end try
###設定されていなければ設定する
if boolChk is not true then
	set strBoolNo to "1" as text
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Add:'NSStatusItem Visible com.apple.menuextra.eject'  bool true\"  \"" & strFilePath & "\"") as text
	log strCommandText
	do shell script strCommandText
end if


######################################################
tell application "Finder"
	set aliasPreferencesDirPath to (path to preferences folder from user domain) as alias
	set strFileName to "com.apple.systemuiserver.plist" as text
	set aliasFilePath to (file strFileName of folder aliasPreferencesDirPath) as alias
end tell
set strFilePath to (POSIX path of aliasFilePath) as text
###すでに設定済みか？チェック
set strCommandText to ("/usr/libexec/PlistBuddy -c \"Print:menuExtras:\"  \"" & strFilePath & "\"") as text
try
	set strResponseArray to (do shell script strCommandText) as text
on error
	##エラーしたら項目が無いって事なので判定用のあたいを入れておく
	set strResponseArray to "Eject.menu" as text
end try
###設定されていなければ設定する  (Array形式なのでADDする)
if strResponseArray does not contain "Eject.menu" then
	set strMenuExtras to "/System/Library/CoreServices/Menu Extras/Eject.menu" as text
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"add:menuExtras:0 string '" & strMenuExtras & "'\"  \"" & strFilePath & "\"") as text
	log strCommandText
	do shell script strCommandText
end if


