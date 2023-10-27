#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#https://github.com/sindresorhus/System-Color-Picker
#を起動用です
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set listAppName to {"Color Picker", "ColorSyncユーティリティ", "Digital Color Meter", "ディスプレイキャリブレータ", "ディスプレイ設定"} as list
try
	set objResponse to (choose from list listAppName with title "選んでください" with prompt "選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set theResponse to (objResponse) as text
log theResponse
###戻り値がリストのX番目なのか？を調べる
set numCntLength to 1 as number
repeat with itemAppName in listAppName
	log itemAppName
	if (itemAppName as text) is theResponse then
		set numListCnt to numCntLength
	end if
	set numCntLength to numCntLength + 1 as number
end repeat
log numListCnt

set listUTI to {"com.sindresorhus.Color-Picker", "com.apple.ColorSyncUtility", "com.apple.DigitalColorMeter", "com.apple.ColorSyncCalibrator", "com.apple.preference.displays"} as list
###リストのX番目まではアプリ
if numListCnt ≤ 4 then
	####アプリを開く
	set strUTI to item numListCnt of listUTI
	tell (application id strUTI) to launch
	####X番目はシステム設定
else if numListCnt = 5 then
	###システム設定（ディスプレイ）を開く
	set strCommandText to "open -b com.apple.systempreferences \"/System/Library/PreferencePanes/Displays.prefPane\"" as text
	do shell script strCommandText
end if
