#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
sitemap_static.xmlへのリンクを記述したXML生成
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


#############################
### 設定項目
set listURL to {"https://foo.hoge.com/contents/sitemap_static.xml", "https://foo.hoge.com/sitemap_static.xml"} as list

#############################
###　ここから本処理
###◆ sitemapindex
##ファイルパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set ocidContainerFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:("sitemap.xml") isDirectory:false
###【A】ROOT エレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"sitemapindex"
###【A-1】ROOT エレメントにネームスペース
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("https://www.sitemaps.org/schemas/sitemap/0.9"))
##リストの数だけ繰り返し
repeat with itemURL in listURL
	
	###【B】子要素　sitemap　エレメント
	set ocidSitemapElement to (refMe's NSXMLElement's alloc()'s initWithName:("sitemap"))
	
	###【C】Bの子要素としてのloc　エレメント
	set ocidLocElement to (refMe's NSXMLElement's elementWithName:("loc"))
	###【C】にテキストの値を設定
	(ocidLocElement's setStringValue:(itemURL))
	
	###【D】Bの子要素としてのlastmod　エレメント
	set ocidLastmodElement to (refMe's NSXMLElement's elementWithName:("lastmod"))
	###【D】にテキストの値を設定
	set strDateNo to doGetDateNo("yyyy-MM-dd")
	(ocidLastmodElement's setStringValue:(strDateNo))
	
	###【E】Bの子要素としてのchangefreq　エレメント
	set ocidChangefreqElement to (refMe's NSXMLElement's elementWithName:("changefreq"))
	###【E】にテキストの値を設定
	(*
always
hourly
daily
weekly
monthly
yearly
never
*)
	(ocidChangefreqElement's setStringValue:("yearly"))
	
	
	###【F】Bの子要素としてのpriority　エレメント
	set ocidPriorityElement to (refMe's NSXMLElement's elementWithName:("priority"))
	###【F】にテキストの値を設定
	(ocidPriorityElement's setStringValue:("0.5"))
	
	
	##　子要素をセット【B】に追加
	(ocidSitemapElement's addChild:(ocidLocElement))
	(ocidSitemapElement's addChild:(ocidLastmodElement))
	(ocidSitemapElement's addChild:(ocidChangefreqElement))
	(ocidSitemapElement's addChild:(ocidPriorityElement))
	##　↑からの子要素をセット　【B】を【A】に追加
	(ocidRootElement's addChild:(ocidSitemapElement))
end repeat


##　↑からのROOTエレメントをセットしてXMLとする　【A】をXMLドキュメントにする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###XML形式のテキストに出力
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listDone to ocidSaveStrings's writeToURL:(ocidContainerFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

return


##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
