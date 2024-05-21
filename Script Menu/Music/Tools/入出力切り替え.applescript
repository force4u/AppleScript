#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
参考
https://www.macscripter.net/t/switchaudio-a-command-line-tool-to-change-the-audio-input-and-output-device/75630
バイナリーへの直リンク
https://klieme.ch/pub/SwitchAudio.dmg
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
#バイナリーへのパス
set strBinPath to ("~/bin/SwitchAudio/SwitchAudio") as text
set ocidBinPathStr to refMe's NSString's stringWithString:(strBinPath)
set ocidBinPath to ocidBinPathStr's stringByStandardizingPath()
#リスト取得
set strCommandText to ("\"" & ocidBinPath & "\"  -l") as text
set strResponse to (do shell script strCommandText) as text
#入出力でわける
set strDelim to AppleScript's text item delimiters
set AppleScript's text item delimiters to "\r\r"
set listResponse to every text item of strResponse as list
set AppleScript's text item delimiters to strDelim
#
set strResponeInput to (item 1 of listResponse) as text
set strResponeOutput to (item 2 of listResponse) as text
#個別項目へ
set strDelim to AppleScript's text item delimiters
set AppleScript's text item delimiters to "\r"
set listInput to every text item of strResponeInput as list
set listOutput to every text item of strResponeOutput as list
set listChooser to every text item of strResponse as list
set AppleScript's text item delimiters to strDelim
#ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strTitle to ("選んでください") as text
set strPrompt to ("切り替えるデバイスを選んでください") as text
try
	set listChoose to (choose from list listChooser with title strTitle with prompt strPrompt default items (item 2 of listChooser) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listChoose) is false then
	return "キャンセルしましたA"
else if (item 1 of listChoose) is "キャンセル" then
	return "キャンセルしましたB"
else
	set strChoose to (item 1 of listChoose) as text
end if
if strChoose is "Input Devices:" then
	log "デバイス以外を選択"
	doReload()
else if strChoose is "Output Devices:" then
	log "デバイス以外を選択"
	doReload()
else if strChoose is "" then
	log "デバイス以外を選択"
	doReload()
else if listInput contains strChoose then
	log "入力デバイスが選択されていました"
	set strCommandText to ("\"" & ocidBinPath & "\"  -i \"" & strChoose & "\"") as text
	try
		do shell script strCommandText
	end try
else if listOutput contains strChoose then
	log "出力デバイスが選択されていました"
	set strCommandText to ("\"" & ocidBinPath & "\"  -o \"" & strChoose & "\"") as text
	try
		do shell script strCommandText
	end try
end if


###デバイス以外を選択したら
to doReload()
	#自分自信を再実行
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe with parameters "再実行"
end doReload
