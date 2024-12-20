#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　書き出す…からアプリケーションで書き出せば　ドロップレットとしても使えます
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

on run
	set strMes to "選択したフォルダをDMGイメージファイルに変換します。"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
end run



on open listAliasDirPath
	###エリアスの数だけ繰り返し
	repeat with itemAliasDirPath in listAliasDirPath
		###入力パス
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		###フォルダの名前
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		log recordFileInfo
		if (kind of recordFileInfo) is "フォルダ" then
			##そのまま処理
		else if (kind of recordFileInfo) is folder then
			##そのまま処理
		else
			log "ディレクトリ以外は処理しません"
			display alert "ディレクトリ以外は処理しません"
			return "ディレクトリ以外は処理しません"
			exit repeat
		end if
		return
		###選んだフォルダのコンテナ
		tell application "Finder"
			set aliasContainerDirPath to (container of aliasDirPath) as alias
		end tell
		###DMGの名前
		set strDirName to (strFolderName & ".dmg")
		###出力パス
		set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
		set strSaveFilePath to (strContainerDirPath & strDirName) as text
		###コマンド実行
		set strCommandText to ("hdiutil create -volname �"" & strFolderName & "�" -srcfolder �"" & strDirPath & "�" -ov -format UDRO �"" & strSaveFilePath & "�"") as text
		log strCommandText
		do shell script strCommandText
	end repeat
	
	###保存先を開く
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
end open



