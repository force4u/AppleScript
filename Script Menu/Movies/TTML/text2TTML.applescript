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

##設定項目
###カウントアップ値（１０分の１秒）
set numTimeInterval to 3.0 as number
###時間のスタート　１か０か
set numStartH to 1 as integer
#【A】ROOT
##指定のない場合は25 50 100 が計算しやすい
set strFPS to ("50") as text
#【B】HEAD共通のID
set strID to ("div01") as text
#【B−１】HEADのstyling
#"before" | "center" | "after" | "justify"
set strDisplayAlign to ("center") as text
set strTextColor to ("#ffffff") as text
# 0-1 0が完全透明　１が透明なし
set strTextOpacity to ("0.8") as text
set strTextOutline to ("#646364 1px") as text
#"left" | "center" | "right" | "start" | "end" | "justify"
set strTextAlign to ("center") as text
set strFontSize to ("100%") as text
#"default","monospace","sansSerif","serif","monospaceSansSerif","monospaceSerif","proportionalSansSerif","proportionalSerif"
set strFontFamily to ("proportionalSerif") as text
#"normal", "italic" ,"oblique"
set strFontStyle to ("italic") as text
#"normal" | "bold"
set strFontWeight to ("bold") as text

#【B−２】HEADのlayout
#前半の0%は固定　後半の値　100%が画面下部 0%が画面上部
set strOrigin to ("0% 90%") as text
# 他の値はYoutubeでは無用なので設定省略


