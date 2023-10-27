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


set the listRGB16bitColor to (choose color default color {65535, 55535, 0, 0}) as list
log class of listRGB16bitColor
log listRGB16bitColor as list

##########Color Picker Value 16Bit
set numRcolor16Bit to item 1 of listRGB16bitColor as number
set numGcolor16Bit to item 2 of listRGB16bitColor as number
set numBcolor16Bit to item 3 of listRGB16bitColor as number
set numAcolor16Bit to 65535 as number

set numRcolorFloat to numRcolor16Bit / 65535 as number
set numGcolorFloat to numGcolor16Bit / 65535 as number
set numBcolorFloat to numBcolor16Bit / 65535 as number
set numAcolorFloat to numAcolor16Bit / 65535 as number


set ocidRGBcolor to refMe's NSColor's colorWithDeviceRed:(numRcolorFloat) green:(numGcolorFloat) blue:(numBcolorFloat) alpha:(1)

set numH to ocidRGBcolor's hueComponent() as number
set numS to ocidRGBcolor's saturationComponent() as number
set numB to ocidRGBcolor's brightnessComponent() as number
(*
set numH to numH * 360 as integer
set numS to numS * 100 as integer
set numB to numB * 100 as integer
*)

set strDisptext to "colorWithDeviceHue:" & numH & " saturation:" & numS & " brightness:" & numB & " alpha:1" as text

------ダイアログ表示用のテキスト
set theRGB8bitColor to "R:" & numRcolorFloat & " G:" & numGcolorFloat & " B:" & numBcolorFloat as text
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
set strMes to ("" & theRGB8bitColor & "　のNSCOLORが\n出来ました\nコピーして使って下さい。") as text
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