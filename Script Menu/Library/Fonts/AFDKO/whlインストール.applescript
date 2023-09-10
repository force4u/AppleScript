#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDownloadsDirPathURL's absoluteURL()) as alias

############UTIリスト

set listUTI to {"public.item", "dyn.ah62d4rv4ge81s4dq"}
set strMes to ("PythonWheel(拡張子whl)ファイルを選んでください") as text
set strPrompt to ("PythonWheel(拡張子whl)ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
	
on error
	log "エラーしました"
	return "エラーしました"
end try

set strFilePath to (POSIX path of aliasFilePath) as text

############コマンド実行
###再インストール時はこちら
set strCommandText to ("python3 -m pip install  --force-reinstall --user \"" & strFilePath & "\"") as text
###通常はこちら
set strCommandText to ("python3 -m pip install --user \"" & strFilePath & "\"") as text

tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 1
	do script strCommandText in objWindowID
	(*
	delay 10
	do script "\n\n" in objWindowID
	do script "exit" in objWindowID
	set theWid to get the id of window 1
	delay 1
	close front window saving no
	*)
end tell
log "モジュールインストールの確認中　pip ok"

