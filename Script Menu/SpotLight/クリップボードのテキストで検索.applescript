#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

####デフォルトの値にクリップボードの中身を使う
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to appPasteboard's types
###ペーストボードのタイプにテキスト形式があればその値を使う
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###プレインテキストで受け取る
	set strClipText to (the clipboard as text)
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		###プレインテキストにして受け取る
		set ocidReadString to appPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strClipText to ocidReadString as text
	else
		####テキスト形式がなかった場合のデフォルト値
		set strClipText to "" as text
	end if
end if

set ocidClipText to refMe's NSString's stringWithString:(strClipText)
set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
ocidSharedWorkspace's showSearchResultsForQueryString:(ocidClipText)

