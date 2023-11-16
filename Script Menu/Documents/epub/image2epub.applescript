#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
自炊用
画像ファイル＝各ページ　で
EPUBのコンテンツを生成します
出来上がったフォルダを
[ドロップレット]EPUB用zip圧縮（半角スペース対応）
https://quicktimer.cocolog-nifty.com/icefloe/2023/11/post-c6729c.html
で
圧縮してEPUBの出来上がりになります
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


#############################
### 設定項目
###タイトル
set strDocumentTitle to ("ドキュメントのタイトル") as text

###一般的には著者　または　作成者
set strAuthor to ("com.cocolog-nifty.quicktimer") as text

###表紙のラベル (この設定は表紙なしなので設定しなくてもOK)
set strLabelTitle to ("表紙") as text

###表紙ページを付与するか trueで表紙ページあり　falseで表紙ページなし
set boolCoverPage to true as boolean

### 左開き？ ltr (left-to-right) 右開き？ rtl (right-to-left) 
set strPageProgression to ("rtl") as text

###見開き調整 trueで表紙をコンテンツから抜いて１ページずらします
##見開きページがズレる場合に true を入れてください
set boolProgression to false as boolean


#############################
###　ここから本処理
(*
大まかな手順
【１】ROOT　フォルダ：META-INF　OPS　ファイル：mimetype
【１−２】mimetype

【２】META-INF　ファイル：　container.xml　com.apple.ibooks.display-options.xml
【２−１】container.xml
【２−２】com.apple.ibooks.display-options.xml

【３】OPS
【３−１】css　book.css
【３−２】js			book.js
【３−３】images
【３−４】toc.ncx
【３−５】content.opf
【３−６】toc.xhtml
【３−７】page-XXXX.xhtml
【３−８】cover.xhtml
*)
######
##設定項目（詳細）
##XMLファイル名の接頭語
set strBaseFileName to ("page-") as text
##コピー後のファイル名の接頭名　コピー後のファイル名を固定にする事で後処理を少し簡素化
set strBaseImageFileName to ("Image_") as text


#############################
###ドキュメントのUUID
set ocidUUID to refMe's NSUUID's alloc()'s init()
set strUUID to ocidUUID's UUIDString as text

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
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
set listUTI to {"public.image"}
set strMes to ("画像ファイルを選んでください") as text
set strPrompt to ("画像ファイルを選んでください") as text
try
	###　ファイル選択
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if listAliasFilePath is {} then
	return "選んでください"
end if

##パス 保存先パス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
###デスクトップ
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
###設定項目の名称がフォルダ名
set ocidEpubDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strDocumentTitle)
set ocidEpubDirPath to ocidEpubDirPathURL's |path|()
##############################
##必要なフォルダを作る
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
##アクセス権755この値は後でも使う
(ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions))
##フォルダのパスのリスト
set listDirName to {"OPS", "OPS/css", "OPS/images", "OPS/js", "META-INF"} as list
##stringsByAppendingPathsでARRAYにする
set ocidSubPathArray to ocidEpubDirPath's stringsByAppendingPaths:(listDirName)
##ARRAYの分だけ
repeat with itemSubPathArray in ocidSubPathArray
	##フォルダを作る
	set listBoolMakeDir to (appFileManager's createDirectoryAtPath:(itemSubPathArray) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
end repeat
#################################################################################
###	【１】ROOT　フォルダ：META-INF　OPS　ファイル：mimetype
set ocidEpubDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidEpubDirPath) isDirectory:true)
###	【１−２】mimetype
##保存先パス
set ocidMimetypeFilePathURL to ocidEpubDirPathURL's URLByAppendingPathComponent:("mimetype") isDirectory:false
##内容
set strMimetype to ("application/epub+zip") as text
set ocidMimetype to refMe's NSString's stringWithString:(strMimetype)
##ファイルに保存して
set listDone to ocidMimetype's writeToURL:(ocidMimetypeFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
##アクセス権755を指定する
set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidMimetypeFilePathURL's |path|) |error|:(reference)
#################################################################################
###	【３】OPS
set ocidOPSDirPathURL to ocidEpubDirPathURL's URLByAppendingPathComponent:("OPS") isDirectory:true
######◆ 【３−１】css　book.css
##フォルダのパス
set ocidCssDirPathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("css") isDirectory:true
###ファイルのパス
set ocidCssFilePathURL to ocidCssDirPathURL's URLByAppendingPathComponent:("book.css") isDirectory:false
##ファイルの中身
set strCssContents to ("body { margin: 0; padding: 0; border: 0;}") as text
set ocidCssContents to refMe's NSString's stringWithString:(strCssContents)
##保存
set listDone to ocidCssContents's writeToURL:(ocidCssFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
##アクセス権
set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidCssFilePathURL's |path|) |error|:(reference)
######◆	【３−２】js			book.js
##フォルダのパス
set ocidJsDirPathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("js") isDirectory:true
###ファイルのパス
set ocidJsFilePathURL to ocidJsDirPathURL's URLByAppendingPathComponent:("book.js") isDirectory:false
##ファイルの中身
set strJsContents to ("function Body_onLoad() {}") as text
set ocidJsContents to refMe's NSString's stringWithString:(strJsContents)
##保存
set listDone to ocidJsContents's writeToURL:(ocidJsFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
##アクセス権
set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidJsFilePathURL's |path|) |error|:(reference)
######◆ 【３−３】images イメージファイルをコピーします
set ocidImagesDirPathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("images") isDirectory:true

