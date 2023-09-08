#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#						
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application

##設定項目
set strPyFileName to "svg2pdf.py"

###パス取得
set aliasPathToMe to path to me as alias
tell application "Finder"
	set aliasPathToMeContainerDir to container of aliasPathToMe as alias
end tell
###パスを生成
set strPathToMeContainerDir to POSIX path of aliasPathToMeContainerDir as text
set strBinPath to strPathToMeContainerDir & "bin/" as text
set strPyPath to strBinPath & strPyFileName as text
####ダイアログ用デスクトップパス
set aliasDefaultLocation to path to desktop folder from user domain as alias
####ダイアログ
set listChooseFiles to (choose file with prompt "ファイルを選んでください" default location aliasDefaultLocation of type {"public.svg-image"} with multiple selections allowed without showing package contents and invisibles) as list

####ファイルの数だけ繰り返し
repeat with objFile in listChooseFiles
	###UNIXパスに変換	
	set theFilePath to POSIX path of objFile as text
	###スクリプトに渡す
	set strCommandText to "'" & strPyPath & "' '" & theFilePath & "'" as text
	do shell script strCommandText
	
end repeat

