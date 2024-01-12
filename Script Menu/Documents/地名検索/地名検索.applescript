#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
シンプル ジオコーディング 
東京大学空間情報科学研究のAPIを利用しています
https://geocode.csis.u-tokyo.ac.jp/ 
※以下の情報が収集されます
IPアドレス
アクセス時刻
変換したレコード数
変換に成功したレコード数
変換に要した処理時間
*)
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807



#############################
### クリップボードの中身取り出し
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "" as text
	end if
end if
##############################
###ダイアログ
set strMes to ("住所で検索\r部分一致が必要です\r福岡の小倉区は小倉ではNGで小倉❝区❞が必要") as text
set strQueryText to strReadString as text
###前面に
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "住所地名検索" default answer strQueryText buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
	if "OK" is equal to (button returned of recordResult) then
		set strReturnedText to (text returned of recordResult) as text
	else if (gave up of recordResult) is true then
		return "時間切れです"
	else
		return "キャンセル"
	end if
on error
	log "エラーしました"
	return
end try
##############################
###戻り値整形
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###タブと改行を除去しておく
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")

##############################
##
set strBaseURL to ("https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
##コンポーネント初期化
set ocidComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:true
##クエリー格納用Array
set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##検索語句
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("addr") value:(ocidTextM)
ocidQueryItemArray's addObject:(ocidQueryItem)
##コード
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("charset") value:("UTF8")
ocidQueryItemArray's addObject:(ocidQueryItem)
##計測系　エラーになるケースが発生しているので停止
#	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("geosys") value:("tokyo")
#	ocidQueryItemArray's addObject:(ocidQueryItem)
##駅名検索はSTATION
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("series") value:("ADDRESS")
ocidQueryItemArray's addObject:(ocidQueryItem)
##AND検索用?　今回は使わない
#	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("constraint") value:("神奈川県")
#	ocidQueryItemArray's addObject:(ocidQueryItem)
##
ocidComponents's setQueryItems:(ocidQueryItemArray)
##URL
set ocidAPIURL to ocidComponents's |URL|
log ocidAPIURL's absoluteString() as text

########################################
##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[検索語句]" & ocidTextM & "</title>" & strStylle & "</head><body>"
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)