set numCntPage to 1 as integer
set numCntAllImage to (count of listAliasFilePath) as integer
set listImageFileName to {} as list
##画像ファイルの数だけ繰り返し
repeat with itemAliasFilePath in listAliasFilePath
	##パス
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	##拡張子
	set ocidExtensionName to ocidFilePathURL's pathExtension()
	###コピー後の画像ファイルは連番処理　四桁のゼロサプレス
	set strZeroSup to "0000" as text
	set strSeroSup to (strZeroSup & (numCntPage as text)) as text
	set strSeroSup to (text -4 through -1 of strSeroSup) as text
	set strFileName to (strBaseImageFileName & strSeroSup) as text
	##コピー先URL
	set ocidBaseFilePathURL to (ocidImagesDirPathURL's URLByAppendingPathComponent:(strFileName))
	set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:(ocidExtensionName))
	##ファイル名のリストを作っておく
	set ocidImageFileName to ocidSaveFilePathURL's lastPathComponent()
	set strImageFileName to ocidImageFileName as text
	set end of listImageFileName to strImageFileName
	###コピー
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listDone to (appFileManager's copyItemAtURL:(ocidFilePathURL) toURL:(ocidSaveFilePathURL) |error|:(reference))
	##カウントアップ
	set numCntPage to numCntPage + 1 as integer
end repeat


#################################
###◆ 【３−７】page-XXXX.xhtml
##配置オブジェクトが画像１つ限定なのでシンプルな構造
##【３−７−A】　root エレメント 【３−７−B】　head エレメント　【３−７−C】　body　エレメント
##カウンター
set numCntPage to 1 as integer
##総画像ファイルする右＝ページ数
set numCntAllImage to (count of listAliasFilePath) as integer
##画像の数だけ繰り返し
repeat numCntAllImage times
	###ファイルは連番処理　四桁のゼロサプレス
	set strZeroSup to "0000" as text
	set strSeroSup to (strZeroSup & (numCntPage as text)) as text
	set strSeroSup to (text -4 through -1 of strSeroSup) as text
	set strFileName to (strBaseFileName & strSeroSup & ".xhtml") as text
	##XHTMLのパス
	set ocidXHTMLFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
	##配置画像
	##不具合の元かもしれないが拡張子判定する方法が見つからなかった
	set strImageName to (item numCntPage of listImageFileName)
	set ocidImagesFilePathURL to ocidImagesDirPathURL's URLByAppendingPathComponent:(strImageName) isDirectory:false
	set ocidReadImage to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL))
	##BitMapRepに変換
	set ocidReadImageRepArray to ocidReadImage's representations()
	set ocidReadImageRep to (ocidReadImageRepArray's objectAtIndex:0)
	##ピクセルサイズ取得
	set strPixelsWidth to (ocidReadImageRep's pixelsWide()) as text
	set strPixelsHeight to (ocidReadImageRep's pixelsHigh()) as text
	########
	##◆【３−７−A】　root エレメント 
	set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"html"
	ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:lang") stringValue:("ja"))
	ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("http://www.w3.org/1999/xhtml"))
	########
	##◆【３−７−B】　head エレメント
	set ocidHeadElement to refMe's NSXMLElement's alloc()'s initWithName:("head")
	#CSS
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("link")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("rel") stringValue:("stylesheet"))
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("css/book.css"))
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("text/css"))
	ocidHeadElement's addChild:(ocidMetaElement)
	#JS
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("script")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:("js/book.js"))
	ocidHeadElement's addChild:(ocidMetaElement)
	#文字コード
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("charset") stringValue:("UTF-8"))
	ocidHeadElement's addChild:(ocidMetaElement)
	#タイトル
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("title")
	set strPageTitle to ("Page : " & strSeroSup) as text
	ocidMetaElement's setStringValue:(strPageTitle)
	ocidHeadElement's addChild:(ocidMetaElement)
	#EPUBドキュメントのUUID
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("EPB-UUID"))
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strUUID))
	ocidHeadElement's addChild:(ocidMetaElement)
	#ビューポイント　ここで画像のサイズ指定＝全画面
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("viewport"))
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:("width=" & strPixelsWidth & ",height=" & strPixelsHeight & ", initial-scale=1.0"))
	ocidHeadElement's addChild:(ocidMetaElement)
	########
	##◆【３−７−C】　body　エレメント
	set ocidBodyElement to refMe's NSXMLElement's alloc()'s initWithName:("body")
	ocidBodyElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("onload") stringValue:("Body_onLoad()"))
	#開き方向指定
	ocidBodyElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("dir") stringValue:(strPageProgression))
	#一番外側のDIV要素
	set ocidOutDiivElement to refMe's NSXMLElement's alloc()'s initWithName:("div")
	ocidOutDiivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("style") stringValue:("position:absolute;left:0;top:0;width: " & strPixelsWidth & "px;height:" & strPixelsHeight & "px;"))
	#imgタグ
	set ocidImgElement to refMe's NSXMLElement's alloc()'s initWithName:("img")
	set strPath to ("images/" & strImageName) as text
	ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:(strPath))
	ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("alt") stringValue:(strFileName))
	ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("style") stringValue:("object-fit: cover;width: " & strPixelsWidth & "px;height:" & strPixelsHeight & "px;"))
	#imgタグをDIVにセット
	ocidOutDiivElement's addChild:(ocidImgElement)
	#DIVをbodyにセット
	ocidBodyElement's addChild:(ocidOutDiivElement)
	########
	##【３−７−B】のheadエレメントをAのROOTにセット
	ocidRootElement's addChild:(ocidHeadElement)
	##【３−７−C】　bodyエレメントをAのROOTにセット
	ocidRootElement's addChild:(ocidBodyElement)
	##　↑からのROOTエレメントをセットしてXMLとする
	set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
	ocidOutPutXML's setVersion:"1.0"
	ocidOutPutXML's setCharacterEncoding:"UTF-8"
	#XMLをテキストにして
	set ocidSaveStrings to ocidOutPutXML's XMLString()
	###改行コードを指定して
	ocidSaveStrings's appendString:"\n"
	##保存
	set listWritetoUrlArray to ocidSaveStrings's writeToURL:(ocidXHTMLFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
	##
	set numCntPage to numCntPage + 1 as integer
