#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set strMes to "検索結果に入れたいフォルダを選択" as text
set aliasDefLoc to path to downloads folder from user domain as alias
set listResponce to (choose folder default location aliasDefLoc with prompt strMes with multiple selections allowed and invisibles without showing package contents) as list

###選択したフォルダの数だけ繰り返し
repeat with itemAliasDirPath in listResponce
	set strDirPath to (POSIX path of itemAliasDirPath) as text
	
	set theCommandText to ("/usr/bin/mdimport -i \"" & strDirPath & "\"") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script theCommandText in objWindowID
		delay 1
		do script "\n\n" in objWindowID
		delay 2
		do script "exit" in objWindowID
		delay 2
		close front window saving no
	end tell
	
end repeat


return "処理終了"
