#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

(*
anchor "scan"
anchor "fax"
anchor "print"
anchor "share"
*)

###システム設定を開いて
tell application "System Settings" to launch
###起動確認１０秒
repeat 10 times
	tell application "System Settings" to activate
	###前面のアプリケーション
	tell application "System Events"
		set strAppName to (name of first application process whose frontmost is true) as text
	end tell
	####起動確認できたら抜ける
	if strAppName is "System Settings" then
		exit repeat
	else
		###起動に時間がかかっている場合は１秒まつ
		delay 1
	end if
end repeat

####パネルオープン確認
tell application "System Settings"
	activate
	repeat 10 times
		####ウィンドウの名前を取得する
		set strWindowName to (name of front window) as text
		###取得できなかったら１秒待つ
		if strWindowName is "" then
			delay 1
			###取得できたらリピート抜ける
		else if strWindowName is "外観" then
			exit repeat
			###すでに起動済みで外観以外を開いている場合
		else
			exit repeat
		end if
	end repeat
end tell

tell application "System Settings"
	set boolDone to reveal anchor "print" of pane id "com.apple.Print-Scan-Settings.extension"
end tell

if boolDone = (missing value) then
	return "open終了"
end if

tell application "System Settings" to activate
####パネルオープン確認
tell application "System Settings"
	###起動確認　最大１０秒
	repeat 10 times
		activate
		####ウィンドウの名前を取得する
		set strWindowName to (name of front window) as text
		###取得できなかったら１秒待つ
		if strWindowName is "" then
			delay 1
			###取得できたらリピート抜ける
		else if strWindowName is "プリンタとスキャナ" then
			exit repeat
			###すでに起動済みで外観以外を開いている場合
		else
			delay 1
		end if
	end repeat
end tell