end repeat

#################################
###◆【３−８】cover.xhtml　いわゆる表紙ページ
# cover-page と　cover-imageがあるがここではcover-pageを生成する
#保存パス
set ocidXHTMLFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("cover.xhtml") isDirectory:false
# 表紙イメージ＝１ページ目の画像
set aliasCoverImageFilePath to (item 1 of listAliasFilePath) as alias
set strCoverImageFilePath to (POSIX path of aliasCoverImageFilePath) as text
set ocidCoverImageFilePathStr to refMe's NSString's stringWithString:(strCoverImageFilePath)
set ocidCoverImageFilePath to ocidCoverImageFilePathStr's stringByStandardizingPath()
set ocidCoverImageFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidCoverImageFilePath) isDirectory:false)
set strExtensionName to (ocidCoverImageFilePathURL's pathExtension()) as text
###
set ocidReadImage to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidCoverImageFilePathURL))
##BitMapRepに変換
set ocidReadImageRepArray to ocidReadImage's representations()
set ocidReadImageRep to (ocidReadImageRepArray's objectAtIndex:0)
##ピクセルサイズ取得
set strPixelsWidth to (ocidReadImageRep's pixelsWide()) as text
set strPixelsHeight to (ocidReadImageRep's pixelsHigh()) as text
#######【３−８-A】ルートエレメント　XHTMLのルートエレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"html"
#ネームスペースの追加
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("http://www.w3.org/1999/xhtml"))
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("epub") stringValue:("http://www.idpf.org/2007/ops"))
#アトリビュートの追加
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:lang") stringValue:("ja"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("epub:prefix") stringValue:("ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/"))
#####【３−６-B】 headエレメント
set ocidHeadElement to refMe's NSXMLElement's alloc()'s initWithName:("head")
#タイトル
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("title")
ocidMetaElement's setStringValue:("表紙：Cover Page")
ocidHeadElement's addChild:(ocidMetaElement)
#スタイルシートへのリンク
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("link")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("rel") stringValue:("stylesheet"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("css/book.css"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("text/css"))
ocidHeadElement's addChild:(ocidMetaElement)
#Jsへのリンク
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("script")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:("js/book.js"))
ocidHeadElement's addChild:(ocidMetaElement)
#文字コード宣言
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("charset") stringValue:("UTF-8"))
ocidHeadElement's addChild:(ocidMetaElement)
#UUID設定
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("EPB-UUID"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strUUID))
ocidHeadElement's addChild:(ocidMetaElement)
#ビューポイント
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("viewport"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:("width=" & strPixelsWidth & ",height=" & strPixelsHeight & ", initial-scale=1.0"))
ocidHeadElement's addChild:(ocidMetaElement)
######【３−８-C】ボディエレメント
set ocidBodyElement to refMe's NSXMLElement's alloc()'s initWithName:("body")
ocidBodyElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("onload") stringValue:("Body_onLoad()"))
#開き方向
ocidBodyElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("dir") stringValue:(strPageProgression))
#
set ocidOutDiivElement to refMe's NSXMLElement's alloc()'s initWithName:("div")
ocidOutDiivElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("style") stringValue:("position:absolute;left:0;top:0;width: " & strPixelsWidth & "px;height:" & strPixelsHeight & "px;"))
##
set ocidImgElement to refMe's NSXMLElement's alloc()'s initWithName:("img")
set strImageName to (strBaseImageFileName & "0001." & strExtensionName) as text
set strPath to ("images/" & strImageName) as text
ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:(strPath))
ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("alt") stringValue:(strFileName))
ocidImgElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("style") stringValue:("object-fit: cover;width: " & strPixelsWidth & "px;height:" & strPixelsHeight & "px;"))
ocidOutDiivElement's addChild:(ocidImgElement)
ocidBodyElement's addChild:(ocidOutDiivElement)
####
#【３−８-B】 head を【３−８-A】 ルートエレメントに追加
ocidRootElement's addChild:(ocidHeadElement)
#【３−８-C】 body を【３−８-A】ルートエレメントに追加
ocidRootElement's addChild:(ocidBodyElement)
##　↑からのROOTエレメントをセットしてXMLとする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###テキストにして
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listDone to ocidSaveStrings's writeToURL:(ocidXHTMLFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
#################################
###◆ 【３−６】toc.xhtml　いわゆる目次
#【３−６-B】 head 【３−６-C】 body 
#保存パス
set ocidXHTMLFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("toc.xhtml") isDirectory:false
#【３−６-A】ルートエレメント　XHTMLのルートエレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"html"
#ネームスペースの追加
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("http://www.w3.org/1999/xhtml"))
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("epub") stringValue:("http://www.idpf.org/2007/ops"))
#アトリビュートの追加
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("xml:lang") stringValue:("ja"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("epub:prefix") stringValue:("ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/"))
#####【３−６-B】 headエレメント
set ocidHeadElement to refMe's NSXMLElement's alloc()'s initWithName:("head")
#タイトル
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("title")
ocidMetaElement's setStringValue:("目次：Table of Contents")
ocidHeadElement's addChild:(ocidMetaElement)
#スタイルシートへのリンク
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("link")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("rel") stringValue:("stylesheet"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("css/book.css"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("text/css"))
ocidHeadElement's addChild:(ocidMetaElement)
#文字コード宣言
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("charset") stringValue:("UTF-8"))
ocidHeadElement's addChild:(ocidMetaElement)
#UUID設定
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("EPB-UUID"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strUUID))
ocidHeadElement's addChild:(ocidMetaElement)
#ビューポイント
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("viewport"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:("width=device-width, initial-scale=1.0"))
ocidHeadElement's addChild:(ocidMetaElement)
####【３−６-C】 body 
set ocidBodyElement to refMe's NSXMLElement's alloc()'s initWithName:("body")
#bodyエレメントに開き方向のアトリビュート
ocidBodyElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("dir") stringValue:(strPageProgression))
#タイトルをH1で入れて
set ocidBodyItem to refMe's NSXMLElement's alloc()'s initWithName:("h1")
ocidBodyItem's setStringValue:(strDocumentTitle)
ocidBodyElement's addChild:(ocidBodyItem)
#区切り線
set ocidBodyItem to refMe's NSXMLElement's alloc()'s initWithName:("hr")
ocidBodyElement's addChild:(ocidBodyItem)
#メインの要素
set ocidBodyItem to refMe's NSXMLElement's alloc()'s initWithName:("div")
ocidBodyItem's addAttribute:(refMe's NSXMLNode's attributeWithName:("class") stringValue:("nav-body"))
ocidBodyElement's addChild:(ocidBodyItem)
#ナビ
set ocidNavItem to refMe's NSXMLElement's alloc()'s initWithName:("nav")
ocidNavItem's addAttribute:(refMe's NSXMLNode's attributeWithName:("epub:type") stringValue:("toc"))
ocidNavItem's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("toc"))
#リスト
set ocidNavOL to refMe's NSXMLElement's alloc()'s initWithName:("ol")
#番号初期化
set numCntPage to 1 as integer
#総ページ数の数だけ繰り返し
repeat numCntAllImage times
	###画像ファイルは連番処理　四桁のゼロサプレス
	set strZeroSup to "0000" as text
	set strSeroSup to (strZeroSup & (numCntPage as text)) as text
	set strSeroSup to (text -4 through -1 of strSeroSup) as text
	set strLinkFileName to (strBaseFileName & strSeroSup) as text
	set strFileName to (strBaseFileName & strSeroSup & ".xhtml") as text
	####
	set ocidNavLI to refMe's NSXMLElement's alloc()'s initWithName:("li")
	set ocidNavA to refMe's NSXMLElement's alloc()'s initWithName:("a")
	ocidNavA's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strFileName))
	ocidNavA's setStringValue:(strLinkFileName)
	ocidNavLI's addChild:(ocidNavA)
	ocidNavOL's addChild:(ocidNavLI)
	set numCntPage to numCntPage + 1 as integer
