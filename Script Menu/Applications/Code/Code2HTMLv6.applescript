#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#v5 テキストファイルを後から開くようにした
#v5 HTMLのファイル名の日付を２４時間表記にした
#v6 １行目の表記を戻した
#v6 １行目の判定方法を変更した
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

##########################################
###保存先確保
##########################################
set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
set ocidSitesDirPathURL to ocidHomeDirURL's URLByAppendingPathComponent:("Sites") isDirectory:(true)
set ocidLocalizedFilePathURL to ocidSitesDirPathURL's URLByAppendingPathComponent:(".localized") isDirectory:(false)
set ocidLocalizedFilePath to ocidLocalizedFilePathURL's |path|()
set ocidSaveDirPathURL to ocidSitesDirPathURL's URLByAppendingPathComponent:("TemporaryItems") isDirectory:(true)
set ocidSaveDirPath to ocidSaveDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(ocidSaveDirPath) isDirectory:(true)
if boolExists = true then
	log "すでに保存先はあります"
else if boolExists = false then
	log "保存先が無いのでフォルダを作ります"
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSitesDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "フォルダの作成に失敗しました"
	end if
	ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "フォルダの作成に失敗しました"
	end if
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set boolDone to appFileManager's createFileAtPath:(ocidLocalizedFilePath) |contents|:("") attributes:(ocidAttrDict)
	if (boolDone) is (false) then
		return "Localizedファイルの作成に失敗しました"
	end if
end if
###テキストはテンポラリに保存ディレクトリ
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidTdirPathURL to ocidTempDirURL's URLByDeletingLastPathComponent()
set ocidTtmpDirPathURL to ocidTdirPathURL's URLByAppendingPathComponent:("TemporaryItems") isDirectory:(true)
set ocidTtmpDirPath to ocidTtmpDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(ocidTtmpDirPath) isDirectory:(true)
if boolExists = true then
	log "すでに保存先はあります"
else if boolExists = false then
	log "保存先が無いのでフォルダを作ります"
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidTtmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "フォルダの作成に失敗しました"
	end if
end if
###保存ファイルパス
set strTime to doGetDateNo("yyyyMMdd_HHmmss") as text
####ファイル名
set strHtmlFileName to ("" & strTime & ".html") as text
set strTextFileName to ("" & strTime & ".txt") as text
###パスURL
set ocidHTMLFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strHtmlFileName) isDirectory:(false)
set ocidTextFilePathURL to ocidTtmpDirPathURL's URLByAppendingPathComponent:(strTextFileName) isDirectory:(false)
##########################################
###ペーストボード
##########################################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
##中に格納されているデータタイプを取得
set ocidPastBoardTypeArray to ocidPasteboard's types
##TEXTを受け取る
set boolRTF to ocidPastBoardTypeArray's containsObject:("public.rtf")
set boolText to ocidPastBoardTypeArray's containsObject:("public.utf8-plain-text")
set boolHTML to ocidPastBoardTypeArray's containsObject:("public.html")
if boolText is true then
	set ocidPublicText to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeString)
	set ocidTextArray to ocidPublicText's componentsSeparatedByString:"\n"
	set ocidFirstLine to ocidTextArray's firstObject()
	set boolOsa to ocidFirstLine's containsString:("osascript")
else
	display alert "内容をコピーしてから実行してね（Visual Studio Code専用です。）"
	return "内容をコピーしてから実行してね（Visual Studio Code専用です。）"
end if
if boolHTML is true then
	set ocidPublicHTML to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeHTML)
else
	display alert "内容をコピーしてから実行してね（Visual Studio Code専用です。）"
	return "内容をコピーしてから実行してね（Visual Studio Code専用です。）"
end if
##########################################
######コピー用のテキストの事前置換　ここはお好み用
##########################################
#set ocidPublicText to doRegrExReplace(ocidPublicText, "#! /usr/bin/env osascript", "#! /usr/bin/env osascript")
#set ocidPublicText to doRegrExReplace(ocidPublicText, "#!/bin/bash", "#! /bin/bash")
set ocidPublicText to doRegrExReplace(ocidPublicText, "Appkit", "AppKit")


