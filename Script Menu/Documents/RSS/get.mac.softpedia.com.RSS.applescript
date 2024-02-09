#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

### 【１】RSSのURL
set strURL to ("https://mac.softpedia.com/backend.xml") as text
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
#	set strImageWidth to (ocidImageDict's elementsForName:("width"))'s stringValue as text
#	set strImageHeight to (ocidImageDict's elementsForName:("height"))'s stringValue as text
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
#headerに渡すエレメント
set ocidH3Element to refMe's NSXMLElement's elementWithName:("h3")
(ocidH3Element's setStringValue:("RSS表示"))
########################################
#footerに渡すエレメント
set ocidFotterAElement to refMe's NSXMLElement's elementWithName:("a")
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:("https://quicktimer.cocolog-nifty.com/"))
(ocidFotterAElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
(ocidFotterAElement's addAttribute:(ocidAddNode))
set strContents to ("AppleScriptで生成しました") as text
(ocidFotterAElement's setStringValue:(strContents))
########################################
#articleに渡すエレメント
#テーブル部生成開始
set ocidTableElement to refMe's NSXMLElement's elementWithName:("table")
#【caption】
set ocidCaptionElement to refMe's NSXMLElement's elementWithName:("caption")
set strSetValue to (strMainTitle & ": " & strJpDate) as text
ocidCaptionElement's setStringValue:(strSetValue)
ocidTableElement's addChild:(ocidCaptionElement)
#【colgroup】
set ocidColgroupElement to refMe's NSXMLElement's elementWithName:("colgroup")
#テーブルのタイトル部
set listColName to {"行番号", "ジャンル", "名称", "内容", "リンク", "修正日"} as list
#タイトル部の数だけ繰り返し
repeat with itemColName in listColName
	#【col】col生成
	set ocidAddElement to (refMe's NSXMLElement's elementWithName:("col"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemColName))
	(ocidAddElement's addAttribute:(ocidAddNode))
	(ocidColgroupElement's addChild:(ocidAddElement))
end repeat
#テーブルエレメントに追加
ocidTableElement's addChild:(ocidColgroupElement)
#【thead】
set ocidTheadElement to refMe's NSXMLElement's elementWithName:("thead")
#TR
set ocidTrElement to refMe's NSXMLElement's elementWithName:("tr")
#タイトル部の数だけ繰り返し
repeat with itemColName in listColName
	#ここはTDではなくてTHを利用
	set ocidAddElement to (refMe's NSXMLElement's elementWithName:("th"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemColName))
	(ocidAddElement's addAttribute:(ocidAddNode))
	#値を入れる
	(ocidAddElement's setStringValue:(itemColName))
	#TH→TRにセット
	(ocidTrElement's addChild:(ocidAddElement))
end repeat
#TRをTHEADにセット
ocidTheadElement's addChild:(ocidTrElement)
#THEADをテーブルにセット
ocidTableElement's addChild:(ocidTheadElement)
########################################
#【tbody】
set ocidTbodyElement to refMe's NSXMLElement's elementWithName:("tbody")
###【３-４】：item
set ocidItemArray to (ocidChannelElement's elementsForName:("item"))
set numLineNO to 1 as integer
repeat with itemArray in ocidItemArray
	###タイトル
	set ocidItemTitle to (itemArray's elementsForName:("title"))'s stringValue
	###詳細
	set ocidItemDescription to (itemArray's elementsForName:("description"))'s stringValue
	###category
	set ocidItemCategory to (itemArray's elementsForName:("category"))'s stringValue
	###日付　英語表記でdateにしてから日本語表記にテキスト出力
	set ocidPubDate to (itemArray's elementsForName:("pubDate"))'s stringValue
	set ocidInputFormatter to refMe's NSDateFormatter's alloc()'s init()
	set ocidEnLocale to (refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("en_US_POSIX"))
	(ocidInputFormatter's setLocale:(ocidEnLocale))
	(ocidInputFormatter's setDateFormat:("EEE, dd MMM yyyy HH:mm:ss Z"))
	set ocidEnDate to (ocidInputFormatter's stringFromDate:(ocidPubDate))
	set ocidOutputFormatter to refMe's NSDateFormatter's alloc()'s init()
	set ocidJpLocale to (refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP"))
	(ocidOutputFormatter's setLocale:(ocidJpLocale))
	(ocidOutputFormatter's setDateFormat:("yyyy年MM月dd日EEEE"))
	set ocidJpDate to (ocidOutputFormatter's stringFromDate:(ocidEnDate))
	###リンク
	set ocidItemLink to (itemArray's elementsForName:("link"))'s stringValue
	#TRの開始
	set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
	#【行番号】をTHでセット
	set strZeroSupp to ("00") as text
	set strZeroSupp to ("00" & numLineNO) as text
	set strLineNO to (text -3 through -1 of strZeroSupp) as text
	set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("行番号"))
	(ocidThElement's addAttribute:(ocidAddNode))
	(ocidThElement's setStringValue:(strLineNO))
	(ocidTrElement's addChild:(ocidThElement))
	#【ジャンル】をTDでセット
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("ジャンル"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	(ocidTdElement's setStringValue:(ocidItemCategory))
	(ocidTrElement's addChild:(ocidTdElement))
	#【ジャンル】をTDでセット
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("タイトル"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	(ocidTdElement's setStringValue:(ocidItemTitle))
	(ocidTrElement's addChild:(ocidTdElement))
	#【詳細】をTDでセット
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("詳細"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	(ocidTdElement's setStringValue:(ocidItemDescription))
	(ocidTrElement's addChild:(ocidTdElement))
	#【リンク】をTDでセット
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("リンク"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	#
	set ocidAElement to (refMe's NSXMLElement's elementWithName:("a"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:(ocidItemLink))
	(ocidAElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
	(ocidAElement's addAttribute:(ocidAddNode))
	(ocidAElement's setStringValue:("LINK"))
	#リンクをTDにセット
	(ocidTdElement's addChild:(ocidAElement))
	(ocidTrElement's addChild:(ocidTdElement))
	#【更新日】をTDでセット
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("更新日"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	(ocidTdElement's setStringValue:(ocidJpDate))
	(ocidTrElement's addChild:(ocidTdElement))
	#出来上がったTRをTBODYにセット
	(ocidTbodyElement's addChild:(ocidTrElement))
	set numLineNO to numLineNO + 1 as integer
end repeat
#TBODYをテーブルにセット
ocidTableElement's addChild:(ocidTbodyElement)
#【tfoot】 TRで
set ocidTfootElement to refMe's NSXMLElement's elementWithName:("tfoot")
set ocidTrElement to refMe's NSXMLElement's elementWithName:("tr")
#項目数を取得して
set numCntCol to (count of listColName) as integer
#colspan指定して１行でセット
set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("テーブルの終わり"))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("colspan") stringValue:(numCntCol as text))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("row"))
(ocidThElement's addAttribute:(ocidAddNode))
#
set ocidTfotterAElement to refMe's NSXMLElement's elementWithName:("a")
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:(strMainLink))
(ocidTfotterAElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
(ocidTfotterAElement's addAttribute:(ocidAddNode))
set strContents to ("ソフトぺディアMac") as text
(ocidTfotterAElement's setStringValue:(strContents))
ocidThElement's addChild:(ocidTfotterAElement)
#THをTRにセットして
ocidTrElement's addChild:(ocidThElement)
#TRをTFOOTにセット
ocidTfootElement's addChild:(ocidTrElement)
#TFOOTをテーブルにセット
ocidTableElement's addChild:(ocidTfootElement)

##############################
#HTMLにする
##############################
set ocidHTML to doMakeRootElement({ocidH3Element, ocidTableElement, ocidFotterAElement})

##############################
#保存
##############################
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
#読み取りやすい表示
set ocidXMLdata to ocidHTML's XMLDataWithOptions:(refMe's NSXMLNodePrettyPrint)

set listDone to ocidXMLdata's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)

####【６】ブラウザで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
tell application "Finder"
	open location aliasFilePath
end tell

##############################
# 基本的なHTMLの構造
(*
doMakeRootElement({argHeaderContents, argArticleContents, argFooterContents})
HTMLのBODY部
header
article
footerにそれぞれAddchildするデータをリストで渡す
戻り値はRootエレメントにセットされた
NSXMLDocumentを戻すので　保存すればOK
*)
##############################
to doMakeRootElement({argHeaderContents, argArticleContents, argFooterContents})
	#XML初期化
	set ocidXMLDoc to refMe's NSXMLDocument's alloc()'s init()
	ocidXMLDoc's setDocumentContentKind:(refMe's NSXMLDocumentHTMLKind)
	# DTD付与
	set ocidDTD to refMe's NSXMLDTD's alloc()'s init()
	ocidDTD's setName:("html")
	ocidXMLDoc's setDTD:(ocidDTD)
	#
	set ocidRootElement to refMe's NSXMLElement's elementWithName:("html")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("lang") stringValue:("ja")
	ocidRootElement's addAttribute:(ocidAddNode)
	#
	set ocidHeadElement to refMe's NSXMLElement's elementWithName:("head")
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("title")
	ocidAddElement's setStringValue:("RSS一覧")
	ocidHeadElement's addChild:(ocidAddElement)
	# http-equiv
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("http-equiv") stringValue:("Content-Type")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("text/html; charset=UTF-8")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("http-equiv") stringValue:("Content-Style-Type")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("text/css")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("http-equiv") stringValue:("Content-Script-Type")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("text/javascript")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("name") stringValue:("viewport")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("width=720")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("style")
	ocidAddElement's setStringValue:("body { margin: 10px; background-color: #FFFFFF; } table { border-spacing: 0; caption-side: top; font-family: system-ui; } thead th { border: solid 1px #666666; padding: .5ch 1ch; border-block-width: 1px 0; border-inline-width: 1px 0; &:first-of-type { border-start-start-radius: .5em } &:last-of-type { border-start-end-radius: .5em; border-inline-end-width: 1px } } tbody td { word-wrap: break-word;max-width: 360px;border-spacing: 0; border: solid 1px #666666; padding: .5ch 1ch; border-block-width: 1px 0; border-inline-width: 1px 0; &:last-of-type { border-inline-end-width: 1px } } tbody th { border-spacing: 0; border: solid 1px #666666; padding: .5ch 1ch; border-block-width: 1px 0; border-inline-width: 1px 0; } tbody tr:nth-of-type(odd) { background: #F2F2F2; } .kind_string { font-size: 0.75em; } .date_string { font-size: 0.5em; } tfoot th { border: solid 1px #666666; padding: .5ch 1ch; &:first-of-type { border-end-start-radius: .5em } &:last-of-type { border-end-end-radius: .5em; border-inline-end-width: 1px } }")
	ocidHeadElement's addChild:(ocidAddElement)
	ocidRootElement's addChild:(ocidHeadElement)
	#	
	#ボディエレメント
	set ocidBodyElement to refMe's NSXMLElement's elementWithName:("body")
	#ヘッダー
	set ocidHeaderElement to refMe's NSXMLElement's elementWithName:("header")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("header")
	ocidHeaderElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_header")
	ocidHeaderElement's addAttribute:(ocidAddNode)
	ocidHeaderElement's addChild:(argHeaderContents)
	ocidBodyElement's addChild:(ocidHeaderElement)
	#アーティクル
	set ocidArticleElement to refMe's NSXMLElement's elementWithName:("article")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("article")
	ocidArticleElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_article")
	ocidArticleElement's addAttribute:(ocidAddNode)
	ocidArticleElement's addChild:(argArticleContents)
	ocidBodyElement's addChild:(ocidArticleElement)
	#フッター
	set ocidFooterElement to refMe's NSXMLElement's elementWithName:("footer")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("footer")
	ocidFooterElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_footer")
	ocidFooterElement's addAttribute:(ocidAddNode)
	ocidFooterElement's addChild:(argFooterContents)
	ocidBodyElement's addChild:(ocidFooterElement)
	
	ocidRootElement's addChild:(ocidBodyElement)
	ocidXMLDoc's setRootElement:(ocidRootElement)
	return ocidXMLDoc
end doMakeRootElement