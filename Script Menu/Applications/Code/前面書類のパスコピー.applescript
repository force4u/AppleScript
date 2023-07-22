#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
###NSPasteboardはAppkitなので必須
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


################################
######ペーストボード初期化
################################
set the clipboard to "" as text
##初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
ocidPasteboard's clearContents()
delay 0.1
####パス取得を試みる
doCopyPathVsCode()
delay 0.1
################################
######ペーストボード取得
################################
##可変テキストとして受け取る
set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
##シングルARRAYが空ならペーストボードの中身が画像とか他のものなのでエラーで終了
if (count of ocidPasteboardArray) = 0 then
	delay 0.1
	###失敗したら再度トライ
	doCopyPathVsCode()
	delay 0.1
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
else
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
end if

if (strPasteboardStrings starts with "/") = false then
	###パスの取得に失敗したのでもう一度トライする
	delay 0.1
	####パス取得を試みる
	doCopyPathVsCode()
	delay 0.1
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
end if

set strPasteboardStrings to "'" & strPasteboardStrings & "'"
set the clipboard to strPasteboardStrings as text


################################
######パスコピーVScode
################################

to doCopyPathVsCode()
	###前面に出して
	tell application "System Events"
		launch
	end tell
	tell application "System Events"
		activate
	end tell
	tell application id "com.microsoft.VSCode"
		activate
	end tell
	delay 0.1
	###パス取得
	tell application "System Events"
		key down {command}
		keystroke "k"
		key up {command}
		delay 0.1
		key down {option, command}
		keystroke "c"
		key up {option, command}
	end tell
	
end doCopyPathVsCode
