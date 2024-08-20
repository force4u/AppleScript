#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	ピクセルサイズを偶数にすることを優先している
#	出力解像度は選択式
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use framework "PDFKit"
use framework "Quartz"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


##############################
#ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if

##############################
#ファイル選択ダイアログ
set ocidUserDesktopPath to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias
set listChooseFileUTI to {"com.adobe.pdf"}
set strPromptText to "PDFファイルを選んでください" as text
set strMesText to "PDFファイルを選んでください" as text
set aliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI without invisibles, multiple selections allowed and showing package contents) as alias

################################
#パス URL
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath)
#ファイル名を取得
set ocidFileName to ocidFilePathURL's lastPathComponent()
#ファイル名から拡張子を取っていわゆるベースファイル名を取得
set ocidPrefixName to ocidFileName's stringByDeletingPathExtension
#コンテナディレクトリを取得
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
#保存先ディレクトリを作成 
set strPrefixName to ocidPrefixName as text
#ディレクトリ名はお好みで
set ocidSaveDirName to (strPrefixName & "_images") as text
#保存先ディレクトリURL
set ocidSaveFileDirPathURL to (ocidContainerDirURL's URLByAppendingPathComponent:ocidSaveDirName isDirectory:true)
#フォルダ作成
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions))
set listDone to (appFileManager's createDirectoryAtURL:(ocidSaveFileDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
if (item 2 of listDone) ≠ (missing value) then
	set strErrorNO to (item 2 of listDone)'s code() as text
	set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "エラーしました" & strErrorNO & strErrorMes
end if

##############################
#ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
#
set listResolution to {"72", "96", "120", "144", "150", "216", "288", "300", "360"} as list
try
	set listResponse to (choose from list listResolution with title "選んでください\n解像度が高いとそれなりに時間がかかります" with prompt "解像度を選んでください" default items (item 4 of listResolution) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResolution to (item 1 of listResponse) as text
#設定項目　出力解像度 ppi
set numResolution to strResolution as integer

#####################
#### 本処理
#####################
#保存時のカラープロファイルを読み出しておく ファイルはお好みで
set strIccFilePath to "/System/Library/ColorSync/Profiles/Generic CMYK Profile.icc"
set ocidIccFilePathStr to (refMe's NSString's stringWithString:strIccFilePath)
set ocidIccFilePath to ocidIccFilePathStr's stringByStandardizingPath
set ocidIccFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIccFilePath) isDirectory:false)
set ocidProfileData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidIccFilePathURL)

