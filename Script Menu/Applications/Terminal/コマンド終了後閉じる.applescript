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
		set strReadString to "COMMANDを入力" as text
	end if
end if
set aliasIconPath to (POSIX file "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns") as alias
try
	set objResponse to (display dialog "入力したコマンドをターミナルで実行します" with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 120 without hidden answer)
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
set strCommandText to theResponse as text
##############################
tell application "Terminal" to activate
delay 0.2
## 実行中チェック
tell application "Terminal"
	set numCntWindow to (count of every window) as integer
end tell
delay 0.5
if numCntWindow = 0 then
	log "Windowないので新規で作る"
	tell application "Terminal"
		set objNewWindow to (do script "\n")
	end tell
else
	log "Windowがある場合は、何か実行中か？をチェック"
	tell application "Terminal"
		tell front window
			tell front tab
				set boolTabStatus to busy as boolean
				set listProcess to processes as list
			end tell
		end tell
		set objNewWindow to selected tab of front window
	end tell
	###前面のタブがbusy＝実行中なら新規Window作る
	if boolTabStatus = true then
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
		###前面のタブにプロセスが無い場合=exit済みの場合は新規Window作る
	else if listProcess = {} then
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
	end if
end if
delay 0.5
##############################
##　コマンド実行
tell application "Terminal"
	do script strCommandText in objNewWindow
end tell
delay 1
log "コマンド実行中"

##############################
## コマンド終了チェック
(*
objNewWindowにWindowIDとTabIDが入っているので
objNewWindowに対してbusyを確認する事で
処理が終わっているか？がわかる
*)
## 無限ループ防止で１００回
repeat 100 times
	tell application "Terminal"
		set boolTabStatus to busy of objNewWindow
	end tell
	if boolTabStatus is false then
		log "コマンド処理終了しました"
		tell application "Terminal"
			tell front window
				tell front tab
					set listProcess to processes as list
				end tell
			end tell
		end tell
		set numCntProcess to (count of listProcess) as integer
		if numCntProcess ≤ 2 then
			exit repeat
		else
			delay 1
		end if
		--->このリピートを抜けて次の処理へ
	else if boolTabStatus is true then
		log "コマンド処理中"
		delay 1
		--->busyなのであと1秒まつ
	end if
end repeat
##############################
## control Cを送る
tell application "System Events"
	tell process "Terminal"
		keystroke "c" using {control down}
	end tell
end tell
##############################
## control Cを送る
tell application "System Events"
	tell process "Terminal"
		keystroke "c" using {control down}
	end tell
end tell

##############################
## exit打って終了
tell application "Terminal"
	do script "exit" in objNewWindow
end tell
##############################
## exitの処理待ちしてClose
repeat 20 times
	tell application "Terminal"
		tell front window
			tell front tab
				set listProcess to processes as list
			end tell
		end tell
	end tell
	if listProcess = {} then
		tell application "Terminal"
			tell front window
				#	tell front tab
				close saving no
				#	end tell
			end tell
		end tell
		exit repeat
	else
		delay 1
	end if
end repeat
