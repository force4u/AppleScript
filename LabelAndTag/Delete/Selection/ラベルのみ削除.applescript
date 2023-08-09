#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###########################
#　処理するのは選択中の項目
###########################
tell application "Finder"
	###選択中のファイルパス
	set listAliasFilePath to selection as list
	###数を数えて
	set numCntSelection to (count of listAliasFilePath) as integer
	###選択中の数が0なら処理終了
	if numCntSelection = 0 then
		return "未選択:処理終了"
	end if
end tell


###########################
# 選択中の項目を順番に処理する
###########################
(* Finderラベル
１:ピンク
２:レッド
３:イエロー
４:ブルー
５:パープル
６:グリーン
７:グレー
０:無し
*)
repeat with itemAliasFilePath in listAliasFilePath
	tell application "Finder"
		set label index of itemAliasFilePath to 0
	end tell
end repeat

