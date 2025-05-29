#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
クリップボードの中身で保存可能なものを
ダウンロードフォルダに保存します

v1初回作成
v2 リンクファイルを追加
v2.1 テキストの中身がURLならWEBLOC保存
v.2.2 Microsoft Edgeのオプション保存を追加
org.microsoft.link-preview
org.microsoft.titled-hyperlink
v2.3 選択範囲テキストのフラグメントURLに対応
v2.4 ローケーションファイルの拡張子の分岐を作成
v2.4.1 画像をコピー等でテキスト無い場合のエラーに対応
v2.5 テキストクリッピングでの保存を追加
v2.5.1 UTI-Dataのmissing value対策を入れた
v2.6 TIFFデータがある場合OCRを実行して結果を保存するようにした

com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use framework "VisionKit"
use framework "Vision"
use scripting additions

property refMe : a reference to current application

################################
##### パス関連
################################
###フォルダ名用に時間を取得する
set strDateno to doGetDateNo("yyyyMMdd-hhmmss") as text
###保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set strSubDirName to ("Pasteboard/" & strDateno) as text
set ocidSaveParentsDirPathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strSubDirName) isDirectory:(true)
#フォルダ生成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveParentsDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
if (item 1 of listDone) is true then
	log "正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	set strErrorNO to (item 2 of listDone)'s code() as text
	set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "エラーしました" & strErrorNO & strErrorMes
end if

################################
######ペーストボードを取得
################################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
#タイプを取得
set ocidPastBoardTypeArray to ocidPasteboard's types()
log ocidPastBoardTypeArray as list