end repeat
##リストに表紙ページを追加
set ocidNavLI to refMe's NSXMLElement's alloc()'s initWithName:("li")
set ocidNavA to refMe's NSXMLElement's alloc()'s initWithName:("a")
ocidNavA's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("cover.xhtml"))
ocidNavA's addAttribute:(refMe's NSXMLNode's attributeWithName:("epub:type") stringValue:("ibooks:reader-start-page"))
ocidNavA's setStringValue:("Cover Page")
ocidNavLI's addChild:(ocidNavA)
ocidNavOL's addChild:(ocidNavLI)
#リストに目次を追加
set ocidNavLI to refMe's NSXMLElement's alloc()'s initWithName:("li")
set ocidNavA to refMe's NSXMLElement's alloc()'s initWithName:("a")
ocidNavA's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("toc.xhtml"))
ocidNavA's addAttribute:(refMe's NSXMLNode's attributeWithName:("epub:type") stringValue:("toc"))
ocidNavA's setStringValue:("Table of Contents")
ocidNavLI's addChild:(ocidNavA)
ocidNavOL's addChild:(ocidNavLI)
#出来上がったリストをbodyに追加
ocidNavItem's addChild:(ocidNavOL)
ocidBodyItem's addChild:(ocidNavItem)
####
#【３−６-B】 head を【３−６-A】 ルートエレメントに追加
ocidRootElement's addChild:(ocidHeadElement)
#【３−６-C】 body を【３−６-A】ルートエレメントに追加
ocidRootElement's addChild:(ocidBodyElement)
##　↑からのROOTエレメントをセットしてXMLとする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###テキストにして
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listDone to ocidSaveStrings's writeToURL:(ocidXHTMLFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

