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
set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
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
############UTIリスト
set listUTI to {"public.xml", "dyn.ah62d4rv4ge8086drru", "public.opml"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return "エラーしました"
end try

########################################
##本処理
repeat with itemAliasFilePath in listAliasFilePath
	###入力パス
	set strFilePath to (POSIX path of itemAliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	###ファイル読み込み
	set ocidOption to (refMe's NSXMLDocumentTidyXML)
	set listReadXMLDoc to (refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(ocidOption) |error|:(reference))
	###XMLドキュメント
	set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
	###ROOTエレメント
	set ocidRootElement to ocidReadXMLDoc's rootElement()
	set ocidHeadArray to (ocidRootElement's elementsForName:("head"))
	set listEntryArray to (ocidRootElement's nodesForXPath:("//head/title") |error|:(reference))
	set strTitle to (item 1 of listEntryArray)'s stringValue as text
	log strTitle
	###bodyエレメント
	set ocidBody to (ocidRootElement's elementsForName:("body"))'s firstObject()
	###outlineエレメント
	set ocidOutLineArray to (ocidBody's elementsForName:("outline"))
	repeat with itemOutLineArray in ocidOutLineArray
		set ocidTextAttr to (itemOutLineArray's attributeForName:("text"))
		if ocidTextAttr is not (missing value) then
			log ocidTextAttr's stringValue as text
		end if
		set ocidTitleAttr to (itemOutLineArray's attributeForName:("title"))
		if ocidTitleAttr is not (missing value) then
			log ocidTitleAttr's stringValue as text
		end if
		###outlineエレメントの子要素
		set ocidContentsArray to (itemOutLineArray's elementsForName:("outline"))
		repeat with itemContentsArray in ocidContentsArray
			set ocidContTextAttr to (itemContentsArray's attributeForName:("text"))
			set ocidContTypeAttr to (itemContentsArray's attributeForName:("type"))
			set ocidContTitleAttr to (itemContentsArray's attributeForName:("title"))
			set ocidContXmlUrlAttr to (itemContentsArray's attributeForName:("xmlUrl"))
			set ocidContHtmlUrlAttr to (itemContentsArray's attributeForName:("htmlUrl"))
			if ocidContTextAttr is not (missing value) then
				log ocidContTextAttr's stringValue as text
			end if
			if ocidContTypeAttr is not (missing value) then
				log ocidContTypeAttr's stringValue as text
			end if
			if ocidContTitleAttr is not (missing value) then
				log ocidContTitleAttr's stringValue as text
			end if
			if ocidContXmlUrlAttr is not (missing value) then
				log ocidContXmlUrlAttr's stringValue as text
			end if
			if ocidContHtmlUrlAttr is not (missing value) then
				log ocidContHtmlUrlAttr's stringValue as text
			end if
		end repeat
	end repeat
	
end repeat


