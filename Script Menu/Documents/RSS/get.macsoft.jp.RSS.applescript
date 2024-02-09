#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
【１】RSSのURL
【２】RSS読み込み
【３】RSSから必要なデータを取得
【４】データをHTMLに整形
【５】保存
【６】ブラウザで開く

【３】RSSから必要なデータを取得
【３-１】：ROOT
【３-２】：RSS
【３-３】：channel
【３-４】：item

【４】データをHTMLに整形
【４−１】ヘッダー部等
【４−２】itemの追加
【４−３】整形終了


【５】保存
【５−１】保存先ディレクトリの確保
【５−２】保存

com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

### 【１】RSSのURL
set strURL to ("https://macsoft.jp/feed/") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strURL)
set strHost to ocidURL's |host|() as text

### 【２】RSS読み込み
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###【３】RSSから必要なデータを取得
#【３-１】：ROOT
#【３-２】：RSS
set ocidRootElement to ocidReadXMLDoc's rootElement()
#【３-３】：channel
#########【取得方法A】
##channelを要素として取得してから処理する
set ocidChannel to ocidRootElement's elementsForName:("channel")
set ocidChannelElement to ocidChannel's firstObject()
##タイトル
set strMainTitle to (ocidChannelElement's elementsForName:("title"))'s stringValue as text
##メインのリンク
set strMainLink to (ocidChannelElement's elementsForName:("link"))'s stringValue as text
##説明
set strDescription to (ocidChannelElement's elementsForName:("description"))'s stringValue as text
##言語
set strLanguage to (ocidChannelElement's elementsForName:("language"))'s stringValue as text
##発行日
set strPubDate to (ocidChannelElement's elementsForName:("lastBuildDate"))'s stringValue as text
######imageの子要素を取得するのでobjectValueは不要
set ocidImageArray to ocidChannelElement's elementsForName:("image")
set ocidImageDict to ocidImageArray's firstObject()
set strImageTitle to (ocidImageDict's elementsForName:("title"))'s stringValue as text
set strImageLink to (ocidImageDict's elementsForName:("link"))'s stringValue as text
set strImageURL to (ocidImageDict's elementsForName:("url"))'s stringValue as text
set strImageWidth to (ocidImageDict's elementsForName:("width"))'s stringValue as text
set strImageHeight to (ocidImageDict's elementsForName:("height"))'s stringValue as text
############pubDateの日付の処理
##日付を日本語表記に
set ocidPubDate to refMe's NSString's stringWithString:(strPubDate)
set ocidInputFormatter to refMe's NSDateFormatter's alloc()'s init()
set ocidEnLocale to refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("en_US_POSIX")
ocidInputFormatter's setLocale:(ocidEnLocale)
ocidInputFormatter's setDateFormat:("EEE, dd MMM yyyy HH:mm:ss ZZZ")
set ocidEnDate to ocidInputFormatter's dateFromString:(ocidPubDate)
##
set ocidOutputFormatter to refMe's NSDateFormatter's alloc()'s init()
set ocidJpLocale to refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP")
ocidOutputFormatter's setLocale:(ocidJpLocale)
ocidOutputFormatter's setDateFormat:("yyyy年MM月dd日EEEE")
set strJpDate to (ocidOutputFormatter's stringFromDate:(ocidEnDate)) as text

###【４】データをHTMLに整形
########################################
##HTML 基本構造
#【４−１】ヘッダー部等
set strStylle to "<style>body {margin: 10px;background-color: #FFFFFF;}#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;}table {border-spacing: 0;caption-side: top;font-family: system-ui;}thead th {border: solid 1px #666666;padding: .5ch 1ch;border-block-width: 1px 0;border-inline-width: 1px 0;&:first-of-type {border-start-start-radius: .5em}&:last-of-type {border-start-end-radius: .5em;border-inline-end-width: 1px}}tbody td {border-spacing: 0;border: solid 1px #666666;padding: .5ch 1ch;border-block-width: 1px 0;border-inline-width: 1px 0;&:last-of-type {border-inline-end-width: 1px}}tbody th {border-spacing: 0;border: solid 1px #666666;padding: .5ch 1ch;border-block-width: 1px 0;border-inline-width: 1px 0;}tbody tr:nth-of-type(odd) {background: #F2F2F2;}.kind_string {font-size: 0.75em;}.date_string {font-size: 0.5em;}tfoot th {border: solid 1px #666666;padding: .5ch 1ch;&:first-of-type {border-end-start-radius: .5em}&:last-of-type {border-end-end-radius: .5em;border-inline-end-width: 1px}}</style>" as text
###ヘッダー部
#タイトル挿入
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>" & strMainTitle & "</title>" & strStylle & "</head><body>" as text
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
ocidHTMLString's appendString:(strHead)
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\"><a href=\"" & strMainLink & "\" target=\"_blank\">" & strMainTitle & "</a> : " & strJpDate & " </caption><thead><tr><th title=\"連番\" scope=\"row\"> </th><th title=\"ジャンル\">ジャンル</th><th title=\"バージョン\">バージョン</th><th title=\"ディスクリプション\">内容</th><th title=\"リンク\">LINK</th><th title=\"更新日\">更新日</th></tr></thead><tbody>") as text
ocidHTMLString's appendString:(strHTML)
########################################
###【３-４】：item
set ocidItemArray to (ocidChannelElement's elementsForName:("item"))
set strLineNO to 1 as integer
repeat with itemArray in ocidItemArray
	###タイトル
	set strItemTitle to (itemArray's elementsForName:("title"))'s stringValue as text
	###詳細
	set strItemDescription to (itemArray's elementsForName:("description"))'s stringValue as text
	set ocidItemDescription to (refMe's NSString's stringWithString:(strItemDescription))
	set ocidItemDescription to (ocidItemDescription's stringByReplacingOccurrencesOfString:("<p>Copyright &copy; 2024 <a href=\"https://macsoft.jp\">新しもの好きのダウンロード</a> All Rights Reserved.</p>") withString:(""))
	set strItemDescription to ocidItemDescription as text
	###category
	set ocidItemCategoryArray to (itemArray's elementsForName:("category"))
	set strCategory to ("") as text
	repeat with itemCategory in ocidItemCategoryArray
		set strItemCategory to itemCategory's stringValue as text
		set strCategory to (strCategory & strItemCategory & "<hr />") as text
	end repeat
	
	###日付　英語表記でdateにしてから日本語表記にテキスト出力
	set strItemPubDate to (itemArray's elementsForName:("pubDate"))'s stringValue as text
	set ocidPubDate to (refMe's NSString's stringWithString:(strItemPubDate))
	set ocidInputFormatter to refMe's NSDateFormatter's alloc()'s init()
	set ocidEnLocale to (refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("en_US_POSIX"))
	(ocidInputFormatter's setLocale:(ocidEnLocale))
	(ocidInputFormatter's setDateFormat:("EEE, dd MMM yyyy HH:mm:ss ZZZ"))
	set ocidEnDate to (ocidInputFormatter's dateFromString:(ocidPubDate))
	set ocidOutputFormatter to refMe's NSDateFormatter's alloc()'s init()
	set ocidJpLocale to (refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP"))
	(ocidOutputFormatter's setLocale:(ocidJpLocale))
	(ocidOutputFormatter's setDateFormat:("yyyy年MM月dd日EEEE"))
	set strJpDate to (ocidOutputFormatter's stringFromDate:(ocidEnDate)) as text
	###リンク
	set strItemLink to (itemArray's elementsForName:("link"))'s stringValue as text
	##HTML整形
	set strHTML to ("<tr><th title=\"連番\" scope=\"row\">" & strLineNO & "</th><td title=\"カテゴリ\">" & strCategory & "</td><td title=\"タイトル\">" & strItemTitle & "</td><td title=\"詳細\">" & strItemDescription & "</td><td title=\"リンク\"><a href=\"" & strItemLink & "\" target=\"_blank\">LINK</a></td><td title=\"日付\">" & strJpDate & "</td></tr>") as text
	##↑のHTMLを出力用のテキストに積み上げていく
	(ocidHTMLString's appendString:(strHTML))
	set strLineNO to strLineNO + 1 as integer
end repeat

set strHTML to ("</tbody><tfoot><tr><th colspan=\"6\" title=\"フッター表の終わり\" scope=\"row\"><a href=\"https://quicktimer.cocolog-nifty.com/\" target=\"_blank\">AppleScriptで生成しました</a></th></tr></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))

#####【５−１】保存先ディレクトリの確保
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
#上書きできないようにUUIDで別名フォルダにする
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
#アクセス権777=511を指定
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#保存ファイル名
set strFileName to (strHost & ".html") as text
#保存先URL
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

#####【５−２】保存
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

####【６】ブラウザで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
tell application "Finder"
	open location aliasFilePath
end tell

