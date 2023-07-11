#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##############################
#####ダイアログを前面に出す
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if

##############################
#####フォルダ選択
##############################

set aliasDefaultLocation to (path to desktop folder) as alias
try
	set aliasFolderPath to (choose folder "フォルダを選んでください" with prompt "フォルダを選択してください" default location aliasDefaultLocation with invisibles and showing package contents without multiple selections allowed)
on error
	log "エラーしました"
	return
end try
set strFolderPath to (POSIX path of aliasFolderPath) as text

##############################
#####検索語句入力
##############################
set aliasIconPath to (POSIX file "/System/Applications/Preview.app/Contents/Resources/AppIcon.icns") as alias
set strDefaultAnswer to "*TEXT*" as text

try
	set recordResponse to (display dialog "検索語句" with title "検索語句" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 60 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if
##############################
#####コマンド実行
##############################
###コマンド整形
set strCommand to ("/usr/bin/find \"" & strFolderPath & "\" -name \"" & strResponse & "\" 2>/dev/null")

####ターミナルで開く
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 1
	do script strCommand in objWindowID
	delay 2
	close
end tell