#############################################
###◆【３−５】content.opf
##【B】メタ情報のheadからなる　【C】各種コンテンツへのパス　manifest　と　【D】コンテンツの配置 spine 　【E】ガイドguide
##Pageの場合
##	set ocidOptFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("epb.opf") isDirectory:false
##一般的な命名
set ocidOptFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("content.opf") isDirectory:false
##【A】ルートエレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"package"
#アトリビュートを追加
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("version") stringValue:("3.0"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("unique-identifier") stringValue:("BookId"))
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("prefix") stringValue:("ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/ rendition: http://www.idpf.org/vocab/rendition/#"))
#ネームスペースを追加
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("http://www.idpf.org/2007/opf"))
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("ibooks") stringValue:("http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/"))
##################
#【B】メタ情報のhead
set ocidMetaDataElement to refMe's NSXMLElement's alloc()'s initWithName:("metadata")
ocidMetaDataElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("dc") stringValue:("http://purl.org/dc/elements/1.1/"))
ocidMetaDataElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("opf") stringValue:("http://www.idpf.org/2007/opf"))
#◆【B-1】タイトル
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:title")
ocidMetaElement's setStringValue:(strDocumentTitle)
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-２】作成者　著者
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:creator")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("creator"))
ocidMetaElement's setStringValue:(strAuthor)
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-３】UUID
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:identifier")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("BookId"))
ocidMetaElement's setStringValue:(strUUID)
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-４】言語
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:language")
ocidMetaElement's setStringValue:("ja")
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-5】作成日
set strSetDate to doGetDateNo("yyyy-MM-dd") as text
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:date")
ocidMetaElement's setStringValue:(strSetDate)
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-6】修正日
set strSetDate to doGetDateNo("yyyy-MM-dd'T'HH:mm:ss'Z'") as text
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("dc:modified")
ocidMetaElement's setStringValue:(strSetDate)
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-７】コンテンツのプロパティ　レイアウト
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("property") stringValue:("rendition:layout"))
##リフロータイプのレイアウト 柔軟な表示形式　文字中心なものに最適
#	ocidMetaElement's setStringValue:("reflowable")
##固定型のレイアウト 画面サイズに依存しない表示　画面のレイアウトを優先したい場合
#	ocidMetaElement's setStringValue:("fixed")
##事前にページ化されたレイアウト  ページベースの表示形式　画像コンテンツに最適
ocidMetaElement's setStringValue:("pre-paginated")
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-８】コンテンツのプロパティ　スプレッド　開き方
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("property") stringValue:("rendition:spread"))
##デバイスの向きに依存しない
ocidMetaElement's setStringValue:("both")
##横
#ocidMetaElement's setStringValue:("landscape")
##縦　非推奨
#ocidMetaElement's setStringValue:("portrait")
##単ページ
##ocidMetaElement's setStringValue:("none")
##自動
##ocidMetaElement's setStringValue:("auto")
ocidMetaDataElement's addChild:(ocidMetaElement)
#◆【B-９】向き
set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("property") stringValue:("rendition:orientation"))
#自動
ocidMetaElement's setStringValue:("auto")
##横
#ocidMetaElement's setStringValue:("landscape")
##縦
#ocidMetaElement's setStringValue:("portrait")
ocidMetaDataElement's addChild:(ocidMetaElement)
##表紙の有無での分岐
if boolCoverPage is true then
	set ocidMetaElement to refMe's NSXMLElement's alloc()'s initWithName:("meta")
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("cover"))
	ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:("cover-image"))
	ocidMetaDataElement's addChild:(ocidMetaElement)
end if

##################
###　【C】各種コンテンツへのパス　manifest
##manifestのROOTエレメント
set ocidManifestElement to refMe's NSXMLElement's alloc()'s initWithName:("manifest")
#CSS追加
set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("stylesheet"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("css/book.css"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("text/css"))
ocidManifestElement's addChild:(ocidItemElement)
#JS追加
set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("javascript"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("js/book.js"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("text/javascript"))
ocidManifestElement's addChild:(ocidItemElement)
#NCX追加
set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("ncx"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("toc.ncx"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("application/x-dtbncx+xml"))
ocidManifestElement's addChild:(ocidItemElement)
#目次追加
set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("toc"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("toc.xhtml"))
ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("application/x-dtbncx+xml"))
ocidManifestElement's addChild:(ocidItemElement)
##表紙　表示画像
if boolCoverPage is true then
	##表紙ページ設定
	set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("cover"))
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("cover.xhtml"))
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("application/x-dtbncx+xml"))
	ocidManifestElement's addChild:(ocidItemElement)
	##表紙画像
	set ocidExtensionName to ocidCoverImageFilePathURL's pathExtension()
	####拡張子からUTI取得
	set ocidUTType to (refMe's UTType's typeWithFilenameExtension:(ocidExtensionName))
	set ocidFileMimeType to ocidUTType's preferredMIMEType()
	##MimeTypeを取得してから
	set strFileMimeType to ocidFileMimeType as text
	#設定
	set strCoverImageFileName to (strBaseImageFileName & "0001." & (ocidExtensionName as text)) as text
	set strHref to ("images/" & strCoverImageFileName) as text
	set ocidItemElement to refMe's NSXMLElement's alloc()'s initWithName:("item")
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("cover-image"))
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strHref))
	ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:(strFileMimeType))
	ocidManifestElement's addChild:(ocidItemElement)
