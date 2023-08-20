#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###フォルダ名
set strFolderName to "サンプルフォルダ" as text

tell application "Finder"
	####デスクトップ
	set aliasUserDesktopDir to (path to desktop folder from user domain) as alias
	####同名のフォルダがあるか？確かめる
	set boolFolderExists to (exists of (folder strFolderName of folder aliasUserDesktopDir)) as boolean
	####なければ作る
	if boolFolderExists is false then
		make new folder at aliasUserDesktopDir with properties {name:strFolderName, owner privileges:"read write", group privileges:"read write", everyones privileges:"read write", comment:"このフォルダは削除しても大丈夫です", description:"スクリプトが生成したフォルダです削除しても大丈夫です", label index:3}
		####パスを取得しておく
		set aliasNewFolderDir to folder strFolderName of folder aliasUserDesktopDir as alias
	else
		###すでに指定のフォルダ名がある場合は『スペース 連番』形式に名称を変更する
		###最大１００まで繰り返す
		repeat with itemIntNo from 2 to 100 by 1
			###指定のフォルダ名＋連番
			set strSameFolderName to (strFolderName & " " & itemIntNo) as text
			###指定のフォルダ名＋連番の同名のフォルダがあるか？確かめる
			set boolSameFoldeName to (exists of (folder strSameFolderName of folder aliasUserDesktopDir)) as boolean
			###なければ作り
			if boolSameFoldeName is false then
				make new folder at aliasUserDesktopDir with properties {name:strSameFolderName, owner privileges:"read write", group privileges:"read write", everyones privileges:"read write", comment:"このフォルダは削除しても大丈夫です", description:"スクリプトが生成したフォルダです削除しても大丈夫です", label index:3}
				###リピートを抜ける
				exit repeat
			end if
		end repeat
		####パスを取得しておく
		set aliasNewFolderDir to folder strSameFolderName of folder aliasUserDesktopDir as alias
	end if
end tell
