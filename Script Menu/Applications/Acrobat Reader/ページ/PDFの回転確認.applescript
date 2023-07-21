#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

## 		"com.adobe.Acrobat.Pro" 
##		"com.adobe.Reader" 


tell application id "com.adobe.Reader"
	#開いているファイル
	set objFile to active doc
	#active docの名前
	set theFileName to name of objFile
	#active docのファイルパス（エイリアス）
	set theFileNPath to file alias of objFile
	#active docのページ数
	set numAllPageNo to (count objFile each page)
	set numAllPageNo to (number of pages)
	tell PDF Window 1
		set numSelectedPage to page number as number
		tell page numSelectedPage
			set numRotation to rotation as number
		end tell
	end tell
##	do script ("this.removeThumbnails();")
end tell
if numRotation = 0 then
	set theResponse to "回転：0\n　OK\n上部が天、下部が地です。" as text
else if numRotation = 90 then
	set theResponse to "右回転：90\n　NG \n右が天、左が地です。" as text
else if numRotation = 180 then
	set theResponse to "右回転：180\n　NG \n下部が天、上部が地です。" as text
else if numRotation = 270 then
	set theResponse to "右回転：270\n　NG \n左が天、右が地です。" as text
end if
try
	set objResponse to (display alert ("結果:" & theResponse) buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10)
on error
	log "エラーしました"
	return
end try


