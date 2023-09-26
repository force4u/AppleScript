#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

### 【１】RSSのURL
set strBaseURL to ("https://www.data.jma.go.jp/developer/xml/feed/extra.xml") as text
set strBaseURL to ("https://www.data.jma.go.jp/developer/xml/feed/regular.xml") as text
set strBaseURL to ("https://www.data.jma.go.jp/developer/xml/feed/other.xml") as text
set strBaseURL to ("https://www.data.jma.go.jp/developer/xml/feed/eqvol.xml") as text

set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
### 【２】RSS読み込み
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
###XMLドキュメント
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOTエレメント
set ocidRootElement to ocidReadXMLDoc's rootElement()
set strMainTitle to (ocidRootElement's elementsForName:("title"))'s stringValue as text
set strUpdate to (ocidRootElement's elementsForName:("updated"))'s stringValue as text
###
set listEntryArray to ocidRootElement's nodesForXPath:("//entry") |error|:(reference)
set ocidEntryArray to (item 1 of listEntryArray)
set numChild to (count of ocidEntryArray) as integer
log numChild & "件の情報があります"
###エントリーの数だけ繰り返す


########################################
##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[eqvol.xml]" & strMainTitle & "</title>" & strStylle & "</head><body>"
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)

#########
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\">" & strMainTitle & "[地震]<a href=\"https://www.jma.go.jp/bosai/map.html#contents=earthquake_map\" target=\"_blank\">LINK</a> [噴火]<a href=\"https://www.jma.go.jp/bosai/map.html#contents=volcano\" target=\"_blank\">LINK</a></caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"項目１\" scope=\"row\" >連番</th><th title=\"項目２\" scope=\"col\"> タイトル </th><th title=\"項目３\" scope=\"col\">日時</th><th title=\"項目４\"  scope=\"col\">発表</th><th title=\"項目５\"  scope=\"col\"> 詳細</th></tr></thead><tbody title=\"検索結果一覧\" >") as text
(ocidHTMLString's appendString:(strHTML))

set strLineNO to 1 as integer
repeat with itemEntry in ocidEntryArray
	set strTitle to (itemEntry's elementsForName:("title"))'s stringValue as text
	##	log (itemEntry's elementsForName:("id"))'s stringValue as text
	set strUpdate to (itemEntry's elementsForName:("updated"))'s stringValue as text
	set strDate to doDateExchange(strUpdate)
	set listEntryArray to (itemEntry's nodesForXPath:("//author") |error|:(reference))
	set strAuth to (((item 1 of listEntryArray)'s firstObject())'s elementsForName:("name"))'s stringValue as text
	set strContents to (itemEntry's elementsForName:("content"))'s stringValue as text
	
	###HTMLにして
	set strHTML to ("<tr><th title=\"連番\"  scope=\"row\">" & strLineNO & "</th><td title=\"タイトル\"><b>" & strTitle & "</b></td><td title=\"日時\">" & strDate & "</td><td title=\"発表\">" & strAuth & "</td><td title=\"詳細\">" & strContents & "</td></tr>") as text
	(ocidHTMLString's appendString:(strHTML))
	
	set strLineNO to strLineNO + 1 as integer
end repeat

set strHTML to ("</tbody><tfoot><tr><th colspan=\"5\" title=\"フッター表の終わり\"  scope=\"row\"><a href=\"https://xml.kishou.go.jp/index.html\" target=\"_blank\">www.jma.go.jp</a></th></tr></tfoot></table></div>") as text
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

set strFileName to ((strMainTitle) & ".html") as text
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


####################
#日付フォーマット変換
####################
to doDateExchange(argDateText)
	###【１】入力日付テキスト
	set ocidDateString to refMe's NSString's stringWithString:(argDateText)
	set ocidFormatter to refMe's NSDateFormatter's alloc()'s init()
	###【２】入力日付フォーマット
	ocidFormatter's setDateFormat:"yyyy-MM-dd'T'HH:mm:ss'Z'"
	###【３】入力テキストを入力フォーマットに沿ってDateにする
	set ocidStringDate to ocidFormatter's dateFromString:(ocidDateString)
	###【４】出力用の日付フォーマット
	ocidFormatter's setDateFormat:("M月d日 H時m分")
	###【５】３で作った入力日付データを４の出力フォーマットでテキストに
	set ocidOutPutDate to ocidFormatter's stringFromDate:(ocidStringDate)
	###【６】テキストにして戻す
	set strOutPutDate to ocidOutPutDate as text
	return strOutPutDate
end doDateExchange
