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


set strDisptext to ""
set theRGB16bitColor to ""

set theRdec to ""
set theGdec to ""
set theBdec to ""
set theRhex to ""
set theGhex to ""
set theBhex to ""
set theOrigHEX to ""


set theOffsetX to ""
set theOffsetY to ""
set theBlurRadius to ""

set theOpenTag to ""
set theCloseTag to ""

-------RGB16bitColorに16bitRGB値を格納

set the theRGB16bitColor to (choose color default color {50, 50, 50})
log theRGB16bitColor
--------RGBに振り分け
set theRdec to (item 1 of theRGB16bitColor) / 256 div 1
set theGdec to (item 2 of theRGB16bitColor) / 256 div 1
set theBdec to (item 3 of theRGB16bitColor) / 256 div 1

------RGB毎の DEC値をHEX値に変換 ゼロサプレスしてから英字を大文字へ変換
set theRhex to do shell script "printf \"%02x\\n\" " & theRdec & " | tr \"a-z\" \"A-Z\"" as text
set theGhex to do shell script "printf \"%02x\\n\" " & theGdec & " | tr \"a-z\" \"A-Z\"" as text
set theBhex to do shell script "printf \"%02x\\n\" " & theBdec & " | tr \"a-z\" \"A-Z\"" as text

------＃を付けてHTML用のHEXカラーコードに
set strDisptext to "#" & theRhex & theGhex & theBhex

------RGBカラー値を整形
set theRGB8bitColor to "R:" & theRdec & " G:" & theGdec & " B:" & theBdec

##############################
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

-----------------ファインダ　アクティブ
activate
--------書き出し形式選択
set SetLabels to ¬
	{¬
		"[background-rgba]", ¬
		"[background#]", ¬
		"[background-color-rgba]", ¬
		"[background-color#]", ¬
		"[color-rgb]", ¬
		"[color-rgba]", ¬
		"[color#]", ¬
		"[box-shadow-rgba]", ¬
		"[box-shadow#]", ¬
		"[text-shadow-rgba]", ¬
		"[text-shadow#]", ¬
		"[border-color#]", ¬
		"[border-color-rgb]", ¬
		"[border-color-rgba]"}
set chooseResult to choose from list SetLabels with prompt "CSSを選んでください" with title "CSSを選んでください"



if chooseResult is {"[background-rgba]"} then
	set theBgCode to "background: rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theBgCode
else if chooseResult is {"[background#]"} then
	set theBgCodeHex to "background: " & strDisptext & ";"
	set strDisptext to theBgCodeHex
else if chooseResult is {"[background-color-rgba]"} then
	set theBgColorCode to "background-color: rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theBgColorCode
else if chooseResult is {"[background-color#]"} then
	set theBgColorCodeHex to "background-color: " & strDisptext & ";"
	set strDisptext to theBgColorCodeHex
else if chooseResult is {"[color-rgb]"} then
	set theColorCode to "color: rgba(" & theRdec & "," & theGdec & "," & theBdec & ");"
	set strDisptext to theColorCode
else if chooseResult is {"[color-rgba]"} then
	set theColorCode to "color: rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theColorCode
else if chooseResult is {"[color#]"} then
	set theColorCodeHex to "color: " & strDisptext & ";"
	set strDisptext to theColorCodeHex
else if chooseResult is {"[box-shadow-rgba]"} then
	set theBoxShadowColorCodeMoz to "-moz-box-shadow:  0px 0px 2px 0px rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);\n"
	set theBoxShadowColorCodeWebKit to "-webkit-box-shadow:  0px 0px 2px 0px rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);\n"
	set theBoxShadowColorCode to "box-shadow:  0px 0px 2px 0px rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theBoxShadowColorCodeMoz & theBoxShadowColorCodeWebKit & theBoxShadowColorCode
else if chooseResult is {"[box-shadow#]"} then
	set theBoxShadowColorCodeMozHex to "-moz-box-shadow:  0px 0px 2px 0px " & strDisptext & ";\n"
	set theBoxShadowColorCodeWebKitHex to "-webkit-box-shadow:  0px 0px 2px 0px " & strDisptext & ";\n"
	set theBoxShadowColorCodeHex to "box-shadow:  0px 0px 2px 0px " & strDisptext & ";"
	set strDisptext to theBoxShadowColorCodeMozHex & theBoxShadowColorCodeWebKitHex & theBoxShadowColorCodeHex
else if chooseResult is {"[text-shadow-rgba]"} then
	set theTextShadowColorCode to "text-shadow:  0px 0px 2px 0px rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theTextShadowColorCode
else if chooseResult is {"[text-shadow#]"} then
	set theTextShadowColorCodeHex to "text-shadow: " & strDisptext & ";"
	set strDisptext to theTextShadowColorCodeHex
else if chooseResult is {"[border-color#]"} then
	set theTexColorCode to "border-color: " & strDisptext & ";"
	set strDisptext to theTexColorCode
else if chooseResult is {"[border-color-rgb]"} then
	set theTexColorCode to "border-color: rgb(" & theRdec & "," & theGdec & "," & theBdec & ");"
	set strDisptext to theTexColorCode
else if chooseResult is {"[border-color-rgba]"} then
	set theTexColorCode to "border-color: rgba(" & theRdec & "," & theGdec & "," & theBdec & ", 1.0);"
	set strDisptext to theTexColorCode
	
end if
##############################
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

###ダイアログ
set aliasIconPath to POSIX file "/System/Applications/Utilities/Digital Color Meter.app/Contents/Resources/AppIcon.icns" as alias
set strTitle to ("コードをコピーしてください") as text
set strMes to ("" & theRGB8bitColor & "　のColorが\n出来ました\nコピーして使って下さい。") as text
set recordResult to (display dialog strMes default answer the strDisptext with icon aliasIconPath with title strTitle buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" giving up after 20 without hidden answer) as record
###クリップボードコピー
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

--------------------------------------------------#ここから文字の置き換え
to replace(theText, orgStr, newStr)
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to orgStr
	set tmpList to every text item of theText
	set AppleScript's text item delimiters to newStr
	set tmpStr to tmpList as text
	set AppleScript's text item delimiters to oldDelim
	return tmpStr
end replace