#############################
##ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
############UTIリスト
set listUTI to {"public.text", "public.plain-text"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI without invisibles, multiple selections allowed and showing package contents) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###入力パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set strFileName to (ocidFilePathURL's lastPathComponent()) as text
########################
##テキスト読み込み
set listReadText to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidReadText to (item 1 of listReadText)
####行毎のリストにしておく
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet
set ocidReadTextArray to ocidReadText's componentsSeparatedByCharactersInSet:(ocidChrSet)
########################
##保存先パス
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
##保存ファイルパス
set strSaveFileName to (strFileName & ".ttml") as text
set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
########################
##TTMLの時間の初期化
set ocidDateComponents to refMe's NSDateComponents's alloc()'s init()
##時間を１でスタートする場合は１
ocidDateComponents's setHour:(numStartH)
ocidDateComponents's setMinute:0
ocidDateComponents's setSecond:0
###カレンダー初期化
set ocidCalendar to refMe's NSCalendar's currentCalendar()
###↑の時間をセット
set ocidTime to ocidCalendar's dateFromComponents:(ocidDateComponents)
###日付時間の書式設定
set ocidDateFormatter to refMe's NSDateFormatter's alloc()'s init()
(ocidDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US"))
(ocidDateFormatter's setDateFormat:"HH:mm:ss.SSS")
########################
##TTML生成開始
###【A】ROOT エレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:("tt")
###【A-1】ROOT エレメントにネームスペース
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("ttp:frameRate") stringValue:(strFPS))
# smpte clock media から　ビデオ編集用ならmediaが使いやすい
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("ttp:timeBase") stringValue:("media"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:lang") stringValue:("en"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns") stringValue:("http://www.w3.org/ns/ttml"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns:ttm") stringValue:("http://www.w3.org/ns/ttml#metadata"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns:tts") stringValue:("http://www.w3.org/ns/ttml#styling"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns:ttp") stringValue:("http://www.w3.org/ns/ttml#parameter"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns:ittp") stringValue:("http://www.w3.org/ns/ttml/profile/imsc1#parameter"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xmlns:itts") stringValue:("http://www.w3.org/ns/ttml/profile/imsc1#styling"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("ttp:profile") stringValue:("http://www.w3.org/ns/ttml/profile/imsc1/text"))
##################
###【B】head エレメント
set ocidHeadElement to refMe's NSXMLElement's alloc()'s initWithName:("head")
###【B-1】styling エレメント
set ocidStylingElement to refMe's NSXMLElement's alloc()'s initWithName:("styling")
###【B-1-1】styling エレメント
set ocidStyleElement to refMe's NSXMLElement's alloc()'s initWithName:("style")
set strStyleID to (strID & "s")
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:id") stringValue:(strStyleID))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:displayAlign") stringValue:(strDisplayAlign))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:color") stringValue:(strTextColor))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:opacity") stringValue:(strTextOpacity))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:fontSize") stringValue:(strFontSize))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:fontFamily") stringValue:(strFontFamily))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:fontStyle") stringValue:(strFontStyle))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:fontWeight") stringValue:(strFontWeight))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:textOutline") stringValue:(strTextOutline))
ocidStyleElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:textAlign") stringValue:(strTextAlign))
##	StyleをStylingにセット
(ocidStylingElement's addChild:(ocidStyleElement))
## Styling を　Headにセット
(ocidHeadElement's addChild:(ocidStylingElement))
###【B-2】layout エレメント
set ocidLayoutElement to refMe's NSXMLElement's alloc()'s initWithName:("layout")
###【B-2-1】region エレメント
set ocidRegionElement to refMe's NSXMLElement's alloc()'s initWithName:("region")
set strRegionID to (strID & "r")
ocidRegionElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:id") stringValue:(strRegionID))
ocidRegionElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:origin") stringValue:(strOrigin))
ocidRegionElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:extent") stringValue:("100% 0%"))
ocidRegionElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("tts:displayAlign") stringValue:("center"))
##	RegionをLayoutにセット
(ocidLayoutElement's addChild:(ocidRegionElement))
##	LayoutをHeadにセット
(ocidHeadElement's addChild:(ocidLayoutElement))
##	Headをrootエレメントにセット
(ocidRootElement's addChild:(ocidHeadElement))
##################
###【C】Body エレメント
set ocidBodyElement to refMe's NSXMLElement's alloc()'s initWithName:("body")
###【C-1】div エレメント divは複数設定可能なので　エレメント名に番号を入れる
set ocidDiv01Element to refMe's NSXMLElement's alloc()'s initWithName:("div")
ocidDiv01Element's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:id") stringValue:(strID))
ocidDiv01Element's addAttribute:(refMe's NSXMLNode's attributeWithName:("style") stringValue:(strStyleID))
ocidDiv01Element's addAttribute:(refMe's NSXMLNode's attributeWithName:("region") stringValue:(strRegionID))
###【C-1-1】ここが各行のテキストになる
repeat with itemReadText in ocidReadTextArray
	set ocidParagraphElement to (refMe's NSXMLElement's alloc()'s initWithName:("p"))
	set ocidSetNode to (refMe's NSXMLNode's textWithStringValue:(itemReadText))
	#各行のテキストデータ＝NODEをPにセット
	(ocidParagraphElement's addChild:(ocidSetNode))
	###時間を書式でテキスト化
	set ocidDateStrings to (ocidDateFormatter's stringFromDate:(ocidTime))
	##開始時間としてセット
	(ocidParagraphElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("begin") stringValue:(ocidDateStrings)))
	###日付時間の書式設定
	###タイムインターバルをセット
	set ocidNewDate to (ocidTime's dateByAddingTimeInterval:(numTimeInterval))
	###インターバル分追加した時間をテキストにして
	set ocidDateStrings to (ocidDateFormatter's stringFromDate:(ocidNewDate))
	##end時間としてセット
	(ocidParagraphElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("end") stringValue:(ocidDateStrings)))
	##加算された時間を次のリピートの開始時間とするためにセット
	set ocidTime to ocidNewDate
	##１行分のPデータを親要素のDIVにセットする
	(ocidDiv01Element's addChild:(ocidParagraphElement))
end repeat
##DIV要素をBODYにセット
(ocidBodyElement's addChild:(ocidDiv01Element))
##BODYをROOTエレメントにセット
(ocidRootElement's addChild:(ocidBodyElement))
##【D】保存
###【XML】↑からのROOTエレメントをセットしてXMLとする　【A】をXMLドキュメントにする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###XML形式のテキストに出力
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##上書きチェック
set ocidSaveFilePath to ocidSaveFilePathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveFilePath) isDirectory:(false)

if boolDirExists = true then
	set strMes to "上書きします？" as text
	try
		##ダイアログを前面に
		if strName is "osascript" then
			tell application "Finder" to activate
		else
			tell current application to activate
		end if
		set objResponse to (display alert strMes buttons {"上書きする", "処理を中止する"} default button "上書きする" cancel button "処理を中止する" as informational giving up after 10)
	on error
		log "処理を中止しました"
		return "処理を中止しました"
		error number -128
	end try
	if true is equal to (gave up of objResponse) then
		return "時間切れですやりなおしてください"
		error number -128
	end if
	if "上書きする" is equal to (button returned of objResponse) then
		log "上書き保存します"
	else if "処理を中止する" is equal to (button returned of objResponse) then
		return "処理を中止しました"
	else
		return "エラーしました"
		error number -128
	end if
else if boolDirExists = false then
	log "そのままファイル生成"
end if

##保存
set listDone to ocidSaveStrings's writeToURL:(ocidSaveFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

return


