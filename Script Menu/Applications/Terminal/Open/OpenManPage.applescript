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
##############################
#####クリップボードの内容取得
##############################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	set strReadString to (the clipboard as text)
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "COMMAND" as text
	end if
end if
set aliasIconPath to (POSIX file "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns") as alias
try
	set objResponse to (display dialog "x-man-page://XXXXXXX\rコマンド名を入力してください" with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 10 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of objResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of objResponse) then
	set theResponse to (text returned of objResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if
##############################
## 実行するコマンド
set strURL to "x-man-page://" & theResponse & ""
##############################
tell application "Finder"
	open location strURL
end tell