#PDFファイルを格納
set ocidActivDoc to refMe's PDFDocument's alloc()'s initWithURL:(ocidFilePathURL)
#ページ数
set numPageCnt to ocidActivDoc's pageCount() as integer
#ページ順に処理
repeat with itemPageNo from 0 to (numPageCnt - 1) by 1
	#PDFの対象ページを格納
	set ocidPdfPage to (ocidActivDoc's pageAtIndex:(itemPageNo))
	#注釈を削除
	(ocidPdfPage's setDisplaysAnnotations:(true))
	set ocidAnotationArray to ocidPdfPage's annotations()
	repeat with itemAnotationArray in ocidAnotationArray
		(ocidPdfPage's removeAnnotation:(itemAnotationArray))
	end repeat
	(ocidPdfPage's setDisplaysAnnotations:(false))
	(ocidPdfPage's removeAnnotation:(ocidAnotationArray))
	#CROPサイズを取得しておくpt
	set ocidPageRect to (ocidPdfPage's boundsForBox:(refMe's kPDFDisplayBoxCropBox))
	set numPDFPtWidth to refMe's NSWidth(ocidPageRect)
	set numPDFPtHeight to refMe's NSHeight(ocidPageRect)
	set ocidPageSize to refMe's NSSize's NSMakeSize(numPDFPtWidth, numPDFPtHeight)
	#サイズセットする比率
	set numSetResolution to (numResolution / 72.0) as number
	#出力イメージピクセルサイズ
	set numPxWidth to ((numPDFPtWidth * numSetResolution) div 1) as integer
	set numPxHeigh to ((numPDFPtHeight * numSetResolution) div 1) as integer
	#今回の処理は仕上がりピクセルサイズを偶数にすることを優先している
	if ((numPxWidth / 2) mod 1) > 0 then
		set numPxWidth to numPxWidth + 1
		set numPxHeigh to numPxHeigh + 1
	end if
	if ((numPxHeigh / 2) mod 1) > 0 then
		set numPxHeigh to numPxHeigh + 1
	end if
	#出力用の解像度をセットするためのNSSize'sをピクセルサイズから生成
	set numSetPtSizeW to (numPxWidth / numSetResolution) as number
	set numSetPtSizeH to (numPxHeigh / numSetResolution) as number
	set ocidSetImageSize to refMe's NSSize's NSMakeSize(numSetPtSizeW, numSetPtSizeH)
	
	#描画するRECT
	set ocidDrawRect to refMe's NSRect's NSMakeRect(0, 0, numPxWidth, numPxHeigh)
	#コピーしてくるRECT＝PDFのページPTサイズ
	set ocidFromRect to refMe's NSRect's NSMakeRect(0, 0, numPDFPtWidth, numPDFPtHeight)
	#NSDATAに
	set ocidDataRep to ocidPdfPage's dataRepresentation()
	#NSDATAに格納
	set ocidPageData to (refMe's NSData's alloc()'s initWithData:(ocidDataRep))
	#NSPDFImageRepに変換
	set ocidPagePep to (refMe's NSPDFImageRep's alloc()'s initWithData:(ocidDataRep))
	#念の為最初のページをセット
	(ocidPagePep's setCurrentPage:(0))
	#出力される画像（アートボード）＝解像度換算のピクセルサイズ
	set ocidAardboardRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numPxWidth) pixelsHigh:(numPxHeigh) bitsPerSample:(8) samplesPerPixel:(4) hasAlpha:(false) isPlanar:(false) colorSpaceName:(refMe's NSDeviceCMYKColorSpace) bitmapFormat:(refMe's NSBitmapFormatAlphaNonpremultiplied) bytesPerRow:(0) bitsPerPixel:(32))
	#
	(ocidAardboardRep's setProperty:(refMe's NSImageColorSyncProfileData) withValue:(ocidProfileData))
	
	########################
	#NSGraphicsContext初期化
	set appGraphicsContext to (refMe's NSGraphicsContext)
	#編集開始
	appGraphicsContext's saveGraphicsState()
	#アートボード画像読み込み
	set ocidContext to (appGraphicsContext's graphicsContextWithBitmapImageRep:(ocidAardboardRep))
	#アートボード画像をContextとしてセット
	(appGraphicsContext's setCurrentContext:(ocidContext))
	#PDFpageRepをアートボードにペースト
	(ocidPagePep's drawInRect:(ocidDrawRect) fromRect:(ocidFromRect) operation:(refMe's NSCompositeSourceOver) fraction:(1.0) respectFlipped:(false) hints:(missing value))
	#編集終了
	appGraphicsContext's restoreGraphicsState()
	
	##################
	#変換設定 オプション設定
	set ocidPropertyDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidPropertyDict's setValue:(0.0) forKey:(refMe's NSImageCompressionFactor))
	(ocidPropertyDict's setValue:(refMe's NSTIFFCompressionNone) forKey:(refMe's NSImageCompressionMethod))
	(ocidPropertyDict's setValue:(missing value) forKey:(refMe's NSImageIPTCData))
	(ocidPropertyDict's setValue:(missing value) forKey:(refMe's NSImageEXIFData))
	(ocidPropertyDict's setValue:(ocidProfileData) forKey:(refMe's NSImageColorSyncProfileData))
	
	set ocidFileType to (refMe's NSBitmapImageFileTypeTIFF)
	set strExtension to "tiff"
	#サイズ指定 ここで解像度が決まる
	(ocidAardboardRep's setSize:(ocidSetImageSize))
	#変換
	set ocidNSInlineData to (ocidAardboardRep's representationUsingType:(ocidFileType) |properties|:(ocidPropertyDict))
	
	###################
	###ページ数連番ゼロサプレス
	set strZeroAdd to ("0000" & (itemPageNo + 1)) as text
	set strPageNO to text -4 through -1 of strZeroAdd as text
	###ファイル名に整形して
	set strSaveImageFileName to ("" & strPrefixName & "." & strPageNO & "." & strExtension & "") as text
	####保存先URL
	set ocidSaveFilePathURL to (ocidSaveFileDirPathURL's URLByAppendingPathComponent:strSaveImageFileName isDirectory:false)
	#####保存
	set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference))
	#一応リセットしたりして
	set ocidAardboardRep to ""
	set ocidNSInlineData to ""
	set ocidBmpImageRep to ""
	set ocidOsDispatchData to ""
	set ocidPageImageData to ""
end repeat
#保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveFileDirPathURL)

return "処理終了"

