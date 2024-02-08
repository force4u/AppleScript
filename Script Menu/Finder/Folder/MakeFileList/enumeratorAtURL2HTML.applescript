#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application


###Wクリックで起動した場合
on run
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	##デフォルト＝デスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
	set strPromptText to "フォルダをえらんでください"
	set strMesText to "フォルダをえらんでください"
	try
		set aliasDirPath to (choose folder strMesText with prompt strPromptText default location aliasDesktopDirPath with invisibles and showing package contents without multiple selections allowed) as alias
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	open aliasDirPath
end run


on open aliasDirPath
	##パス
	set aliasDirPath to aliasDirPath as alias
	set strDirPath to (POSIX path of aliasDirPath) as text
	set ocidDirPathStr to refMe's NSString's stringWithString:(strDirPath)
	set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
	set ocidDirPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath)
	set strDirPathURL to ocidDirPathURL's absoluteString() as text
	##フォルダ判定
	set listBoole to (ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
	set boolIsDir to (item 2 of listBoole) as boolean
	if boolIsDir is false then
		return "フォルダ以外です処理を終了します"
	end if
	##フォルダ名→保存先HTMLパス
	set ocidDirName to ocidDirPathURL's lastPathComponent()
	set ocidSaveFileName to refMe's NSMutableString's alloc()'s initWithCapacity:0
	ocidSaveFileName's appendString:("_ファイルリスト")
	ocidSaveFileName's appendString:(ocidDirName)
	set ocidBaseFilePathURL to ocidDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName)
	set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("html")
	
	##ファイルの各種プロパティを取得
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
	set ocidPropertieArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidPropertieArray's addObject:(refMe's NSURLPathKey)
	ocidPropertieArray's addObject:(refMe's NSURLFileSizeKey)
	ocidPropertieArray's addObject:(refMe's NSURLCreationDateKey)
	ocidPropertieArray's addObject:(refMe's NSURLContentModificationDateKey)
	ocidPropertieArray's addObject:(refMe's NSURLNameKey)
	ocidPropertieArray's addObject:(refMe's NSURLContentTypeKey)
	ocidPropertieArray's addObject:(refMe's NSURLFileAllocatedSizeKey)
	ocidPropertieArray's addObject:(refMe's NSURLIsRegularFileKey)
	########################################
	##コンテンツの収集　A 第一階層のみの場合
	########################################
	(*
	set listResponse to (appFileManager's contentsOfDirectoryAtURL:(ocidDirPathURL) includingPropertiesForKeys:(ocidPropertieArray) options:(ocidOption) |error|:(reference))
	set ocidFilePathURLArray to item 1 of listResponse
	#パスリストをファイル名でソート並び替え
	set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("lastPathComponent") ascending:(yes) selector:("localizedStandardCompare:")
	set ocidDescriptorArray to refMe's NSArray's arrayWithObject:(ocidDescriptor)
	set ocidSortedArray to ocidFilePathURLArray's sortedArrayUsingDescriptors:(ocidDescriptorArray)
	*)
	########################################
	##コンテンツの収集　B　最下層までの場合
	########################################
	set ocidEmuDict to appFileManager's enumeratorAtURL:(ocidDirPathURL) includingPropertiesForKeys:(ocidPropertieArray) options:(ocidOption) errorHandler:(reference)
	set ocidEmuFileURLArray to ocidEmuDict's allObjects()
	set ocidFilePathURLAllArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	ocidFilePathURLAllArray's addObjectsFromArray:(ocidEmuFileURLArray)
	#
	set ocidFilePathURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	repeat with itemFilePathURL in ocidFilePathURLAllArray
		set listResult to (itemFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
		set boolIsRegularFileKey to item 2 of listResult
		if boolIsRegularFileKey is (refMe's NSNumber's numberWithBool:true) then
			####リストにする
			(ocidFilePathURLArray's addObject:(itemFilePathURL))
		end if
	end repeat
	#パスリストをファイル名でソート並び替え absoluteString localizedStandardCompare
	set ocidDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"path" ascending:(true) selector:"localizedStandardCompare:")
	set ocidDescriptorArray to refMe's NSArray's arrayWithObject:(ocidDescriptor)
	set ocidSortedArray to ocidFilePathURLArray's sortedArrayUsingDescriptors:(ocidDescriptorArray)
	
	##############################
	# XML　生成開始
	##############################
	#XML初期化
	set ocidXMLDoc to refMe's NSXMLDocument's alloc()'s init()
	ocidXMLDoc's setDocumentContentKind:(refMe's NSXMLDocumentHTMLKind)
	# DTD付与
	set ocidDTD to refMe's NSXMLDTD's alloc()'s init()
	ocidDTD's setName:("html")
	ocidXMLDoc's setDTD:(ocidDTD)
	# XML主要部分を生成
	set ocidRootElement to doMakeRootElement()
	#ボディエレメント
	set ocidBodyElement to refMe's NSXMLElement's elementWithName:("body")
	#ヘッダー
	set ocidHeaderElement to refMe's NSXMLElement's elementWithName:("header")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("header")
	ocidHeaderElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_header")
	ocidHeaderElement's addAttribute:(ocidAddNode)
	ocidBodyElement's addChild:(ocidHeaderElement)
	#アーティクル
	set ocidArticleElement to refMe's NSXMLElement's elementWithName:("article")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("article")
	ocidArticleElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_article")
	ocidArticleElement's addAttribute:(ocidAddNode)
	ocidBodyElement's addChild:(ocidArticleElement)
	#フッター
	set ocidFooterElement to refMe's NSXMLElement's elementWithName:("footer")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("id") stringValue:("footer")
	ocidFooterElement's addAttribute:(ocidAddNode)
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("class") stringValue:("body_footer")
	ocidFooterElement's addAttribute:(ocidAddNode)
	#リンク付与（不要なら削除可）
	set ocidAElement to refMe's NSXMLElement's elementWithName:("a")
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:("https://quicktimer.cocolog-nifty.com/"))
	(ocidAElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
	(ocidAElement's addAttribute:(ocidAddNode))
	set strContents to ("AppleScriptで生成しました") as text
	(ocidAElement's setStringValue:(strContents))
	ocidFooterElement's addChild:(ocidAElement)
	ocidBodyElement's addChild:(ocidFooterElement)
	##############################
	# TABLE コンテンツ部分生成開始
	##############################
	#テーブル部生成開始
	set ocidTableElement to refMe's NSXMLElement's elementWithName:("table")
	#【caption】
	set ocidCaptionElement to refMe's NSXMLElement's elementWithName:("caption")
	ocidCaptionElement's setStringValue:("【ファイルリスト】: ")
	ocidTableElement's addChild:(ocidCaptionElement)
	#【colgroup】
	set ocidColgroupElement to refMe's NSXMLElement's elementWithName:("colgroup")
	#テーブルのタイトル部
	set listColName to {"行番号", "ファイル名", "サイズ", "種類", "作成日", "修正日"} as list
	#タイトル部の数だけ繰り返し
	repeat with itemColName in listColName
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
	repeat with itemColName in listColName
		#ここはTDではなくてTHを利用
		set ocidAddElement to (refMe's NSXMLElement's elementWithName:("th"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:(itemColName))
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
	#【tbody】
	set ocidTbodyElement to refMe's NSXMLElement's elementWithName:("tbody")
	#行番号
	set numCntLineNo to 1 as integer
	#合計ファイルサイズ用
	set numAllFileSize to 0 as integer
	#ファイルのパスの数だけ繰り返し
	repeat with itemFilePathURL in ocidSortedArray
		#ファイルのリソースを取得
		set listResponse to (itemFilePathURL's resourceValuesForKeys:(ocidPropertieArray) |error|:(reference))
		set ocidValueDict to (item 1 of listResponse)
		#TRの開始
		set ocidTrElement to (refMe's NSXMLElement's elementWithName:("tr"))
		#【行番号】をTHでセット
		set strZeroSupp to ("00") as text
		set strZeroSupp to ("00" & numCntLineNo) as text
		set strLineNO to (text -3 through -1 of strZeroSupp) as text
		set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("行番号"))
		(ocidThElement's addAttribute:(ocidAddNode))
		(ocidThElement's setStringValue:(strLineNO))
		(ocidTrElement's addChild:(ocidThElement))
		#【ファイル名】をTDでセット
		set ocidValue to (ocidValueDict's valueForKey:(refMe's NSURLNameKey))
		set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("ファイル名"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		####
		set itemFilePath to itemFilePathURL's |path|
		set ocidRange to (itemFilePath's rangeOfString:(ocidDirPath))
		set numLength to (|length| of ocidRange) + 1 as integer
		set ocidRlativePath to (itemFilePath's substringFromIndex:(numLength))
		
		#↑のTDの内容＝ファイル名にリンクを付与
		set ocidAElement to (refMe's NSXMLElement's elementWithName:("a"))
		set strHref to ("./" & ocidRlativePath) as text
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("href") stringValue:(strHref))
		(ocidAElement's addAttribute:(ocidAddNode))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("target") stringValue:("_blank"))
		(ocidAElement's addAttribute:(ocidAddNode))
		set strHref to (ocidRlativePath) as text
		(ocidAElement's setStringValue:(strHref))
		#リンクをTDにセット
		(ocidTdElement's addChild:(ocidAElement))
		#TDをTRにセット
		(ocidTrElement's addChild:(ocidTdElement))
		#【ファイルサイズ】TD
		set ocidValue to (ocidValueDict's valueForKey:(refMe's NSURLFileSizeKey))
		#ファイルサイズの合計に加算
		set numAllFileSize to (numAllFileSize + (ocidValue as integer))
		set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("ファイルサイズ"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		#単位による分岐
		set numFileSize to ocidValue as integer
		if (numFileSize) < 102400 then
			set numValue to (numFileSize / 1024) as integer
			set strValue to numValue & " kb" as text
		else if (numFileSize) > (10240 * 100000) then
			set numValue to (numFileSize / (10240 * 100000))
			set ocidFormatter to refMe's NSNumberFormatter's alloc()'s init()
			(ocidFormatter's setNumberStyle:(refMe's NSNumberFormatterDecimalStyle))
			(ocidFormatter's setMinimumFractionDigits:(2))
			(ocidFormatter's setMaximumFractionDigits:(2))
			set strValue to (ocidFormatter's stringFromNumber:(numValue)) as text
			set strValue to strValue & " gb" as text
		else
			set numValue to (numFileSize / 1024000) as integer
			set strValue to numValue & " mb" as text
		end if
		(ocidTdElement's setStringValue:(strValue))
		(ocidTrElement's addChild:(ocidTdElement))
		#【種類】TDでセット
		set ocidValue to (ocidValueDict's valueForKey:(refMe's NSURLContentTypeKey))'s localizedDescription()
		set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("種類"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("kind_string"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		(ocidTdElement's setStringValue:(ocidValue))
		(ocidTrElement's addChild:(ocidTdElement))
		#【作成日】TDでセット
		set ocidValue to (ocidValueDict's valueForKey:(refMe's NSURLCreationDateKey))
		set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("作成"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("date_string"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		set strDate to (ocidValue as date) as text
		(ocidTdElement's setStringValue:(strDate))
		(ocidTrElement's addChild:(ocidTdElement))
		#【修正日】TDでセット
		set ocidValue to (ocidValueDict's valueForKey:(refMe's NSURLContentModificationDateKey))
		set ocidTdElement to (refMe's NSXMLElement's elementWithName:("td"))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("修正日"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("class") stringValue:("date_string"))
		(ocidTdElement's addAttribute:(ocidAddNode))
		set strDate to (ocidValue as date) as text
		(ocidTdElement's setStringValue:(strDate))
		(ocidTrElement's addChild:(ocidTdElement))
		#出来上がったTRをTBODYにセット
		(ocidTbodyElement's addChild:(ocidTrElement))
		#項目番号のカウントアップ
		set numCntLineNo to (numCntLineNo + 1) as integer
	end repeat
	#TBODYをテーブルにセット
	ocidTableElement's addChild:(ocidTbodyElement)
	#【tfoot】 TRで
	set ocidTfootElement to refMe's NSXMLElement's elementWithName:("tfoot")
	set ocidTrElement to refMe's NSXMLElement's elementWithName:("tr")
	#項目数を取得して
	set numCntCol to (count of listColName) as integer
	#colspan指定して１行でセット
	set ocidThElement to (refMe's NSXMLElement's elementWithName:("th"))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("title") stringValue:("テーブルの終わり"))
	(ocidThElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("colspan") stringValue:(numCntCol as text))
	(ocidThElement's addAttribute:(ocidAddNode))
	set ocidAddNode to (refMe's NSXMLNode's attributeWithName:("scope") stringValue:("row"))
	(ocidThElement's addAttribute:(ocidAddNode))
	#
	if (numAllFileSize) < 102400 then
		set numValue to (numAllFileSize / 1024) as integer
		set strValue to "フォルダ合計：" & numValue & " kb" as text
	else if (numAllFileSize) > (10240 * 100000) then
		set numValue to (numAllFileSize / (10240 * 100000))
		set ocidFormatter to refMe's NSNumberFormatter's alloc()'s init()
		(ocidFormatter's setNumberStyle:(refMe's NSNumberFormatterDecimalStyle))
		(ocidFormatter's setMinimumFractionDigits:(2))
		(ocidFormatter's setMaximumFractionDigits:(2))
		set strValue to (ocidFormatter's stringFromNumber:(numValue)) as text
		set strValue to "フォルダ合計：" & strValue & " gb" as text
	else
		set numValue to (numAllFileSize / 1024000) as integer
		set strValue to "フォルダ合計：" & numValue & " mb" as text
	end if
	ocidThElement's setStringValue:(strValue)
	
	#THをTRにセットして
	ocidTrElement's addChild:(ocidThElement)
	#TRをTFOOTにセット
	ocidTfootElement's addChild:(ocidTrElement)
	#TFOOTをテーブルにセット
	ocidTableElement's addChild:(ocidTfootElement)
	#	出来上がったテーブルをArticleエレメントにセット
	ocidArticleElement's addChild:(ocidTableElement)
	#
	ocidRootElement's addChild:(ocidBodyElement)
	##############################
	# TABLE
	##############################
	#ROOTエレメントをXMLにセット
	ocidXMLDoc's setRootElement:(ocidRootElement)
	#読み取りやすい表示
	set ocidXMLdata to ocidXMLDoc's XMLDataWithOptions:(refMe's NSXMLNodePrettyPrint)
	#保存
	set listDone to ocidXMLdata's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
	set ocidSaveFilePath to ocidSaveFilePathURL's |path|
	set ocidContainerDirPathURL to ocidSaveFilePathURL's URLByDeletingLastPathComponent()
	set ocidContainerDirPath to ocidContainerDirPathURL's |path|
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePath) inFileViewerRootedAtPath:(ocidContainerDirPath)
	set boolDone to appSharedWorkspace's openURL:(ocidSaveFilePathURL)
	if (boolDone as boolean) is false then
		#ファイルを開く
		set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
		tell application "Finder"
			open file aliasSaveFilePath
		end tell
	end if
	##処理終了
	return "処理終了"
end open
##############################
# 基本的なHTMLの構造
##############################
to doMakeRootElement()
	#
	set ocidRootElement to refMe's NSXMLElement's elementWithName:("html")
	set ocidAddNode to refMe's NSXMLNode's attributeWithName:("lang") stringValue:("ja")
	ocidRootElement's addAttribute:(ocidAddNode)
	#
	set ocidHeadElement to refMe's NSXMLElement's elementWithName:("head")
	#
	set ocidAddElement to refMe's NSXMLElement's elementWithName:("title")
	ocidAddElement's setStringValue:("ファイル一覧")
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
	#
	ocidRootElement's addChild:(ocidHeadElement)
	#	
	return ocidRootElement
end doMakeRootElement
