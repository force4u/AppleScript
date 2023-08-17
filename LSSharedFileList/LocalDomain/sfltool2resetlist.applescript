#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#  要管理者権限
# 対象のSharedFileListをリセットします
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
#######################################
###リストを取得
#######################################
set strCommandText to ("/usr/bin/sfltool list") as text
set strSFTlist to (do shell script strCommandText) as text
###
set AppleScript's text item delimiters to "\r"
set listSFTlist to every text item of strSFTlist
set AppleScript's text item delimiters to ""
#######################################
###ダイアログを前面に出す
#######################################
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
	set listResponse to (choose from list listSFTlist with title "選んでください" with prompt "対象のSharedFileListをリセットします\r【要管理者権限】リセットには管理者権限が必要です" default items (item 1 of listSFTlist) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
#######################################
###リセット実行
#######################################
set strCommandText to ("/usr/bin/sfltool resetlist " & strResponse & "") as text
do shell script strCommandText



