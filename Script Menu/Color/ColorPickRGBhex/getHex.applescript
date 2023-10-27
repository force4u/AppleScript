#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set listRGBValues to (choose color default color {255, 255, 255}) as list

set hexValue to (convertRGBColorToHexValue(listRGBValues))


#####ダイアログを前面に
##############################
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set recordResult to (display dialog "RGB:" & listRGBValues & "　のHEXカラーが\n出来ました\nコピーして使って下さい。" default answer the hexValue with icon 1 with title "コードをコピーしてください" buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 without hidden answer) as record


if button returned of recordResult is "クリップボードにコピー" then
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
end if


on convertRGBColorToHexValue(listRGBValues)
	set listHexList to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set strHexList to ""
	repeat with a from 1 to count of listRGBValues
		set numCurrentRGBValue to (item a of listRGBValues) div 256
		if numCurrentRGBValue is 256 then set numCurrentRGBValue to 255
		set numFirstItem to item ((numCurrentRGBValue div 16) + 1) of listHexList
		log numFirstItem
		
		set numSecondItem to item (((numCurrentRGBValue / 16 mod 1) * 16) + 1) of listHexList
		set strHexList to (strHexList & numFirstItem & numSecondItem) as string
	end repeat
	return (strHexList) as string
end convertRGBColorToHexValue