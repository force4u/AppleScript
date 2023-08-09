#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


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
(* NSURLLabelNumberKey
0:ラベル無し
1:グレイ
2:グリーン
3:パープル
4:ブルー
5:イエロー
6:レッド
7:オレンジ
*)
repeat with itemAliasFilePath in listAliasFilePath
	###パス
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	
	set listResult to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
	if (item 1 of listResult) is false then
		return "ラベル取得に失敗しました"
	else
		set ocidLabelNumber to (item 2 of listResult)
		if ocidLabelNumber = (missing value) then
			log "ラベル指定不明"
			###ラベル番号０を入れる＝ラベル無し
			set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
			set listDone to (ocidFilePathURL's setResourceValue:(ocidIntValue) forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
		else if ocidLabelNumber = 0 then
			log "ラベル指定無し"
		else
			###ラベル番号０を入れる＝ラベル無し
			set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
			set listDone to (ocidFilePathURL's setResourceValue:(ocidIntValue) forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
		end if
	end if
	############################
	####次にタグネームに空のリストを入れる
	############################
	
	set listResult to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
	if (item 1 of listResult) is false then
		return "取得に失敗しました"
	else
		set ocidTagNames to (item 2 of listResult)
		if ocidTagNames is (missing value) then
			log "タグ指定無し"
		else
			###タグネーム＝リスト形式　を空のリストで埋める＝タグ無し
			set ocidArrayValue to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
			set listDone to (ocidFilePathURL's setResourceValue:(ocidArrayValue) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		end if
	end if
end repeat


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
