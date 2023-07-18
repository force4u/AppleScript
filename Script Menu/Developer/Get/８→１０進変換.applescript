#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
set strDefaultAnswer to "666" as text

set strText to "777-->511\n775-->509\n770-->504\n755-->493\n750-->488\n700-->448\n644-->420"

try
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
	set recordResponse to (display dialog strText with title "３桁８進数を入力" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if

set strDec to doOct2Dec(strResponse) as text

try
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
	set recordResult to (display alert ("計算結果:" & strDec) buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" as informational giving up after 30)
on error
	log "エラーしました"
	return
end try

###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to strDec as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if

###################################
##	パーミッション　８進→１０進
##	Octal to Decimal
###################################

to doOct2Dec(argOctNo)
	set strOctalText to argOctNo as text
	set num3Line to (first item of strOctalText) as number
	set num2Line to (2nd item of strOctalText) as number
	set num1Line to (last item of strOctalText) as number
	set numDecimal to (num3Line * 64) + (num2Line * 8) + (num1Line * 1) as number
	return numDecimal as number
end doOct2Dec