end if


set numCntPage to 1 as integer
repeat with itemAliasFilePath in listAliasFilePath
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidExtensionName to ocidFilePathURL's pathExtension()
	####拡張子からUTI取得
	set ocidUTType to (refMe's UTType's typeWithFilenameExtension:(ocidExtensionName))
	set ocidFileMimeType to ocidUTType's preferredMIMEType()
	set strFileMimeType to ocidFileMimeType as text
	###画像ファイルは連番処理　四桁のゼロサプレス
	set strZeroSup to "0000" as text
	set strSeroSup to (strZeroSup & (numCntPage as text)) as text
	set strSeroSup to (text -4 through -1 of strSeroSup) as text
	#IDを定義
	set strBaseImageFileName to ("dataItem") as text
	set strFileName to (strBaseImageFileName & strSeroSup) as text
	##メディア要素（イメージファイル）
	#itemエレメント
	set ocidItemElement to (refMe's NSXMLElement's alloc()'s initWithName:("item"))
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:(strFileName)))
	#パス
	set strSetValue to ("images/Image_" & strSeroSup & "." & (ocidExtensionName as text)) as text
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strSetValue)))
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:(strFileMimeType)))
	(ocidManifestElement's addChild:(ocidItemElement))
	##ページ要素（XHTMLファイル）
	set strBaseFileName to ("page-") as text
	set strFileName to (strBaseFileName & strSeroSup) as text
	#itemエレメント
	set ocidItemElement to (refMe's NSXMLElement's alloc()'s initWithName:("item"))
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:(strFileName)))
	#パス
	set strSetValue to (strBaseFileName & strSeroSup & ".xhtml") as text
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strSetValue)))
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("application/xhtml+xml")))
	(ocidItemElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("properties") stringValue:("scripted")))
	(ocidManifestElement's addChild:(ocidItemElement))
	##カウントアップ
	set numCntPage to numCntPage + 1 as integer
end repeat

########################
#【D】コンテンツの配置 spine
set ocidSpineElement to refMe's NSXMLElement's alloc()'s initWithName:("spine")
##アトリビュート
ocidSpineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("toc") stringValue:("ncx"))
##開き方向指定
ocidSpineElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("page-progression-direction") stringValue:(strPageProgression))
##【D-1】表紙ページの有無
if boolCoverPage is true then
	#表紙ページ　ID: cover-page
	set ocidItemRef to refMe's NSXMLElement's alloc()'s initWithName:("itemref")
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("idref") stringValue:("cover"))
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("linear") stringValue:("yes"))
	ocidSpineElement's addChild:(ocidItemRef)
	(*
	#表紙画像		ID: cover-image
	set ocidItemRef to refMe's NSXMLElement's alloc()'s initWithName:("itemref")
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("idref") stringValue:("cover-image"))
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("linear") stringValue:("yes"))
	ocidSpineElement's addChild:(ocidItemRef)
	#表紙ページ　ID: cover-page
	set ocidItemRef to refMe's NSXMLElement's alloc()'s initWithName:("itemref")
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("idref") stringValue:("cover-page"))
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("linear") stringValue:("yes"))
	ocidSpineElement's addChild:(ocidItemRef)
		*)
	##【D-2】目次ページ
	set ocidItemRef to refMe's NSXMLElement's alloc()'s initWithName:("itemref")
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("idref") stringValue:("toc"))
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("linear") stringValue:("yes"))
	ocidSpineElement's addChild:(ocidItemRef)
end if

#カウンタ初期化
set numCntPage to 1 as integer
#事前に取得している総ページ数回繰り返す
repeat numCntAllImage times
	###画像ファイルは連番処理　四桁のゼロサプレス
	set strZeroSup to "0000" as text
	set strSeroSup to (strZeroSup & (numCntPage as text)) as text
	set strSeroSup to (text -4 through -1 of strSeroSup) as text
	set strSetFileID to (strBaseFileName & strSeroSup) as text
	##ファイル名をitemrefとして登録
	set ocidItemRef to refMe's NSXMLElement's alloc()'s initWithName:("itemref")
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("idref") stringValue:(strSetFileID))
	ocidItemRef's addAttribute:(refMe's NSXMLNode's attributeWithName:("linear") stringValue:("yes"))
	if boolProgression is true then
		if numCntPage = 1 then
			log "spineから１ページ目を抜きます"
		else
			##ページ要素itemrefをspineの子要素に追加
			ocidSpineElement's addChild:(ocidItemRef)
		end if
	else
		##ページ要素itemrefをspineの子要素に追加
		ocidSpineElement's addChild:(ocidItemRef)
	end if
	set numCntPage to numCntPage + 1 as integer
