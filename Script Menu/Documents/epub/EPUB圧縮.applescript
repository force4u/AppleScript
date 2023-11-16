#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


###Wクリックで起動した場合
on run
	set aliasDefaultLocation to (path to desktop from user domain) as alias
	set strPromptText to "編集済みEPUBフォルダをえらんでください"
	set strMesText to "編集済みEPUBフォルダをえらんでください"
	try
		set listFolderPath to (choose folder strMesText with prompt strPromptText default location aliasDefaultLocation with multiple selections allowed, invisibles and showing package contents) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	open listFolderPath
end run

###ドロップで起動した場合
on open listFolderPath
	tell application "Finder"
		set strKind to (kind of (item 1 of listFolderPath)) as text
	end tell
	if strKind is not "フォルダ" then
		return "フォルダ以外は処理しない"
	end if
	####構造ファイルの名称を取得する
	repeat with itemFolderPath in listFolderPath
		set aliasFolderPath to itemFolderPath as alias
		tell application "Finder"
			tell folder aliasFolderPath
				set listContentsAlias to name of every folder as list
				set strDirName to name as text
			end tell
			set aliasContainerDirPath to (container of aliasFolderPath) as alias
		end tell
		set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
		set strDirPath to (POSIX path of aliasFolderPath) as text
		set strCommandText to ("pushd \"" & strDirPath & "\"") as text
		log strCommandText
		do shell script strCommandText
		
		set strCommandText to ("pushd \"" & strDirPath & "\" && '/usr/bin/zip' -rX \"../" & strDirName & ".epub\" mimetype " & (item 1 of listContentsAlias as text) & "/  " & (item 2 of listContentsAlias as text) & "/ ") as text
		log strCommandText
		do shell script strCommandText
		
	end repeat
	
end open




