#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
 com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##############################
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
###RGB16bitColorに16bitRGB値を格納
tell application "Finder"
	activate
	set the listRGB16bitColor to (choose color default color {65535, 46805, 17486}) as list
end tell
log listRGB16bitColor

###リスト形式で取得したカラー値をRGBに振り分け
set theR16bit to (item 1 of listRGB16bitColor) as text
set theG16bit to (item 2 of listRGB16bitColor) as text
set theB16bit to (item 3 of listRGB16bitColor) as text

###AppleScript利用時のカラー値に整形
set theDisptext to "{" & theR16bit & "," & theG16bit & "," & theB16bit & "}" as text

tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set recordResult to (display dialog "RGB:" & theDisptext & "　の16bitColorが\n出来ました\nコピーして使って下さい。" default answer the theDisptext with icon 1 with title "コードをコピーしてください" default button 1 buttons {"クリップボードにコピー", "OK", "キャンセル"}) as record

tell application "Finder"
	if button returned of recordResult is "クリップボードにコピー" then
		set the clipboard to theDisptext
	end if
end tell