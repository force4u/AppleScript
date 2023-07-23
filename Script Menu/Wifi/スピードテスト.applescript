#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###ダイアログを前面に出す
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
set strAlertMes to "処理が終わるまで３０秒ほどかかります" as text
display alert ("【処理を開始します】\r" & strAlertMes) buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 2

set strCommandText to "/usr/bin/networkQuality -s -v" as text
set strResponse to (do shell script strCommandText) as text
###改行でリスト化
set AppleScript's text item delimiters to "\r"
set listResponse to every text item of strResponse
set AppleScript's text item delimiters to ""
###出力初期化
set strOutPutText to "" as text
set strDownlink to "" as text
set strUplink to "" as text
###SUMMARY行以前は出力しない
set boolSUMMARY to false as boolean
###出力行の数だけ繰り返し
repeat with itemLineText in listResponse
	if itemLineText contains "=" then
		set boolSUMMARY to true as boolean
	end if
	if itemLineText starts with "Downlink bytes" then
		set strDownlink to itemLineText as text
	end if
	if itemLineText starts with "Uplink bytes" then
		set strUplink to itemLineText as text
	end if
	if boolSUMMARY is true then
		set strOutPutText to strOutPutText & itemLineText & "\r" as text
	end if
end repeat

###ダイアログへ戻す
set strMes to ("ネットワーク　スピードテスト\r" & strDownlink & "\r" & strUplink & "\r") as text
###表示用アイコン
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericNetworkIcon.icns" as alias
try
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
	set recordResult to (display dialog strMes with title "ネットワーク　スピードテスト" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return
end try
if true is equal to (gave up of recordResult) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResult) then
	set theResponse to (text returned of recordResult) as text
else if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
else
	return "キャンセル"
end if



