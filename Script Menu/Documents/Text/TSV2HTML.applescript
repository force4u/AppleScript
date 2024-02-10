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

### 【１】入力ファイル
#ダイアログ
tell current application
	set strName to name as text
end tell
#スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
#デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
#
set listUTI to {"public.tab-separated-values-text"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location aliasDesktopDirPath of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
if aliasFilePath is (missing value) then
	return "選んでください"
end if
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
#保存するタブ区切りテキストのパス
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidFileName to ocidBaseFilePathURL's lastPathComponent()
set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("html"))
### 【２】	ファイルのテキストを読み込み
set listResponse to (refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
set ocidReadString to (item 1 of listResponse)
#可変にして
set ocidLineString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
(ocidLineString's setString:(ocidReadString))
#改行をUNIXに強制
set ocidLineStringLF to (ocidLineString's stringByReplacingOccurrencesOfString:("\r\n") withString:("\n"))
set ocidLineString to (ocidLineStringLF's stringByReplacingOccurrencesOfString:("\r") withString:("\n"))
#改行毎でリストにする
set ocidCharSet to (refMe's NSCharacterSet's newlineCharacterSet)
set ocidLineArray to (ocidLineString's componentsSeparatedByCharactersInSet:(ocidCharSet))
#最初の１行目だけ別で取得しておく
set ocidFirstObjectString to ocidLineArray's firstObject()
set ocidFirstLineArray to ocidFirstObjectString's componentsSeparatedByString:("\t")

###【４】データをHTMLに整形
########################################
#headerに渡すエレメント
set ocidH3Element to refMe's NSXMLElement's elementWithName:("h3")
(ocidH3Element's setStringValue:("タブ区切りテキストをHTMLテーブルに"))
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
ocidCaptionElement's setStringValue:(ocidFileName)
ocidTableElement's addChild:(ocidCaptionElement)
#【colgroup】
set ocidColgroupElement to refMe's NSXMLElement's elementWithName:("colgroup")
#タイトル部の数だけ繰り返し
repeat with itemColName in ocidFirstLineArray
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
repeat with itemColName in ocidFirstLineArray
	#ここはTDではなくてTHを利用
	set ocidAddElement to (refMe's NSXMLElement's elementWithName:("th"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemColName))
	(ocidAddElement's addAttribute:(ocidAddNode))
	#
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("id") stringValue:(itemColName))
	(ocidAddElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("col"))
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
set numCntContents to (count of ocidLineArray) - 1 as integer
repeat with itemIntNo from 1 to numCntContents by 1
	set ocidLineItem to (ocidLineArray's objectAtIndex:(itemIntNo))
	#空行で終わり
	if (ocidLineItem as text) is "" then
		exit repeat
	end if
	#
	set ocidItemLineArray to (ocidLineItem's componentsSeparatedByString:("\t"))
	set numCntItemLineArray to (count of ocidItemLineArray) as integer
	##############
	#TRの開始
	set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
	repeat with itemLineNo from 0 to (numCntItemLineArray - 1) by 1
		set coidFieldValue to (ocidItemLineArray's objectAtIndex:(itemLineNo))
		if itemLineNo = 0 then
			set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
			set strTitle to (ocidFirstLineArray's objectAtIndex:(itemLineNo))
			set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(strTitle))
			(ocidThElement's addAttribute:(ocidAddNode))
			set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("headers") stringValue:(strTitle))
			(ocidThElement's addAttribute:(ocidAddNode))
			set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("col"))
			(ocidThElement's addAttribute:(ocidAddNode))
			(ocidThElement's setStringValue:(coidFieldValue))
			(ocidTrElement's addChild:(ocidThElement))
		else
			set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
			set strTitle to (ocidFirstLineArray's objectAtIndex:(itemLineNo))
			set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(strTitle))
			(ocidTdElement's addAttribute:(ocidAddNode))
			set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("headers") stringValue:(strTitle))
			(ocidTdElement's addAttribute:(ocidAddNode))
			(ocidTdElement's setStringValue:(coidFieldValue))
			(ocidTrElement's addChild:(ocidTdElement))
		end if
	end repeat
	(ocidTbodyElement's addChild:(ocidTrElement))
end repeat
#TBODYをテーブルにセット
ocidTableElement's addChild:(ocidTbodyElement)
#【tfoot】 TRで
set ocidTfootElement to refMe's NSXMLElement's elementWithName:("tfoot")
set ocidTrElement to refMe's NSXMLElement's elementWithName:("tr")
#項目数を取得して
set numCntCol to (count of ocidFirstLineArray) as integer
#colspan指定して１行でセット
set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("テーブルの終わり"))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("colspan") stringValue:(numCntCol as text))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("row"))
(ocidThElement's addAttribute:(ocidAddNode))
#
set strContents to ("項目数 : " & (numCntContents - 1)) as text
(ocidThElement's setStringValue:(strContents))
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

#####【５−２】保存
#読み取りやすい表示
set ocidXMLdata to ocidHTML's XMLDataWithOptions:(refMe's NSXMLNodePrettyPrint)

set listDone to ocidXMLdata's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)

####【６】ブラウザで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
tell application "Finder"
	open location aliasFilePath
end tell

############################################################
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
############################################################
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
	ocidAddElement's setStringValue:("TSV2HTML")
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
	#ボディをROOTエレメントにセット
	ocidRootElement's addChild:(ocidBodyElement)
	#ROOTをXMLにセット
	ocidXMLDoc's setRootElement:(ocidRootElement)
	#値を戻す
	return ocidXMLDoc
end doMakeRootElement
