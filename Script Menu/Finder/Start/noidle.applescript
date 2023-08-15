#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#ダイアログで入力した分数だけスリープさせない
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

################################
######ダイアログ
################################
###初期値
set strDefaultAnswer to 120 as text

set aliasIconPath to POSIX file "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns" as alias
try
	set recordResponse to (display dialog "分入力=X分後(ex:120=2時間)にシャットダウン" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "キャンセルしました"
	return "キャンセルしました"
end if
###分換算
set intMin to strResponse as integer
set intSec to (intMin * 60) as integer
################################
######コマンド実行
################################
set strCommandText to ("/usr/bin/pmset noidle") as text
##do shell script strCommandText

####
tell application "Terminal" to launch
tell application "Terminal" to activate
## 実行中チェック
tell application "Terminal"
	set numCntWindow to (count of every window) as integer
end tell
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
	else if listProcess = {} then
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
	end if
end if

##############################
##　コマンド実行
tell application "Terminal"
	do script strCommandText in objNewWindow
end tell
##############################
##ダイアログの秒数待つ
delay intSec

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
				# tell front tab
				close saving no
				# end tell
			end tell
		end tell
		exit repeat
	else
		delay 1
	end if
end repeat
