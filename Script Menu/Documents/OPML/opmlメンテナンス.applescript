#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	OPMLの４０４見つからない　と　３００移動をリストにします
#　項目の削除もできます
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###設定項目
# 404ステータスのRSSを削除するか？
set boolDel404 to true as boolean
# 30xステータスのRSSを削除するか？
set boolDel300 to false as boolean


#############################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell

############UTIリスト
set listUTI to {"public.xml", "public.rss", "public.opml", "dyn.ah62d4rv4ge8086drru"}

set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
####################
#【保存】パス
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
set ocidSaveFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("edit.opml")
set ocid404FilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("404リスト.txt")
set ocid301FilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("301リスト.txt")
####################
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to (refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(ocidOption) |error|:(reference))
###XMLドキュメント
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOTエレメント
set ocidRootElement to ocidReadXMLDoc's rootElement()
set ocidHeadElement to (ocidRootElement's elementsForName:("head"))'s firstObject()
set ocidHeadCopy to ocidHeadElement's XMLString()
###bodyエレメント
set ocidBody to (ocidRootElement's elementsForName:("body"))'s firstObject()
set ocidBodyCopy to ocidBody's XMLString()

####################
#【保存】XML初期化
set ocidSaveXMLDoc to refMe's NSXMLDocument's alloc()'s init()
ocidSaveXMLDoc's setVersion:("1.0")
ocidSaveXMLDoc's setCharacterEncoding:("utf-8")
ocidSaveXMLDoc's setDocumentContentKind:(refMe's NSXMLDocumentXMLKind)
#【保存】ROOT
set ocidSaveRootElement to refMe's NSXMLElement's elementWithName:("opml")
set ocidAddNode to refMe's NSXMLNode's attributeWithName:("version") stringValue:("1.0")
ocidSaveRootElement's addAttribute:(ocidAddNode)
#【保存】HEAD
set ocidSaveHeadElement to refMe's NSXMLElement's alloc()'s initWithXMLString:(ocidHeadCopy) |error|:(missing value)
#【保存】BODY
set ocidSaveBodyElement to refMe's NSXMLElement's alloc()'s initWithXMLString:(ocidBodyCopy) |error|:(missing value)
####################
set numCntBodyChild to ocidSaveBodyElement's childCount() as integer
set list404 to {} as list
set list300 to {} as list
###親＝フォルダ　の数だけ繰り返し
repeat with itemIntNo from 0 to (numCntBodyChild - 1) by 1
	set ocidOutLineParent to (ocidSaveBodyElement's childAtIndex:(itemIntNo))
	set numCntOutLineParent to ocidOutLineParent's childCount() as integer
	###子＝各RSSのURL要素の数だけ繰り返し
	repeat with itemIntCildNo from (numCntOutLineParent - 1) to 0 by -1
		set ocidOutLineChild to (ocidOutLineParent's childAtIndex:(itemIntCildNo))
		set ocidContXmlUrlAttr to (ocidOutLineChild's attributeForName:("xmlUrl"))
		set ocidXMLURL to ocidContXmlUrlAttr's stringValue()
		set ocidURLString to (refMe's NSString's stringWithString:(ocidXMLURL))
		#302対策でHTTPをHTTPSに置き換えておく
		set ocidSetURL to (ocidURLString's stringByReplacingOccurrencesOfString:("http:") withString:("https:"))
		set ocidURL to (refMe's NSURL's alloc()'s initWithString:(ocidSetURL))
		#生存確認
		set strURL to ocidURL's absoluteString() as text
		set strCommandText to ("/usr/bin/curl -s -o /dev/null -w \"%{http_code}\" \"" & strURL & "\" --connect-timeout 5 --max-time 10") as text
		try
			set strResponse to (do shell script strCommandText) as text
		on error
			#ドメイン落ちしている場合
			set strResponse to ("404") as text
		end try
		if strResponse is "404" then
			set end of list404 to strURL
			if boolDel404 is true then
				#対象の子要素を削除
				(ocidOutLineParent's removeChildAtIndex:(itemIntCildNo))
			end if
		else if strResponse is "301" then
			set end of list300 to strURL
			if boolDel300 is true then
				#対象の子要素を削除
				(ocidOutLineParent's removeChildAtIndex:(itemIntCildNo))
			end if
		else if strResponse is "302" then
			set end of list300 to strURL
			if boolDel300 is true then
				#対象の子要素を削除
				(ocidOutLineParent's removeChildAtIndex:(itemIntCildNo))
			end if
		end if
		
	end repeat
	
end repeat
####################
#別に取得した４０４リストと３００リストをテキストで保存
##リストを改行区切りテキストに変更
set ocid404Array to refMe's NSArray's arrayWithArray:(list404)
set ocid301Array to refMe's NSArray's arrayWithArray:(list300)
set ocid404Text to ocid404Array's componentsJoinedByString:("\n")
set ocid301Text to ocid301Array's componentsJoinedByString:("\n")
#保存
set listDone to ocid404Text's writeToURL:(ocid404FilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set listDone to ocid301Text's writeToURL:(ocid301FilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####################
#編集済みのエレメントをテキストにして
set ocidEditBody to ocidSaveBodyElement's XMLString()
#編集済みエレメントにしてから
set listEditBodyElement to refMe's NSXMLElement's alloc()'s initWithXMLString:(ocidEditBody) |error|:(reference)
set ocidEditBodyElement to (item 1 of listEditBodyElement)
##rootにセットして
ocidSaveRootElement's addChild:(ocidSaveHeadElement)
ocidSaveRootElement's addChild:(ocidEditBodyElement)
ocidSaveXMLDoc's setRootElement:(ocidSaveRootElement)
##########
#【保存】読み取りやすい表示
set ocidXMLdata to ocidSaveXMLDoc's XMLDataWithOptions:(refMe's NSXMLNodePrettyPrint)
#保存
set listDone to ocidXMLdata's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