##############################
set recordiLvl to {|1|:"都道府県", |2|:"郡・支庁・振興局", |3|:"市町村・特別区", |4|:"政令市の区", |5|:"大字", |6|:"丁目・小字", |7|:"街区・地番", |8|:"号・枝番", |0|:"レベル不明", |-1|:"座標不明"} as record
set ocidiLvlDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordiLvl)
###
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidAPIURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOT
set ocidRootElement to ocidReadXMLDoc's rootElement()
log (ocidRootElement's elementsForName:("query"))'s stringValue as text
log (ocidRootElement's elementsForName:("geodetic"))'s stringValue as text
log (ocidRootElement's elementsForName:("iConf"))'s stringValue as text
log (ocidRootElement's elementsForName:("converted"))'s stringValue as text
set listCandidateArray to ocidRootElement's nodesForXPath:("//candidate") |error|:(reference)
set ocidCandidateArray to (item 1 of listCandidateArray)
set numChild to (count of ocidCandidateArray) as integer

#########
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\">検索語句：" & ocidTextM & " 検索結果:" & numChild & "件</caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"項目１\" scope=\"row\" >連番</th><th title=\"項目２\" scope=\"col\">地名</th><th title=\"項目３\" scope=\"col\">リンク１</th><th title=\"項目４\"  scope=\"col\">リンク２</th><th title=\"項目５\"  scope=\"col\"> リンク３</th><th title=\"項目６\"  scope=\"col\">リンク４</th><th title=\"項目７\"  scope=\"col\">リンク５</th><th title=\"項目８\"  scope=\"col\">iLvl</th></tr></thead><tbody title=\"検索結果一覧\" >") as text
(ocidHTMLString's appendString:(strHTML))
##############################
set numLineNo to 1 as integer
###第一階層だけの子要素
repeat with itemCandidate in ocidCandidateArray
	set strAdd to (itemCandidate's elementsForName:("address"))'s stringValue as text
	set strLat to (itemCandidate's elementsForName:("latitude"))'s stringValue as text
	set strLong to (itemCandidate's elementsForName:("longitude"))'s stringValue as text
	set numiLvl to (itemCandidate's elementsForName:("iLvl"))'s stringValue as text
	set striLvl to (ocidiLvlDict's valueForKey:(numiLvl)) as text
	log striLvl
	###リンク１
	set strMapURL to ("https://www.navitime.co.jp/maps/aroundResult?lat=" & strLat & "&lon=" & strLong & "&type=station&radius=2000")
	set strLINK1 to "<a href=\"" & strMapURL & "\" target=\"_blank\">Navitime Map</a>"
	###リンク２
	set strMapURL to ("https://map.yahoo.co.jp/place?lat=" & strLat & "&lon=" & strLong & "&zoom=15&maptype=twoTones")
	set strLINK2 to "<a href=\"" & strMapURL & "\" target=\"_blank\">Yahoo Map</a>"
	###リンク３
	set strMapURL to ("https://maps.gsi.go.jp/vector/#15/" & strLat & "/" & strLong & "/&ls=vstd&disp=1&d=l")
	set strLINK3 to "<a href=\"" & strMapURL & "\" target=\"_blank\">Gsi vector Map</a>"
	###リンク４
	set strMapURL to ("https://www.jma.go.jp/bosai/nowc/#lat:" & strLat & "/lon:" & strLong & "/zoom:15/")
	set strLINK4 to "<a href=\"" & strMapURL & "\" target=\"_blank\">Jma Map</a>"
	###リンク５
	set strEncAdd to doTextEncode(strAdd)
	set strMapURL to ("http://maps.apple.com/?ll=" & strLat & "," & strLong & "&z=10&t=d&q=" & strEncAdd & "")
	set strLINK5 to "<a href=\"" & strMapURL & "\" target=\"_blank\">Apple Map</a>"
	###HTMLにして
	set strHTML to ("<tr><th title=\"連番\"  scope=\"row\">" & numLineNo & "</th><td title=\"地名\"><b>" & strAdd & "</b></td><td title=\"リンク１\">" & strLINK1 & "</td><td title=\"リンク２\">" & strLINK2 & "</td><td title=\"リンク３\">" & strLINK3 & "</td><td title=\"リンク４\">" & strLINK4 & "</td><td title=\"リンク５\">" & strLINK5 & "</td><td title=\"iLvl\">" & striLvl & "</td></tr>") as text
	(ocidHTMLString's appendString:(strHTML))
	###カウントアップ	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to ("</tbody><tfoot><tr><th colspan=\"8\" title=\"フッター表の終わり\"  scope=\"row\"><a href=\"https://geocode.csis.u-tokyo.ac.jp/\" target=\"_blank\">シンプル ジオコーディング</a></th></tr></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))

###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###パス

set strFileName to ((ocidTextM as text) & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
###ファイルに書き出し
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####テキストエディタで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
(*
tell application "TextEdit"
	activate
	open file aliasFilePath
end tell
*)
tell application "Safari"
	activate
	open file aliasFilePath
end tell




####################################
###### ％エンコード
####################################
on doUrlEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	##テキスト形式に確定
	set strTextToEncode to ocidArgTextEncoded as text
	###値を戻す
	return strTextToEncode
end doUrlEncode
####################################
###### ％エンコード
####################################
on doTextEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## 置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|!|:"%21", |#|:"%23", |$|:"%24", |&|:"%26", |'|:"%27", |(|:"%28", |)|:"%29", |*|:"%2A", |+|:"%2B", |,|:"%2C", |:|:"%3A", |;|:"%3B", |=|:"%3D", |?|:"%3F", |@|:"%40", | |:"%20"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		set strItemKey to itemAllKey as text
		##キーの値を取り出して
		if strItemKey is "@" then
			##置換
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:("@") withString:("%40"))
		else
			set ocidMapValue to (ocidPercentMap's valueForKey:(strItemKey))
			##置換
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(strItemKey) withString:(ocidMapValue))
		end if
		
		##次の変換に備える
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##テキスト形式に確定
	set strTextToEncode to ocidEncodedText as text
	###値を戻す
	return strTextToEncode
end doTextEncode