##########################################
######コピーボタン用　text
##########################################
###置換レコード
set recordEntityMap to {|&|:"&amp;", |<|:"&lt;", |>|:"&gt;", |"|:"&quot;", |'|:"&apos;", |=|:"&#x3D;", |+|:"&#x2B;", |\\|:"&bsol;", |$|:"&#36;"} as record
###ディクショナリにして
set ocidEntityMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordEntityMap)
###キーの一覧を取り出します
set ocidAllKeys to ocidEntityMap's allKeys()
###可変テキストにして
set ocidTextToEncode to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidTextToEncode's setString:(ocidPublicText)
###取り出したキー一覧を順番に処理
repeat with itemAllKey in ocidAllKeys
	##キーの値を取り出して
	set ocidMapValue to (ocidEntityMap's valueForKey:itemAllKey)
	##置換
	set ocidEncodedText to (ocidTextToEncode's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
	##次の変換に備える
	set ocidTextToEncode to ocidEncodedText
end repeat
####テキスト確定させて
set strEncodedText to ocidEncodedText as text
###HTMLのエレメントID用のランダム番号３桁
set num3Digit to random number from 100 to 999
###JAVAASCRIPT整形
set strJsText to ("<script>const elmentButtonCopy" & num3Digit & " = document.getElementById('buttonCopy" & num3Digit & "');const elmentInputText" & num3Digit & " = document.getElementById('inputText" & num3Digit & "');elmentButtonCopy" & num3Digit & ".addEventListener('click', () => {const strInputTextValue = elmentInputText" & num3Digit & ".value;return navigator.clipboard.writeText(strInputTextValue);})</script>\n") as text
###HTML整形
set strCopyHTML to ("<textarea id=\"inputText" & num3Digit & "\" type=\"text\" hidden readonly>" & strEncodedText & "</textarea>") as text
###ボタン用CSS
set strCopyBottonCSS to ("#buttonCopy" & num3Digit & "{background-color:#569cd6;border:none;color:white;padding:15px32px;text-align:center;text-decoration:none;display:inline-block;font-size:16px;margin:4px2px;cursor:pointer;border-radius:10px;}") as text
###出来上がり
set strCopyLinkText to (strCopyHTML & "<button id=\"buttonCopy" & num3Digit & "\">クリップボードへコピー</button>" & strJsText) as text
set strJsLinkText to ("<span class=\"javascript_botton\">" & strCopyLinkText & "</span>") as text

##########################################
######リンクボタン　AppleScript
##########################################
if boolOsa is true then
	########   %エンコードする
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	###ペーストボードの内容をキャラクタセットで変換
	set ocidTextEncodeAS to ocidPublicText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	###可変テキストに格納しておく
	set ocidEncodedText to refMe's NSMutableString's alloc()'s initWithCapacity:0
	ocidEncodedText's setString:(ocidTextEncodeAS)
	########   置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidPercentMap's valueForKey:itemAllKey)
		##置換
		set ocidEncodedText to (ocidEncodedText's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidTextToEncode to ocidEncodedText
	end repeat
	set strEncodedText to ocidTextToEncode as text
	##HTML生成
	set strAsLinkText to "<span class=\"openscript\"><a href=\"applescript://com.apple.scripteditor?action=new&name=com.cocolog-nifty.quicktimer&script=" & strEncodedText & "\" title=\"Open in Script Editor\" class=\"open-script-editor\">【スクリプトエディタで開く】</a></span>" as text
	set strLinkBotton to ("<p class=\"script-copy-botton\">" & strAsLinkText & "  |  " & strJsLinkText & "</p>") as text
else
	set strLinkBotton to ("<p class=\"script-copy-botton\">" & strJsLinkText & "</p>") as text
end if
##

##########################################
######本処理　開始
##########################################
##メタとDiv要素だけあらかじめ削除しておく
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "  ", "××××")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "<meta charset='utf-8'>", "")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "<br>", "\n")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "<div><span", "\n<span")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "</span></div>", "</span>")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "</span></div>", "</span>\n</div>")
set ocidPublicHTML to doRegrExReplace(ocidPublicHTML, "\n</div>", "")

