#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

###設定項目
set strBaseURL to ("https://www.nhk.or.jp/rss/news/") as text
##ファイル名デスクトップが保存先
set strSaveFileName to ("NHKOpml.opml") as text
##OPMLのタイトル
set strTitle to ("QuickTimerのOPML") as text
##outlineエレメント名＝feedlyだとフォルダ名
set strOutlineName to ("NHK RSS") as text
##ファイル名と名前をレコードにしておく
set recordFileName to {|主要|:"cat0.xml", |社会|:"cat1.xml", |文化|:"cat2.xml", |科学|:"cat3.xml", |政治|:"cat4.xml", |経済|:"cat5.xml", |国際|:"cat6.xml", |スポーツ|:"cat7.xml", |LIVE|:"cat-live.xml"} as record
##DICTに入れて
set ocidFileNameDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidFileNameDict's setDictionary:(recordFileName)
##キーリストにしておく
set ocidAllKeys to ocidFileNameDict's allKeys()
########################
##保存先パス
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
##保存ファイルパス
set ocidOpmlFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
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
##【A-C-2】bodyエレメントの外側のoutline＝フォルダ名になる
set ocidOutLineDivElement to (refMe's NSXMLElement's elementWithName:("outline"))
##外側のoutlineにネームスペース text とtitleを追加
(ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("rss")))
(ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(strOutlineName)))
(ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(strOutlineName)))
###【A-C-３】子要素 項目
repeat with itemAllKeyArray in ocidAllKeys
	##【A-C-３】子要素の各ITEM
	set ocidOutLineElement to (refMe's NSXMLElement's elementWithName:("outline"))
	##ネームスペース text とtitleを追加
	(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("rss")))
	(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(itemAllKeyArray)))
	(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemAllKeyArray)))
	#URLをセット
	set strItemURL to (ocidFileNameDict's valueForKey:(itemAllKeyArray)) as text
	set strSetURL to (strBaseURL & strItemURL) as text
	(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlUrl") stringValue:(strSetURL)))
	#リンクをセット
	(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("htmlUrl") stringValue:("https://www3.nhk.or.jp/news/")))
	#####外側のoutlineエレメントをbodyエレメントに追加
	(ocidOutLineDivElement's addChild:(ocidOutLineElement))
end repeat
##個別で１つだけ別でセット
set strRssURL to ("https://www.nhk.or.jp/blog-blog/last20.xml") as text
set strLinkURL to ("https://www.nhk.or.jp/blog-blog/") as text
set ocidOutLineElement to (refMe's NSXMLElement's elementWithName:("outline"))
(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("rss")))
(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:("BLOG")))
(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:("BLOG")))
(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlUrl") stringValue:(strRssURL)))
(ocidOutLineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("htmlUrl") stringValue:(strLinkURL)))
(ocidOutLineDivElement's addChild:(ocidOutLineElement))

###外側のOutLineをBodyにセットしてから
(ocidBodyElement's addChild:(ocidOutLineDivElement))
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


