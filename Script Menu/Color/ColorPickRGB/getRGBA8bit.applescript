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


#####RGB16bitColorに16bitRGB値を格納
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


set the listRGB16bitColor to (choose color default color {65535, 55535, 0, 1}) as list
log class of listRGB16bitColor
log listRGB16bitColor as list

##########Color Picker Value 16Bit
set numRcolor to item 1 of listRGB16bitColor as number
set numGcolor to item 2 of listRGB16bitColor as number
set numBcolor to item 3 of listRGB16bitColor as number
set numAcolor to 65535 as number

set intRcolor to ((numRcolor / 65535) * 255) as integer
set intGcolor to ((numGcolor / 65535) * 255) as integer
set intBcolor to ((numBcolor / 65535) * 255) as integer
set intAcolor to ((numAcolor / 65535) * 255) as integer


set strDisptext to ("rgba( " & intRcolor & ", " & intGcolor & ", " & intBcolor & ", 1);") as text
------ダイアログ表示用のテキスト
set strRGB8bitColor to ("R:" & intRcolor & " G:" & intGcolor & " B:" & intBcolor) as text
log strRGB8bitColor
##############################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Utilities/Digital Color Meter.app/Contents/Resources/AppIcon.icns" as alias
set strTitle to ("コードをコピーしてください") as text
set strMes to ("" & strRGB8bitColor & "　のRGBAColorが\n出来ました\nコピーして使って下さい。") as text
set recordResult to (display dialog strMes default answer the strDisptext with icon aliasIconPath with title strTitle buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" giving up after 20 without hidden answer) as record

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