end repeat
##################
#【E】ガイドguide
(* referenceのtypeの要素
toc（Table of Contents）: 目次へのリンク。
cover: 書籍の表紙ページへのリンク。
title-page: 書籍のタイトルページへのリンク。
colophon: 制作者や印刷情報を含むページへのリンク。
acknowledgements: 著者への謝辞が含まれるページへのリンク。
dedication: 書籍の献辞が含まれるページへのリンク。
*)
set ocidGuideElement to refMe's NSXMLElement's alloc()'s initWithName:("guide")
#【E-1】目次追加
set ocidReferenceElement to (refMe's NSXMLElement's alloc()'s initWithName:("reference"))
ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("toc"))
ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("toc.xhtml"))
ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:("目次"))
ocidGuideElement's addChild:(ocidReferenceElement)
##【E-2】表紙ページの有無　設定依存
if boolCoverPage is true then
	set ocidReferenceElement to (refMe's NSXMLElement's alloc()'s initWithName:("reference"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("cover"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:("cover.xhtml"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:("表紙"))
	ocidGuideElement's addChild:(ocidReferenceElement)
	##１ページ目指定
	set strStartFileName to (strBaseFileName & "0001.xhtml") as text
	set ocidReferenceElement to (refMe's NSXMLElement's alloc()'s initWithName:("reference"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("other.reader-start-page"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strStartFileName))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:("最初のページ"))
	ocidGuideElement's addChild:(ocidReferenceElement)
	##１ページ目指定
	set ocidReferenceElement to (refMe's NSXMLElement's alloc()'s initWithName:("reference"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("type") stringValue:("text"))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("href") stringValue:(strStartFileName))
	ocidReferenceElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("title") stringValue:("最初のコンテンツ"))
	ocidGuideElement's addChild:(ocidReferenceElement)
end if

##################
#↑からの各子要素をセット
##　【B】メタ部を【A】のROOTエレメントに追加
ocidRootElement's addChild:(ocidMetaDataElement)
##　【C】manifest部を【A】のROOTエレメントに追加
ocidRootElement's addChild:(ocidManifestElement)
##　【D】spine部を【A】のROOTエレメントに追加
ocidRootElement's addChild:(ocidSpineElement)
##　【E】ガイド部を【A】のROOTエレメントに追加
ocidRootElement's addChild:(ocidGuideElement)
##　【A】をROOTエレメントをセットしてXMLとする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###　【A】をテキストにして
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listWritetoUrlArray to ocidSaveStrings's writeToURL:(ocidOptFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####################################
###◆ 【３−４】toc.ncx　主に閲覧者が必要な情報や
##ページや項目の順番等を指定する
##マルチメディア系やアクセシビリティ要素もここで指定する
###ファイルパス
##Pageの場合
##	set ocidNcxFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("epb.ncx") isDirectory:false
##一般的な命名
set ocidNcxFilePathURL to ocidOPSDirPathURL's URLByAppendingPathComponent:("toc.ncx") isDirectory:false
######【A】ROOTのエレメント　４つの子要素がある
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"ncx"
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("version") stringValue:("2005-1"))
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("http://www.daisy.org/z3986/2005/ncx/"))
######【B】head　メタ情報部分
set ocidHeadElement to refMe's NSXMLElement's alloc()'s initWithName:("head")
##【B-1】uid
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dtb:uid"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strUUID))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
##◆【B-2】depth
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dtb:depth"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:("1"))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
##◆【B-3】totalPageCount
set strCntAllImage to numCntAllImage as text
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dtb:totalPageCount"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strCntAllImage))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
##◆【B-4】maxPageNumber
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dtb:maxPageNumber"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strCntAllImage))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
##◆【B-5】作成日
set strSetDate to doGetDateNo("yyyy-MM-dd") as text
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dc:date"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strSetDate))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
##◆【B-6】修正日
set strSetDate to doGetDateNo("yyyy-MM-dd'T'HH:mm:ss'Z'") as text
###エレメント名meta
set ocidMetaElement to refMe's NSXMLElement's elementWithName:("meta")
##アトリビュートを設定して
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("dc:modified"))
ocidMetaElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("content") stringValue:(strSetDate))
##親要素の【B】head　に追加する
ocidHeadElement's addChild:(ocidMetaElement)
######【C】docTitle　タイトル
##エレメント名docTitle
set ocidTitleElement to refMe's NSXMLElement's alloc()'s initWithName:("docTitle")
##子要素のtext
set ocidTextElement to refMe's NSXMLElement's elementWithName:("text")
##子要素textにドキュメント名を値として設定して
ocidTextElement's setStringValue:(strDocumentTitle)
##CのdocTitleエレメントに子要素として追加する
ocidTitleElement's addChild:(ocidTextElement)
######【D】docAuthor　作者　著者
##エレメント名　docAuthor
set ocidAuthorElement to refMe's NSXMLElement's alloc()'s initWithName:("docAuthor")
##子要素のtext
set ocidTextElement to refMe's NSXMLElement's elementWithName:("text")
##子要素textに作者情報を値として設定して
ocidTextElement's setStringValue:(strAuthor)
##DのdocAuthorエレメントに子要素として追加する
ocidAuthorElement's addChild:(ocidTextElement)
######【E】navMap　navMapは閲覧時の順番を指定するので表紙イメージの設定とは異なる
set ocidMapElement to refMe's NSXMLElement's alloc()'s initWithName:("navMap")
#navMapの子要素navPoint
set ocidNavPointElement to refMe's NSXMLElement's elementWithName:("navPoint")
##navPointのアトリビュート　カバー表紙を最初のページとして読み順指定する
ocidNavPointElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("id") stringValue:("navpoint-1"))
ocidNavPointElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("playOrder") stringValue:("1"))
##【E-1】 navLabel ↑このnavPointの意図するラベル名
set ocidNavLabelElement to refMe's NSXMLElement's elementWithName:("navLabel")
set ocidTextElement to refMe's NSXMLElement's elementWithName:("text")
ocidTextElement's setStringValue:(strLabelTitle)
##ラベルテキストをnavLabelに子要素として追加
ocidNavLabelElement's addChild:(ocidTextElement)
##↑追加したラベルをnavPointに子要素として追加
ocidNavPointElement's addChild:(ocidNavLabelElement)
##【E-２】contentはnavPointとして指定するファイルのリソースパス
set ocidNavContentElement to refMe's NSXMLElement's elementWithName:("content")
###表紙設定ありの場合は
if boolCoverPage is true then
	##アトリビュートでパス指定する　＝表紙ページ
	ocidNavContentElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:("cover.xhtml"))
