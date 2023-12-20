#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
MacUpdateの最新２５項目をHTMLで表示
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

### 【１】RSSのURL
set strURL to ("https://www.macupdate.com/rss") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strURL)
### 【２】RSS読み込み
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###【３】ROOTエレメント
set ocidRootElement to ocidReadXMLDoc's rootElement()
###【４】channelエレメント
########タイトル(取得方法A)
set ocidChannel to ocidRootElement's elementsForName:("channel")
set ocidChannelElement to ocidChannel's firstObject()
set strMainTitle to (ocidChannelElement's elementsForName:("title"))'s stringValue as text
log strMainTitle
##メインのリンク
set strMainLink to (ocidChannelElement's elementsForName:("link"))'s stringValue as text

########発行日(取得方法B)
set listPubDate to ocidRootElement's nodesForXPath:("//channel/pubDate") |error|:(reference)
set strPubDate to (item 1 of listPubDate)'s stringValue as text
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

###【5】生成するHTMLパーツ
########################################
##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>" as text
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>" & strMainTitle & "</title>" & strStylle & "</head><body>" as text
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
ocidHTMLString's appendString:(strHead)
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\"><a href=\"" & strMainLink & "\" target=\"_blank\">" & strMainTitle & "</a> : " & strJpDate & " </caption>") as text
ocidHTMLString's appendString:(strHTML)

###【6】itemエレメント
set ocidItemArray to (ocidChannelElement's elementsForName:("item"))
set strLineNO to 1 as integer
repeat with itemArray in ocidItemArray
	###タイトル
	set strItemTitle to (itemArray's elementsForName:("title"))'s stringValue as text
	###タイトルを　名称　バージョン　詳細　に分離
	set ocidItemTitle to (refMe's NSString's stringWithString:(strItemTitle))
	set ocidItemTitleArray to (ocidItemTitle's componentsSeparatedByString:(" - "))
	set strDiscription to (ocidItemTitleArray's lastObject()) as text
	set strAppName to (ocidItemTitleArray's firstObject()) as text
	set ocidAppName to (refMe's NSString's stringWithString:(strAppName))
	set ocidAppNameArray to (ocidAppName's componentsSeparatedByString:(" "))
	set strVersIon to (ocidAppNameArray's lastObject()) as text
	set numCntArrya to count of ocidAppNameArray
	if numCntArrya = 2 then
		set strAppName to (ocidAppNameArray's componentsJoinedByString:(""))
	else
		ocidAppNameArray's removeLastObject()
		set strAppName to (ocidAppNameArray's componentsJoinedByString:(""))
	end if
	###リンクからAppIDを取得
	set strItemLink to (itemArray's elementsForName:("link"))'s stringValue as text
	set ocidItemURL to (refMe's NSURL's alloc()'s initWithString:(strItemLink))
	set ocidAppURL to ocidItemURL's URLByDeletingLastPathComponent()
	set strAppID to (ocidAppURL's lastPathComponent()) as text
	
	set strHTML to ("<tr><th title=\"連番\" scope=\"row\">" & strLineNO & "</th><td title=\"タイトル\">" & strAppName & "</td><td title=\"バージョン\">" & strVersIon & "</td><td title=\"ディスクリプション\">" & strDiscription & "</td><td title=\"リンク\"><a href=\"" & strItemLink & "\" target=\"_blank\">LINK</a></td></tr>") as text
	(ocidHTMLString's appendString:(strHTML))
	set strLineNO to strLineNO + 1 as integer
end repeat

set strHTML to ("</tbody><tfoot><tr><th colspan=\"5\" title=\"フッター表の終わり\" scope=\"row\"><a href=\"https://quicktimer.cocolog-nifty.com/\" target=\"_blank\">AppleScriptで生成しました</a></th></tr></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))

#####【７】保存先ディレクトリとURLを生成しておく
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###パス
set strFileName to ("macupdate.html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

#####【８】HTMLをファイルにする
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

####【９】Finderで開く
set strFilePath to ocidSaveFilePathURL's |path| as text
set strFilePathURL to ocidSaveFilePathURL's absoluteString() as text
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias

tell application "Finder"
	open location aliasFilePath
end tell