#好みの追加
set ocidBaseHTML to (ocidPublicHTML's stringByReplacingOccurrencesOfString:("<span style=\"color: #d4d4d4;\">use ") withString:("<span style=\"color: #569cd6;\">use "))
set ocidBaseHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("<span style=\"color: #d4d4d4;\"> as ") withString:("<span style=\"color: #569cd6;\"> as "))
set ocidBaseHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("refMe's") withString:("</span><span style=\"color: #C55F8F;\">refMe's</span><span style=\"color: #d4d4d4;\">"))

set ocidStrRange to ocidBaseHTML's rangeOfString:(ocidBaseHTML)
ocidBaseHTML's replaceOccurrencesOfString:("(\\bNS\\w*?\\b)") withString:("</span><span style=\"color: #C55F8F;\">$1</span><span style=\"color: #d4d4d4;\">") options:(refMe's NSRegularExpressionSearch) range:(ocidStrRange)

set ocidBaseHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("set</span><span style=\"color: #d4d4d4;\"> ") withString:("set</span><span style=\"color: #F1EEC8;\">&#160;"))
set ocidBaseHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("<span style=\"color: #d4d4d4;\">return</span>") withString:("<span style=\"color: #569cd6;\">return</span>"))
set ocidBaseHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("|error|") withString:("</span><span style=\"color: #569cd6;\"> |error| </span><span style=\"color: #d4d4d4;\">"))

set ocidStrRange to ocidBaseHTML's rangeOfString:(ocidBaseHTML)
ocidBaseHTML's replaceOccurrencesOfString:("(\\bocid\\w*?\\b)") withString:("</span><span style=\"color: #F1EEC8;\">$1</span><span style=\"color: #d4d4d4;\">") options:(refMe's NSRegularExpressionSearch) range:(ocidStrRange)