set strText to ("")
#########################
#【１】FILEURL処理
set boolContain to ocidPastBoardTypeArray's containsObject:("NSFilenamesPboardType")
if boolContain is true then
	set ocidPastBoardData to (ocidPasteboard's propertyListForType:("NSFilenamesPboardType"))
	#パス出力用
	set ocidFileNamesString to refMe's NSMutableString's alloc()'s init()
	#順番に処理
	repeat with itemData in ocidPastBoardData
		#出力用のテキストにそのまま追加して改行入れる
		(ocidFileNamesString's appendString:(itemData))
		(ocidFileNamesString's appendString:("\n"))
		#NSURLにして
		set ocidItemFilePath to itemData's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidItemFilePath))
		#ファイル名から
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
		set ocidSaveFileName to (ocidBaseFileName's stringByAppendingPathExtension:("fileloc"))
		#保存先のURLを作成
		set ocidPlistFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName) isDirectory:(false))
		set ocidItemFilePath to ocidFilePathURL's absoluteString()
		#DICTにして
		set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s init()
		(ocidPlistDict's setValue:(ocidItemFilePath) forKey:("URL"))
		#PLISTに
		set ocidFormat to (refMe's NSPropertyListXMLFormat_v1_0)
		set listResponse to (refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference))
		set ocidPlistData to (item 1 of listResponse)
		#保存
		set ocidOption to (refMe's NSDataWritingAtomic)
		set listDone to (ocidPlistData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference))
		
	end repeat
	set ocidSaveFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:("NSFilenamesPboardType.txt") isDirectory:(false))
	set listDone to ocidFileNamesString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
end if

#########################
#【２】org.chromium.source-url処理
set boolContain to ocidPastBoardTypeArray's containsObject:("org.chromium.source-url")
if boolContain is true then
	set ocidPastBoardData to (ocidPasteboard's dataForType:("org.chromium.source-url"))
	set ocidURLstring to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
	#一度URLにして
	set ocidURL to (refMe's NSURL's alloc()'s initWithString:(ocidURLstring))
	
	#ファイル名用にHOST名を取得
	set strHostName to ocidURL's |host|() as text
	#保存用拡張子を付与
	set ocidItemSaveFileName to ("" & strHostName & ".webloc")
	#DICTにして
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s init()
	(ocidPlistDict's setValue:(ocidURLstring) forKey:("URL"))
	#PLISTに
	set ocidFormat to (refMe's NSPropertyListXMLFormat_v1_0)
	set listResponse to (refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference))
	set ocidPlistData to (item 1 of listResponse)
	#保存先
	set ocidPlistFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(ocidItemSaveFileName) isDirectory:(false))
	#保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to (ocidPlistData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference))
	##テキストでも保存しておく
	set ocidItemSaveFileName to ("org.chromium.source-url.txt") as text
	set ocidSaveURLFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(ocidItemSaveFileName) isDirectory:(false))
	#
	set listDone to ocidURLstring's writeToURL:(ocidSaveURLFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
	
end if
#########################
#カレンダー
set boolContain to ocidPastBoardTypeArray's containsObject:("com.apple.calendar.pasteboard.event")
if boolContain is true then
	set ocidPastBoardData to (ocidPasteboard's dataForType:("com.apple.calendar.pasteboard.event"))
	set ocidEventIDstring to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
	log ocidEventIDstring as text
end if

set boolContain to ocidPastBoardTypeArray's containsObject:("com.apple.iCal.pasteboard.dragOriginDate")
if boolContain is true then
	set ocidPastBoardData to (ocidPasteboard's dataForType:("com.apple.iCal.pasteboard.dragOriginDate"))
	set ocidEventIDstring to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
	log ocidEventIDstring as text
end if

#########################
#【３】public.url処理
set boolContain to ocidPastBoardTypeArray's containsObject:("public.url")
if boolContain is true then
	set ocidPastBoardData to (ocidPasteboard's dataForType:("public.url"))
	set ocidURLstring to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
	set ocidURL to (refMe's NSURL's alloc()'s initWithString:(ocidURLstring))
	#
	set ocidURLomponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:(false)
	set strScheme to ocidURLomponents's |scheme|() as text
	if strScheme starts with "http" then
		set strSaveExtension to ("webloc") as text
	else if strScheme starts with "mail" then
		set strSaveExtension to ("mailloc") as text
	else if strScheme starts with "ftp" then
		set strSaveExtension to ("ftploc") as text
	else if strScheme starts with "atp" then
		set strSaveExtension to ("afploc") as text
	else if strScheme starts with "file" then
		set strSaveExtension to ("fileloc") as text
	else if strScheme starts with "news" then
		set strSaveExtension to ("newsloc") as text
	else
		set strSaveExtension to ("inetloc") as text
	end if
	
	set boolContain to ocidPastBoardTypeArray's containsObject:("public.url-name")
	if boolContain is true then
		set ocidPastBoardData to (ocidPasteboard's dataForType:("public.url-name"))
		set ocidURLname to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
		set strSaveFileName to ("" & (ocidURLname as text) & "." & strSaveExtension & "") as text
	else if boolContain is false then
		set ocidHostName to ocidURL's |host|()
		set strSaveFileName to ("" & (ocidHostName as text) & "." & strSaveExtension & "") as text
	end if
	#DICTにして
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s init()
	(ocidPlistDict's setValue:(ocidURLstring) forKey:("URL"))
	#PLISTに
	set ocidFormat to (refMe's NSPropertyListXMLFormat_v1_0)
	set listResponse to (refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference))
	set ocidPlistData to (item 1 of listResponse)
	#保存先
	set ocidPlistFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
	#保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to (ocidPlistData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference))
end if

#########################
#textClipping
set ocidTextClippingDict to refMe's NSMutableDictionary's alloc()'s init()
set ocidUTIDataDict to refMe's NSMutableDictionary's alloc()'s init()
#全タイプ処理する
repeat with itemPasteType in ocidPastBoardTypeArray
	if (itemPasteType as text) is "public.utf8-plain-text" then
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		(ocidUTIDataDict's setValue:(ocidPastBoardData) forKey:(itemPasteType))
	else if (itemPasteType as text) is "public.utf16-external-plain-text" then
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		(ocidUTIDataDict's setValue:(ocidPastBoardData) forKey:(itemPasteType))
	else if (itemPasteType as text) is "public.utf16-plain-text" then
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		(ocidUTIDataDict's setValue:(ocidPastBoardData) forKey:(itemPasteType))
	else if (itemPasteType as text) is "com.apple.traditional-mac-plain-text" then
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		(ocidUTIDataDict's setValue:(ocidPastBoardData) forKey:(itemPasteType))
	else if (itemPasteType as text) is "public.rtf" then
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		set ocidRTFString to (refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding))
		(ocidUTIDataDict's setValue:(ocidRTFString) forKey:(itemPasteType))
	else
		set ocidUTIDataDict to (missing value)
	end if
end repeat
if ocidUTIDataDict ≠ (missing value) then
	ocidTextClippingDict's setObject:(ocidUTIDataDict) forKey:("UTI-Data")
	#PLISTデータに
	set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
	set listResponse to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidTextClippingDict) format:(ocidFormat) options:0 |error|:(reference)
	set ocidPlistData to (first item of listResponse)
	#保存先パス
	set strSaveFileName to ("UTI-Data.textClipping") as text
	set ocidSaveFilePath to ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false)
	#保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to (ocidPlistData's writeToURL:(ocidSaveFilePath) options:(ocidOption) |error|:(reference))
end if


#########################
#全タイプ処理する
repeat with itemPasteType in ocidPastBoardTypeArray
	#【１】全タイプ処理 拡張子を決めておく
	if (itemPasteType as text) is "public.utf8-plain-text" then
		set strExtension to ("utf8.txt") as text
	else if (itemPasteType as text) is "public.utf16-external-plain-text" then
		set strExtension to ("utf16.txt") as text
	else
		#UTTypeを取得
		set ocidUTType to (refMe's UTType's typeWithIdentifier:(itemPasteType))
		#取得できない
		if ocidUTType = (missing value) then
			set strExtension to (missing value)
		else if ocidUTType ≠ (missing value) then
			set ocidExtension to (ocidUTType's preferredFilenameExtension())
			if ocidExtension = (missing value) then
				set strExtension to (missing value)
			else
				set strExtension to (ocidExtension) as text
			end if
		end if
	end if
	#【２】データを取得
	if strExtension = (missing value) then
		#拡張子がわからなかったモノは処理しない
	else
		log strExtension
		#データ取り出し
		set ocidPastBoardData to (ocidPasteboard's dataForType:(itemPasteType))
		if strExtension is "utf8.txt" then
			set ocidTypeClassArray to (refMe's NSMutableArray's alloc()'s init())
			(ocidTypeClassArray's addObject:(refMe's NSString))
			set ocidReadString to (ocidPasteboard's readObjectsForClasses:(ocidTypeClassArray) options:(missing value))
			set strText to ocidReadString as text
		else if strExtension is "tiff" then
			#TIFFを元にOCRする
			set ocidReadImage to (refMe's NSImage's alloc()'s initWithData:(ocidPastBoardData))
			set ocidImageRepArray to ocidReadImage's representations()
			set ocidImageRep to ocidImageRepArray's firstObject()
			set ocidPxSizeH to ocidImageRep's pixelsHigh()
			#とっとと解放
			set ocidImageRepArray to ""
			set ocidImageRep to ""
			set intTextHeight to (8 / ocidPxSizeH) as number
			#####OCR
			#VNImageRequestHandler's
			set ocidHandler to (refMe's VNImageRequestHandler's alloc()'s initWithData:(ocidPastBoardData) options:(missing value))
			#VNRecognizeTextRequest's
			set ocidRequest to refMe's VNRecognizeTextRequest's alloc()'s init()
			set ocidOption to (refMe's VNRequestTextRecognitionLevelAccurate)
			(ocidRequest's setRecognitionLevel:(ocidOption))
			(ocidRequest's setMinimumTextHeight:(intTextHeight))
			(ocidRequest's setAutomaticallyDetectsLanguage:(true))
			(ocidRequest's setRecognitionLanguages:{"en", "ja"})
			(ocidRequest's setUsesLanguageCorrection:(false))
			#results
			(ocidHandler's performRequests:(refMe's NSArray's arrayWithObject:(ocidRequest)) |error|:(reference))
			set ocidResponseArray to ocidRequest's results()
			#戻り値を格納するテキスト
			set ocidFirstOpinionString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
			set ocidSecondOpinionString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
			set ocidSaveString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
			#戻り値の数だけ々
			repeat with itemArray in ocidResponseArray
				#候補数指定　１−１０ ここでは２種の候補を戻す指定
				set ocidRecognizedTextArray to (itemArray's topCandidates:(2))
				set ocidFirstOpinion to ocidRecognizedTextArray's firstObject()
				set ocidSecondOpinion to ocidRecognizedTextArray's lastObject()
				(ocidFirstOpinionString's appendString:(ocidFirstOpinion's |string|()))
				(ocidFirstOpinionString's appendString:("\n"))
				(ocidSecondOpinionString's appendString:(ocidSecondOpinion's |string|()))
				(ocidSecondOpinionString's appendString:("\n"))
			end repeat
			##比較して相違点を探すならここで
			(ocidSaveString's appendString:("-----第１候補\n\n"))
			(ocidSaveString's appendString:(ocidFirstOpinionString))
			(ocidSaveString's appendString:("\n\n-----第２候補\n\n"))
			(ocidSaveString's appendString:(ocidSecondOpinionString))
			###保存
			set ocidBaseFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(itemPasteType) isDirectory:(false))
			set ocidSaveTextFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("OCR.txt"))
			
			set listDone to (ocidSaveString's writeToURL:(ocidSaveTextFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
		end if
		#保存先パス
		#ファイル名はUTI
		set ocidBaseFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(itemPasteType) isDirectory:(false))
		#拡張子つけて
		set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:(strExtension))
		#保存
		set ocidOption to (refMe's NSDataWritingAtomic)
		set listDone to (ocidPastBoardData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
		if (item 1 of listDone) is true then
			log "正常処理"
		else if (item 2 of listDone) ≠ (missing value) then
			set strErrorNO to (item 2 of listDone)'s code() as text
			set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
			refMe's NSLog("■：" & strErrorNO & strErrorMes)
			return "エラーしました" & strErrorNO & strErrorMes
		end if
	end if
end repeat



################################
#テキストがURLならWEBLOC保存を試す
################################
set ocidURLstring to refMe's NSString's stringWithString:(strText)
set ocidURLstring to (ocidURLstring's stringByReplacingOccurrencesOfString:("\r") withString:("\n"))
set ocidURLstring to (ocidURLstring's stringByReplacingOccurrencesOfString:("\n\n") withString:("\n"))
set ocidLineArray to ocidURLstring's componentsSeparatedByString:("\n")
repeat with itemLine in ocidLineArray
	set ocidLineString to (itemLine's stringByReplacingOccurrencesOfString:("\t") withString:(""))
	set boolHas to (ocidLineString's hasPrefix:("http")) as boolean
	if boolHas is true then
		set ocidURL to (refMe's NSURL's alloc()'s initWithString:(ocidURLstring))
		set ocidHOST to ocidURL's |host|()
		set strSaveFileName to ("" & (ocidHOST as text) & ".make.webloc") as text
		set ocidSaveFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
		set ocidURLstring to ocidURL's absoluteString()
		#
		set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s init()
		(ocidPlistDict's setValue:(ocidURLstring) forKey:("URL"))
		#PLIST2NSDATA(MutableContainersAndLeaves)
		set ocidFromat to (refMe's NSPropertyListXMLFormat_v1_0)
		set ocidFromat to (refMe's NSPropertyListBinaryFormat_v1_0)
		set listResponse to (refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference))
		set ocidPlistData to (item 1 of listResponse)
		#NSDATA
		set ocidOption to (refMe's NSDataWritingAtomic)
		set listDone to (ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	end if
end repeat

################################
##### Microsoft Edgeカスタム
################################
set ocidPastBoardData to (ocidPasteboard's dataForType:("org.microsoft.link-preview"))
if ocidPastBoardData ≠ (missing value) then
	set ocidJsonString to refMe's NSString's alloc()'s initWithData:(ocidPastBoardData) encoding:(refMe's NSUTF8StringEncoding)
	set strSaveFileName to ("org.microsoft.link-preview.json") as text
	set ocidSaveFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
	set listDone to ocidJsonString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
end if
################################
##### Microsoft Edgeカスタム
################################
set ocidPastBoardString to (ocidPasteboard's stringForType:("org.microsoft.titled-hyperlink"))
if ocidPastBoardString ≠ (missing value) then
	set ocidPastBoardString to (ocidPastBoardString's stringByReplacingOccurrencesOfString:("<meta charset='utf-8'>") withString:(""))
	set strSaveFileName to ("org.microsoft.link-preview.html") as text
	set ocidSaveFilePathURL to (ocidSaveParentsDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
	set listDone to ocidPastBoardString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
end if
################################
##### 保存先を開く
################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveParentsDirPathURL)

################################
##### ファイル名用の時間
################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
