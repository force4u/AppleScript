#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property objMe : a reference to current application

set listVolume to {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100}


try
	set objResponse to (choose from list listVolume with title "マイクボリューム" with prompt "マイクボリューム：選んでください" default items (item 1 of listVolume) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if

set numVolNo to (objResponse) as integer
log numVolNo



try
	tell application "System Events" to set volume input volume numVolNo
	
	
	display notification "マイクVolを" & numVolNo & "にしました" with title "処理終了" subtitle "マイクVolを" & numVolNo & "にしました" sound name "Sonumi"
	log ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
	return ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
on error
	display notification "エラーしました" with title "エラーしました" subtitle "エラーしました" sound name "Sonumi"
	log ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
	####エラーした場合はシステム環境設定を開く
	tell application "System Settings" to launch
	repeat
		try
			tell application "System Settings"
				set current pane to pane "com.apple.preference.sound"
				set thePaneID to id of current pane
			end tell
		on error
			delay 0.5
			tell application "System Settings"
				set thePaneID to id of current pane
			end tell
		end try
		if thePaneID is "com.apple.preference.sound" then
			exit repeat
		else
			delay 0.5
		end if
	end repeat
	
	--アンカーを指定する
	tell application "System Settings"
		tell current pane
			reveal anchor "input"
		end tell
	end tell
	
	return ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
end try





