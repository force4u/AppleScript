#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

###設定項目
##ファイル名デスクトップが保存先
set strSaveFileName to ("Adobe Community ALL Post Opml.opml") as text
##OPMLのタイトル
set strTitle to ("QuickTimerのOPML") as text
##outlineエレメント名＝feedlyだとフォルダ名
set strOutlineName to ("Adobe Community JP All Post") as text


set listCategoryIDJp to {"ct-acrobat-reader-and-reader-mobile-jp", "ct-indesign-jp", "ct-illustrator-jp", "ct-after-effects-jp", "ct-acrobat-jp", "ct-photoshop-jp", "ct-premiere-elements-jp", "ct-premiere-pro-jp", "ct-fireworks-jp", "ct-adobe-express-jp", "ct-animate-jp", "ct-xd-jp", "ct-lightroom-classic-jp", "ct-photoshop-express-jp", "ct-lightroom-jp", "ct-video-hardware-jp", "ct-photoshop-elements-jp", "ct-premiere-rush-jp", "ct-media-encoder-jp", "ct-cc-services-jp", "ct-download-and-install-jp", "ct-stock-jp", "ct-fresco-jp", "ct-dreamweaver-jp", "ct-account-payment-and-plan-jp", "ct-perpetual-jp", "ct-bridge-jp", "ct-photoshop-beta-jp", "ct-audition-jp", "ct-community-help-jp", "ct-character-animator-jp", "ct-muse-jp", "ct-teams-jp", "ct-adbe-sign-and-dc-pdf-services-jp", "ct-fonts-jp", "ct-captivate-jp", "ct-adobe-scan-jp", "ct-camera-raw-jp", "ct-framemaker-jp", "ct-enterprise-jp", "ct-color-jp", "ct-robohelp-jp", "ct-dimension-jp", "ct-flash-player-and-shockwave-player-jp", "ct-photoshop-camera-jp", "ct-contribute-jp", "ct-photoshop-mix-jp", "ct-digital-editions-jp", "ct-comp-jp", "ct-spark-jp", "ct-capture-jp", "ct-prelude-jp", "ct-photoshop-sketch-jp", "ct-photoshop-fix-jp", "ct-air-jp", "ct-flex-and-flash-builder-jp", "ct-incopy-jp", "ct-japan-lounge-jp", "ct-illustrator-draw-jp"} as list
set ocidCategoryArray to refMe's NSArray's arrayWithArray:(listCategoryIDJp)
set ocidCategoryM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidCategoryM's setArray:(ocidCategoryArray)
set ocidSortedArray to ocidCategoryM's sortedArrayUsingSelector:("localizedCompare:")
set listCategoryIDJp to ocidSortedArray as list


############################################
##保存先
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
##保存ファイルパス
set ocidNewFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)

############################################
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

###【A-C-1】子要素
set ocidBodyElement to (refMe's NSXMLElement's alloc()'s initWithName:("body"))
##【A-C-2】bodyエレメントの外側のoutline＝フォルダ名になる
set ocidOutLineDivElement to (refMe's NSXMLElement's elementWithName:("outline"))
##外側のoutlineにネームスペース text とtitleを追加
ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(strOutlineName))
ocidOutLineDivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(strOutlineName))
##【A-C-D】内側のoutlineエレメントこれが本体

repeat with itemCategoryIDJp in listCategoryIDJp
	
	set ocidOutLineItemElement to (refMe's NSXMLElement's elementWithName:("outline"))
	(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("rss")))
	(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("text") stringValue:(itemCategoryIDJp)))
	(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemCategoryIDJp)))
	set strBaseURL to ("https://community.adobe.com/t5/" & itemCategoryIDJp & "/ct-p/" & itemCategoryIDJp & "") as text
	(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("htmlUrl") stringValue:(strBaseURL)))
	set strNewPostRssURL to ("https://community.adobe.com/havfw69955/rss/Category?category.id=" & itemCategoryIDJp & "&interaction.style=forum&feeds.replies=true") as text
	(ocidOutLineItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlUrl") stringValue:(strNewPostRssURL)))
	##内側アイテムoutlineエレメントを　外側のoutlineエレメントにセットしていく
	(ocidOutLineDivElement's addChild:(ocidOutLineItemElement))
end repeat

#####外側のoutlineエレメントをbodyエレメントに追加
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
set listDone to ocidSaveStrings's writeToURL:(ocidNewFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

