#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strCommandText to "/usr/bin/sudo /usr/bin/killall coreaudiod"
do shell script strCommandText with administrator privileges

(*
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 2
	do script strCommandText in objWindowID
	delay 2
	do script strPassWord in objWindowID
	delay 2
	do script "\n" in objWindowID
end tell

(*
objWindowIDにWindowIDとTabIDが入っているので
objWindowIDに対してbusyを確認する事で
処理が終わっているか？がわかる
*)

repeat
	tell application "Terminal"
		set boolTabStatus to busy of objWindowID
	end tell
	if boolTabStatus is false then
		exit repeat
		--->このリピートを抜けて次の処理へ
	else if boolTabStatus is true then
		delay 3
		--->busyなのであと３秒まつ
	end if
end repeat

tell application "Terminal"
	launch
	activate
	do script "exit" in objWindowID
	delay 10
	tell window id numWindowID
		try
			close
		end try
	end tell
	
end tell

tell application "Terminal" to close (get window 1)

*)
