#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

##########################
## ディスクリスト
##########################
set listDiskName to {}

tell application "System Events"
	set listObjDisk to every disk as list
	repeat with objDisk in listObjDisk
		tell objDisk
			##ディスク名をリストに格納
			set srtDiskName to name
			copy "" & srtDiskName & "" to end of listDiskName
		end tell
	end repeat
end tell

##########################
## ダイアログ
##########################
set numCntDisk to (count of listDiskName) as integer
try
	set strDiskName to (choose from list listDiskName with title "ディスクの選択" with prompt "使用中のファイルリストを出力します" default items (item numCntDisk of listDiskName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if strDiskName is false then
	return
end if
###戻り値のディスクにコマンド実行
try
	set theComandText to ("/usr/sbin/lsof \"/Volumes/" & strDiskName & "\"") as text
	set strResponse to (do shell script theComandText) as text
on error
	set strResponse to "使用中のファイルはありませんでした"
end try
####戻り値を保存する
set strDateNo to doGetDateNo("yyyyMMddhhmmss")
set strFileName to strDateNo & ".txt" as text
set aliasTemporaryPath to path to temporary items from user domain as alias
set strFilePath to (POSIX path of aliasTemporaryPath) & strFileName as text
####テキストエディタで開く
tell application "TextEdit"
	activate
	make new document with properties {name:strFileName, path:strFilePath}
	tell document strFileName
		activate
		set its text to "使用中のファイルのパス\r" & strResponse
		save in (POSIX file strFilePath)
	end tell
end tell

###ファイル名用の日付時間連番
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
