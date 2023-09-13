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
set strDefaultAnswer to "504" as text

set strText to "511-->777n509-->775n504-->770n493-->755n488-->750n448-->700n420-->644"

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
	set recordResponse to (display dialog strText with title "３桁１０進数を入力" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
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

set strOct to doDec2Oct(strResponse) as text

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
	set recordResult to (display alert ("計算結果:" & strOct) buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" as informational giving up after 30)
on error
	log "エラーしました"
	return
end try

###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to strOct as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if


###################################
##	パーミッション１０進数 →８進数  　
##	Decimal to Octal
###################################
to doDec2Oct(argDecNo)
	set numDecNo to argDecNo as number
	set numDiv1 to (numDecNo div 8) as number
	set numMod1 to (numDecNo mod 8) as number
	set numDiv2 to (numDiv1 div 8) as number
	set numMod2 to (numDiv1 mod 8) as number
	set numDiv3 to (numDiv2 div 8) as number
	set numMod3 to (numDiv2 mod 8) as number
	set strOctal to (numMod3 & numMod2 & numMod1) as text
	set numOctal to strOctal as number
	return numOctal as number
	
end doDec2Oct