set ocidPublicHTML to (ocidBaseHTML's stringByReplacingOccurrencesOfString:("\"> </span>") withString:("\">&#160;</span>"))
##########################################
#行毎のリストにしておく
set ocidCharSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidHTMLArray to ocidPublicHTML's componentsSeparatedByCharactersInSet:(ocidCharSet)
#一番外になるDIVをとっておく
set ocidOuterDiv to ocidHTMLArray's objectAtIndex:(0)
#その上で削除
ocidHTMLArray's removeObjectAtIndex:(0)
##########################################
######XML　テーブル生成開始
##########################################
if boolOsa is true then
	# タイトル　headerとタイトル用
	set strTitleText to ("AppleScript サンプルコード") as text
	#サブタイトル article
	set strSubTitle to ("AppleScript サンプルコード") as text
	#キャプション用のテキスト
	set strCaption to ("AppleScript サンプルソース（参考）") as text
else
	# タイトル　headerとタイトル用
	set strTitleText to ("サンプルコード") as text
	#サブタイトル article
	set strSubTitle to ("サンプルコード") as text
	#キャプション用のテキスト
	set strCaption to ("サンプルソース（参考）") as text
end if
##########################################
#headerに渡すエレメント
set ocidSetHeaderElement to (refMe's NSXMLElement's elementWithName:("div"))
set ocidH3Element to (refMe's NSXMLElement's elementWithName:("h3"))
##タイトルを入れる
(ocidH3Element's setStringValue:(strTitleText))
(ocidSetHeaderElement's addChild:(ocidH3Element))

########################################
#footerに渡すエレメント
set ocidSetFooterElement to (refMe's NSXMLElement's elementWithName:("div"))
set ocidPElement to (refMe's NSXMLElement's elementWithName:("p"))
set strContents to ("あくまでも参考にしてください") as text
(ocidPElement's setStringValue:(strContents))
(ocidSetFooterElement's addChild:(ocidPElement))

(*
#リンクをつける
set ocidAElement to (refMe's NSXMLElement's elementWithName:("a"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:("https://quicktimer.cocolog-nifty.com/"))
(ocidAElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
(ocidAElement's addAttribute:(ocidAddNode))
set strContents to ("AppleScriptで生成しました") as text
(ocidAElement's setStringValue:(strContents))
(ocidSetFooterElement's addChild:(ocidAElement))
##
set ocidButtonElement to (refMe's NSXMLElement's elementWithName:("button"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("id") stringValue:("closeWindow"))
(ocidButtonElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("close-botton"))
(ocidButtonElement's addAttribute:(ocidAddNode))
set strContents to ("ウィンドウを閉じる") as text
(ocidButtonElement's setStringValue:(strContents))
(ocidSetFooterElement's addChild:(ocidButtonElement))
#
set ocidScriptElement to (refMe's NSXMLElement's elementWithName:("script"))
(ocidScriptElement's setStringValue:("document.getElementById(\"closeWindow\").addEventListener(\"click\", function() {window.close();});"))
(ocidSetFooterElement's addChild:(ocidScriptElement))
*)

########################################
#articleに渡すエレメント
set ocidSetArticleElement to (refMe's NSXMLElement's elementWithName:("div"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("source-table-outer"))
(ocidSetArticleElement's addAttribute:(ocidAddNode))

set ocidH5Element to (refMe's NSXMLElement's elementWithName:("h5"))
(ocidH5Element's setStringValue:(strSubTitle))
(ocidSetArticleElement's addChild:(ocidH5Element))
#
set ocidPElement to (refMe's NSXMLElement's elementWithName:("p"))
(ocidPElement's setStringValue:("ボタン置換用のPタグ"))
(ocidSetArticleElement's addChild:(ocidPElement))


########################################
#テーブル部生成開始
set ocidTableElement to (refMe's NSXMLElement's elementWithName:("table"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("source-table"))
(ocidTableElement's addAttribute:(ocidAddNode))
########################################
#【caption】
set ocidCaptionElement to (refMe's NSXMLElement's elementWithName:("caption"))
(ocidCaptionElement's setStringValue:(strCaption))
(ocidTableElement's addChild:(ocidCaptionElement))
#######################
#【colgroup】
set ocidColgroupElement to (refMe's NSXMLElement's elementWithName:("colgroup"))
#######################
#【col】col生成
#項目番号
set ocidAddElement to (refMe's NSXMLElement's elementWithName:("col"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("LineNo"))
(ocidAddElement's addAttribute:(ocidAddNode))
(ocidColgroupElement's addChild:(ocidAddElement))
#値
set ocidAddElement to (refMe's NSXMLElement's elementWithName:("col"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("Source"))
(ocidAddElement's addAttribute:(ocidAddNode))
(ocidColgroupElement's addChild:(ocidAddElement))
#テーブルエレメントに追加
(ocidTableElement's addChild:(ocidColgroupElement))
########################################
#【thead】
set ocidTheadElement to (refMe's NSXMLElement's elementWithName:("thead"))
set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
#項目番号
set ocidAddElement to (refMe's NSXMLElement's elementWithName:("th"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("lineNo"))
(ocidAddElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("lineNo"))
(ocidAddElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("col"))
(ocidAddElement's addAttribute:(ocidAddNode))
(ocidAddElement's setStringValue:("行番号"))
(ocidTrElement's addChild:(ocidAddElement))
#値
set ocidAddElement to (refMe's NSXMLElement's elementWithName:("th"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("Source"))
(ocidAddElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("Source"))
(ocidAddElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("col"))
(ocidAddElement's addAttribute:(ocidAddNode))
(ocidAddElement's setStringValue:("ソース"))
(ocidTrElement's addChild:(ocidAddElement))
#TRをTHEADにセット
(ocidTheadElement's addChild:(ocidTrElement))
#THEADをテーブルにセット
(ocidTableElement's addChild:(ocidTheadElement))
########################################
#【tbody】
set ocidTbodyElement to (refMe's NSXMLElement's elementWithName:("tbody"))
#行番号初期化
set numLineNo to 1 as integer
#HTMLのソースの数だけ繰り返し
repeat with itemArray in ocidHTMLArray
	#行番号を３桁ゼロサプレス
	set ocidFormatter to refMe's NSNumberFormatter's alloc()'s init()
	(ocidFormatter's setMinimumIntegerDigits:(3))
	(ocidFormatter's setMaximumIntegerDigits:(3))
	set strLineNo to (ocidFormatter's stringFromNumber:(numLineNo)) as text
	#TRの開始
	set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
	####項番処理
	set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("項目番号 : " & strLineNo))
	(ocidThElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("headers") stringValue:("lineNo"))
	(ocidThElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("row"))
	(ocidThElement's addAttribute:(ocidAddNode))
	(ocidThElement's setStringValue:(strLineNo))
	(ocidTrElement's addChild:(ocidThElement))
	####値
	set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("Source"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("headers") stringValue:("Source"))
	(ocidTdElement's addAttribute:(ocidAddNode))
	#	ここで取得したHTMLからspanを挿入していく
	#	１行に複数のspanがあるのでspan毎に処理する
	set ocidReplacedStrings to (itemArray's stringByReplacingOccurrencesOfString:("</span><span") withString:("</span>\n<span"))
	set ocidLineItemArray to (ocidReplacedStrings's componentsSeparatedByCharactersInSet:(ocidCharSet))
	repeat with itemLine in ocidLineItemArray
		if (itemLine as text) is "" then
			log "改行のみの空行"
		else
			set listResponse to (refMe's NSXMLElement's alloc()'s initWithXMLString:(itemLine) |error|:(reference))
			if (item 2 of listResponse) ≠ (missing value) then
				log (item 2 of listResponse)'s localizedDescription() as text
				log itemArray as text
				return "HTMLの挿入に失敗しました"
			else if (item 2 of listResponse) = (missing value) then
				set ocidInsHTMLElement to (item 1 of listResponse)
			end if
			(ocidTdElement's addChild:(ocidInsHTMLElement))
		end if
	end repeat
	(ocidTrElement's addChild:(ocidTdElement))
	#
	(ocidTbodyElement's addChild:(ocidTrElement))
	####
	set numLineNo to numLineNo + 1 as integer
end repeat
#TBODYをテーブルにセット
(ocidTableElement's addChild:(ocidTbodyElement))
#【tfoot】 TRで
set ocidTfootElement to (refMe's NSXMLElement's elementWithName:("tfoot"))
set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
#colspan指定して１行でセット
set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("テーブルの終わり"))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("colspan") stringValue:("2"))
(ocidThElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("row"))
(ocidThElement's addAttribute:(ocidAddNode))
#
#リンクをつける
set ocidAElement to (refMe's NSXMLElement's elementWithName:("a"))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:("https://quicktimer.cocolog-nifty.com/icefloe/cat76053856/index.html"))
(ocidAElement's addAttribute:(ocidAddNode))
set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
(ocidAElement's addAttribute:(ocidAddNode))
set strContents to ("AppleScriptで生成しました") as text
(ocidAElement's setStringValue:(strContents))
(ocidThElement's addChild:(ocidAElement))
#
#(ocidThElement's setStringValue:("行数 : " & (numLineNo - 1) & ""))
#THをTRにセットして
(ocidTrElement's addChild:(ocidThElement))
#TRをTFOOTにセット
(ocidTfootElement's addChild:(ocidTrElement))
#TFOOTをテーブルにセット
(ocidTableElement's addChild:(ocidTfootElement))
#テーブルをアーティクルにセット
(ocidSetArticleElement's addChild:(ocidTableElement))

##########################################
#テキストファイルを生成する
##########################################
#テキストにして
set ocidTableXML to ocidSetArticleElement's XMLString()
#必要に応じて置換
set ocidReplacedStrings to (ocidTableXML's stringByReplacingOccurrencesOfString:("××××") withString:("  "))

#set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("#! /usr/bin/env osascript") withString:("#! /usr/bin/env osascript"))
#set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("#!/bin/bash") withString:("#! /bin/bash"))
set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("Appkit") withString:("AppKit"))
set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("  ") withString:("&#160;&#160;"))
set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("> </span>") withString:(">&#160;</span>"))
set ocidTableHTML to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("<p>ボタン置換用のPタグ</p>") withString:(strLinkBotton))

(*
set ocidSaveXMLStrings to doRegrExReplace(ocidTableXML, "××××", "  ")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "#! /usr/bin/env osascript", "#! /usr/bin/env osascript")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "#!/bin/bash", "#! /bin/bash")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "Appkit", "AppKit")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "  ", "&#160;&#160;")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "> </span>", ">&#160;</span>")
set ocidTableHTML to doRegrExReplace(ocidSaveXMLStrings, "<p>ボタン置換用のPタグ</p>", strLinkBotton)

*)

#CSS取得
set strCSS to doGetTextCss() as text
set strStyle to ("<style>" & strCSS & strCopyBottonCSS & "</style>") as text
#出力用テキスト
set ocidSaveTextStrings to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidSaveTextStrings's appendString:("<hr>")
ocidSaveTextStrings's appendString:(strStyle)
ocidSaveTextStrings's appendString:(ocidTableHTML)
ocidSaveTextStrings's appendString:("<hr>")

#######################
#テキストファイル保存
set listDone to ocidSaveTextStrings's writeToURL:(ocidTextFilePathURL) atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "HTMLの保存に失敗しまし"
else if (item 2 of listDone) = (missing value) then
	log "HTMLファイルを保存しました"
end if


##########################################
#HTMLファイルを生成する
##########################################
set ocidHTML to doMakeRootElement({ocidSetHeaderElement, ocidSetArticleElement, ocidSetFooterElement, strTitleText})
set ocidXMLString to ocidHTML's XMLString()
set ocidSaveXMLStrings to doRegrExReplace(ocidXMLString, "××××", "  ")
#set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "#! /usr/bin/env osascript", "#! /usr/bin/env osascript")
#set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "#!/bin/bash", "#! /bin/bash")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "Appkit", "AppKit")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "  ", "&nbsp;&nbsp;")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "> </span>", ">&nbsp;</span>")
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "<p>ボタン置換用のPタグ</p>", strLinkBotton)
set strRepText to (strCopyBottonCSS & "</style>") as text
set ocidSaveXMLStrings to doRegrExReplace(ocidSaveXMLStrings, "</style>", strRepText)


set listDone to ocidSaveXMLStrings's writeToURL:(ocidHTMLFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "HTMLの保存に失敗しまし"
else if (item 2 of listDone) = (missing value) then
	log "HTMLファイルを保存しました"
end if
##########################################
####保存先を開く
##########################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveDirPathURL)
if (boolDone) is (true) then
	log "正常終了" as text
	#		return "正常終了"
else if (boolDone) is (false) then
	return "ファイルの保存先を開けません"
end if

##########################################
####テキストファイルを後で開くようにした
##########################################

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidTextFilePathURL)
if (boolDone) is (true) then
	log "テキストファイル正常終了" as text
	return "テキストファイル正常終了"
else if (boolDone) is (false) then
	return "ファイルの保存先を開けません"
end if

return

##########################################
####CSS部分
##########################################
to doGetTextCss()
	set strCSS to ("@font-face {font-family: 'OsakaMonoLocal';src: url('file:///System/Library/AssetsV2/com_apple_MobileAsset_Font7/0818d874bf1d0e24a1fe62e79f407717792c5ee1.asset/AssetData/OsakaMono.ttf') format('truetype');}div.source-table-outer {margin: 5px;padding: 10px;background-color: #1e1e1e;color: #679AD1;max-width: 680px;}div.source-table-outer h5 {display: none;visibility: hidden;-webkit-user-select: none;user-select: none;}table.source-table {border-spacing: 0;caption-side: top;color: #679AD1;font-family: OsakaMonoLocal, Osaka-Mono, Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;}table.source-table caption {display: none;visibility: hidden;}table.source-table thead th {border: solid 1px #666666;padding: .5ch 1ch;border-block-width: 1px 1px;border-inline-width: 1px 0;-webkit-user-select: none;user-select: none;font-weight: normal;font-size: 10pt;&:first-of-type {border-start-start-radius: .5em}&:last-of-type {border-start-end-radius: .5em;border-inline-end-width: 1px}}table.source-table tbody th {border-spacing: 0;border-top: none;border-bottom: solid 1px #666666;border-left: solid 1px #666666;border-right: solid 1px #666666;padding: .5ch 1ch;font-weight: normal;border-block-width: 1px 0;border-inline-width: 1px 0;-webkit-user-select: none;user-select: none;font-size: 10pt;}table.source-table tbody td {max-width: 580px;word-wrap: break-word;border-spacing: 0;border-top: none;border-bottom: solid 1px #666666;border-left: solid 1px #666666;border-right: solid 1px #666666;padding-left: .5ch;padding-right: 1ch;border-block-width: 1px 0;border-inline-width: 1px 0;&:last-of-type {border-inline-end-width: 1px}}table.source-table tbody td span {font-size: 12pt;line-height: 12.5pt;}table.source-table tbody tr:nth-of-type(odd) {background-color: #2e2e2e;}.kind_string {font-size: 0.75em;}.date_string {font-size: 0.5em;}table.source-table tfoot th {border: solid 1px #666666;padding: .5ch 1ch;-webkit-user-select: none;user-select: none;font-weight: normal;&:first-of-type {border-end-start-radius: .5em}&:last-of-type {border-end-end-radius: .5em;border-inline-end-width: 1px}}table.source-table tfoot th a {color: #679AD1;}a.open-script-editor {color: #679AD1;-webkit-user-select: none;user-select: none;}#buttonCopy387 {background-color: #569cd6;border: none;color: white;padding: 15px32px;text-align: center;text-decoration: none;display: inline-block;font-size: 16px;margin: 4px2px;cursor: pointer;border-radius: 10px;-webkit-user-select: none;user-select: none;}") as text
	#
	return strCSS
end doGetTextCss

##########################################
####CSS部分
##########################################

to doGetAppendCss()
	set strCSS to ("body {margin: 10px;background-color: #1e1e1e;font-family: OsakaMonoLocal, Osaka-Mono, Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;font-weight: 400;font-size: 12pt;color: #679AD1;}header {font-family: OsakaMonoLocal, Osaka-Mono, Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;-webkit-user-select: none;user-select: none;}article {font-family: OsakaMonoLocal, Osaka-Mono, Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;}footer {font-family: OsakaMonoLocal, Osaka-Mono, Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;-webkit-user-select: none;user-select: none;}footer a {color: #679AD1;}#closeWindow {background-color: #569cd6;border: none;color: white;padding: 15px32px;text-align: center;text-decoration: none;display: inline-block;font-size: 16px;margin: 4px2px;cursor: pointer;border-radius: 10px;-webkit-user-select: none;user-select: none;}") as text
	return strCSS
end doGetAppendCss

##########################################
####HTMLの置換　正規表現
##########################################
to doRegrExReplace(argText, argReplaceString, argWithString)
	set ocidReturnText to refMe's NSMutableString's alloc()'s initWithCapacity:0
	ocidReturnText's setString:(argText)
	###レンンジを取って(元データの元データのレンジ＝最初から最後まで)
	set ocidArgTextRange to ocidReturnText's rangeOfString:(ocidReturnText)
	###置換
	ocidReturnText's replaceOccurrencesOfString:(argReplaceString) withString:(argWithString) options:(refMe's NSRegularExpressionSearch) range:(ocidArgTextRange)
	return ocidReturnText
end doRegrExReplace


##########################################
####日付情報の取得
##########################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo




############################################################
# 基本的なHTMLの構造
(*
doMakeRootElement({argHeaderContents, argArticleContents, argFooterContents,argTitleText})
HTMLのBODY部
header
article
footerにそれぞれAddchildするデータをリストで渡す
戻り値はRootエレメントにセットされた
NSXMLDocumentを戻すので　保存すればOK
*)
############################################################
to doMakeRootElement({argHeaderContents, argArticleContents, argFooterContents, argTitleText})
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
	ocidAddElement's setStringValue:(argTitleText)
	ocidHeadElement's addChild:(ocidAddElement)
	# http-equiv
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("http-equiv") stringValue:("Content-Type")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("text/html; charset=UTF-8")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	(*
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
	*)
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("meta")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("name") stringValue:("viewport")
	ocidAddElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("content") stringValue:("width=740")
	ocidAddElement's addAttribute:(ocidAddNode)
	ocidHeadElement's addChild:(ocidAddElement)
	#
	set strCSS to doGetTextCss()
	set strAppendCss to doGetAppendCss()
	set strSetCSS to (strAppendCss & strCSS) as text
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("style")
	ocidAddElement's setStringValue:(strSetCSS)
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

