#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()


###################################
#####入力フォルダ
###################################
set ocidHomeDirUrl to appFileManager's homeDirectoryForCurrentUser()
set ocidSauceDirPathURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/Scripts"
set strSauceDirPath to (ocidSauceDirPathURL's |path|()) as text
###################################
#####コピー先フォルダ
###################################
set ocidDistDirPathURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/CloudStorage/Dropbox/Scripts"
set strDistDirPath to (ocidDistDirPathURL's |path|()) as text

###################################
#####コマンド実行
###################################

set strCommandText to "/usr/bin/ditto \"" & strSauceDirPath & "\" \"" & strDistDirPath & "\"" as text
try
	set strResponse to (do shell script strCommandText) as text
on error strResponse
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
	set aliasIconPath to POSIX file "/Applications/Dropbox.app/Contents/Resources/AppIcon.icns" as alias
	display dialog "一部エラーが発生しました\r確認してください" with title "エラーメッセージ" default answer strResponse buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer
end try


