#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 別途JSONが必要です
# 使う場合は以下を利用ください（JSONも同封しています）
(*
https://quicktimer.cocolog-nifty.com/icefloe/files/yahoonewsrss.zip
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

###設定項目
set strBaseURL to ("https://news.yahoo.co.jp") as text
##ファイル名デスクトップが保存先
set strSaveFileName to ("YahooNewsOpml.opml") as text
##OPMLのタイトル
set strTitle to ("QuickTimerのOPML") as text
##outlineエレメント名＝feedlyだとフォルダ名
set strOutlineName to ("YahooNewsRss") as text

########################
##保存先パス
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
##保存ファイルパス
set ocidOpmlFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
########################
##JSONファイル
set strJsonFileName to ("rssList.json") as text
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDirPath to (container of aliasPathToMe) as alias
	set aliasJsonFilePath to (file strJsonFileName of folder "data" of folder aliasContainerDirPath) as alias
end tell
set strJsonFilePath to (POSIX path of aliasJsonFilePath) as text
set ocidJsonFilePathStr to refMe's NSString's stringWithString:(strJsonFilePath)
set ocidJsonFilePath to ocidJsonFilePathStr's stringByStandardizingPath()
set ocidJsonFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidJsonFilePath) isDirectory:false)
##JSON読みとり
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidJsonFilePathURL) options:(ocidOption) |error|:(reference)
set ocidReadData to (item 1 of listReadData)
#NSPropertyListSerializationしてレコードに
set ocidOption to (refMe's NSJSONReadingMutableContainers)
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadData) options:(ocidOption) |error|:(reference))
set ocidPlistDict to item 1 of listJSONSerialization
###ALLkey取得
set ocidAllKeyArray to ocidPlistDict's allKeys()
########################
##XML
###【A】ROOT エレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"opml"
###【A-1】ROOT エレメントにネームスペース
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("version") stringValue:("1.0"))
###【A-B】子要素
set ocidHeadElement to (refMe's NSXMLElement's alloc()'s initWithName:("head"))
###【A-B-1】子要素
set ocidTitleElement to (refMe's NSXMLElement's elementWithName:("title"))
(ocidTitleElement's setStringValue:(strTitle))
##子要素titleエレメント　をheadにセット
(ocidHeadElement's addChild:(ocidTitleElement))
##↑で追加したheadエレメントをROOTにセット
(ocidRootElement's addChild:(ocidHeadElement))
###【A-C-1】子要素body
set ocidBodyElement to (refMe's NSXMLElement's alloc()'s initWithName:("body"))
###【A-C-2】子要素 項目フォルダ
repeat with itemAllKeyArray in ocidAllKeyArray
	##【A-C-2】bodyエレメントの外側のoutline＝フォルダ名になる
	set ocidOutLineDivElement to (refMe's NSXMLElement's elementWithName:("outline"))
	##外側のoutlineにネームスペース text とtitleを追加
	(ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(itemAllKeyArray)))
	(ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemAllKeyArray)))
	set ocidDivArray to (ocidPlistDict's objectForKey:(itemAllKeyArray))
	##【A-D】各項目＝RSSの項目の処理
	repeat with itemDivDict in ocidDivArray
		#名前をセット
		set strItemName to (itemDivDict's valueForKey:("name"))
		set ocidOutLineItemElement to (refMe's NSXMLElement's elementWithName:("outline"))
		(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("rss")))
		(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(strItemName)))
		(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(strItemName)))
		#URLをセット
		set strItemURL to (itemDivDict's valueForKey:("url")) as text
		set strSetURL to (strBaseURL & strItemURL) as text
		(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlUrl") stringValue:(strSetURL)))
		#リンクをセット
		set ocidSetURLString to (refMe's NSString's stringWithString:(strSetURL))
		##rssの部分のパスを削除して
		set ocidSetURL to (ocidSetURLString's stringByReplacingOccurrencesOfString:("/rss/") withString:("/"))
		set ocidURL to (refMe's NSURL's alloc()'s initWithString:(ocidSetURL))
		##XMLファイル名を削除して
		set ocidWebLinkURL to ocidURL's URLByDeletingLastPathComponent()
		##そのURLをセットする
		set strWebLinkURL to ocidWebLinkURL's absoluteString() as text
		(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("htmlUrl") stringValue:(strWebLinkURL)))
		##内側アイテムoutlineエレメントを　外側のoutlineエレメントにセットしていく
		(ocidOutLineDivElement's addChild:(ocidOutLineItemElement))
	end repeat
	#####外側のoutlineエレメントをbodyエレメントに追加
	(ocidBodyElement's addChild:(ocidOutLineDivElement))
end repeat
###bodyエレメントをROOTにセット
(ocidRootElement's addChild:(ocidBodyElement))
###【XML】↑からのROOTエレメントをセットしてXMLとする　【A】をXMLドキュメントにする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###XML形式のテキストに出力
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listDone to ocidSaveStrings's writeToURL:(ocidOpmlFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

return