else
	##見開き調整ありの場合は
	if boolProgression is true then
		set strStartFileName to (strBaseFileName & "0002.xhtml") as text
		ocidNavContentElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:(strStartFileName))
	else
		set strStartFileName to (strBaseFileName & "0001.xhtml") as text
		ocidNavContentElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("src") stringValue:(strStartFileName))
	end if
end if
##contentをnavPointに子要素として追加
ocidNavPointElement's addChild:(ocidNavContentElement)
##複数のnavPointを指定する場合はこの下に追加していく
###navPointをnavMapに子要素として追加
ocidMapElement's addChild:(ocidNavPointElement)
##　↑からの子要素をセット
##【A】に【B】を追加
ocidRootElement's addChild:(ocidHeadElement)
##【A】に【C】を追加
ocidRootElement's addChild:(ocidTitleElement)
##【A】に【D】を追加
ocidRootElement's addChild:(ocidAuthorElement)
##【A】に【E】を追加
ocidRootElement's addChild:(ocidMapElement)
##　↑からのROOTエレメントをセットしてXMLとする
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###XML形式のテキストに出力
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存 これでCNXファイルの出来上がり
set listWritetoUrlArray to ocidSaveStrings's writeToURL:(ocidNcxFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

#################################################################
###	【２】META-INF　ファイル：　container.xml　com.apple.ibooks.display-options.xml
set ocidMetaDirPathURL to ocidEpubDirPathURL's URLByAppendingPathComponent:("META-INF") isDirectory:true
##################
###◆【２−１】container.xml
###ファイルのパス
set ocidContainerFilePathURL to ocidMetaDirPathURL's URLByAppendingPathComponent:("container.xml") isDirectory:false
###【A】ROOT エレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"container"
##【A】にアトリビュートを追加
ocidRootElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("version") stringValue:("1.0"))
##【A】にネームスペースを追加
ocidRootElement's addNamespace:(refMe's NSXMLNode's namespaceWithName:("") stringValue:("urn:oasis:names:tc:opendocument:xmlns:container"))
###【B】子要素　rootfiles　エレメント
set ocidRootFilesElement to refMe's NSXMLElement's alloc()'s initWithName:"rootfiles"
###【C】Bの子要素　rootfileノード
set ocidRootFilesNode to refMe's NSXMLElement's alloc()'s initWithName:"rootfile"
##【C】にアトリビュートを追加
ocidRootFilesNode's addAttribute:(refMe's NSXMLNode's attributeWithName:("full-path") stringValue:("OPS/content.opf"))
ocidRootFilesNode's addAttribute:(refMe's NSXMLNode's attributeWithName:("media-type") stringValue:("application/oebps-package+xml"))
##　↑からの子要素をセット(【B】に【C】を追加)
ocidRootFilesElement's addChild:(ocidRootFilesNode)
##　↑からの子要素をセット(【A】に【B】を追加)
ocidRootElement's addChild:(ocidRootFilesElement)
##　↑からのROOTエレメントをセットしてXMLとする　　【A】をXMLドキュメントに
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"
###XML形式のテキストに出力
set ocidSaveStrings to ocidOutPutXML's XMLString()
###改行コードを指定して
ocidSaveStrings's appendString:"\n"
##保存
set listDone to ocidSaveStrings's writeToURL:(ocidContainerFilePathURL) atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

##################
###◆	【２−２】com.apple.ibooks.display-options.xml
##ファイルパス
set ocidContainerFilePathURL to ocidMetaDirPathURL's URLByAppendingPathComponent:("com.apple.ibooks.display-options.xml") isDirectory:false
###【A】ROOT エレメント
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:"display_options"
###【B】子要素　platform　エレメント
set ocidPlatformElement to refMe's NSXMLElement's alloc()'s initWithName:("platform")
###【B】にアトリビュートを追加
ocidPlatformElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("*"))
###【C】Bの子要素としてのoption　エレメント
set ocidOptionElement to refMe's NSXMLElement's elementWithName:("option")
###【C】にアトリビュートを追加
ocidOptionElement's addAttribute:(refMe's NSXMLNode's attributeWithName:("name") stringValue:("specified-fonts"))
###【C】にテキストの値を設定
ocidOptionElement's setStringValue:("false")
##　子要素をセット　【C】を【B】に追加
ocidPlatformElement's addChild:(ocidOptionElement)
##　↑からの子要素をセット　【B】を【A】に追加
ocidRootElement's addChild:(ocidPlatformElement)
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
