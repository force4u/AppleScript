#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*	com.cocolog-nifty.quicktimer.icefloe
選択したファイルの
OS標準のアイコンを取得し
iconset画像を生成して
ICNSファイルにします=ユーザーの設定によって生成されるICNSもかわります
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
#############################
###ダイアログを前面に出す
set strName to (name of current application) as text
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
set listUTI to {"public.data"}
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
####ドキュメントのパス
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidContainerDirPath to ocidFilePath's stringByDeletingLastPathComponent()
set ocidIconFilePathURL to ocidFilePathURL's URLByAppendingPathExtension:("icns")
#　NSISIconImageRep を取り出す
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidIconImage to appSharedWorkspace's iconForFile:(ocidFilePath)
#　コンテンツタイプ　の取得
set ocidKey to (refMe's NSURLContentTypeKey)
set listRresourceValue to ocidFilePathURL's getResourceValue:(reference) forKey:(ocidKey) |error|:(reference)
set ocidContentType to (item 2 of listRresourceValue)
set ocidUTI to ocidContentType's identifier()
#	デフォルトのアプリケーションの取得
set ocidAppURL to appSharedWorkspace's URLForApplicationToOpenContentType:(ocidContentType)
log ocidAppURL's absoluteString() as text
#デフォルトアプリケーションのバンドルID
set ocidBunndle to refMe's NSBundle's bundleWithURL:(ocidAppURL)
set ocidBunndleID to ocidBunndle's bundleIdentifier()
#保存先確保
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
set ocidParentDirPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:("Icons/AppIcon") isDirectory:(true)
set ocidAppDirPathURL to ocidParentDirPathURL's URLByAppendingPathComponent:(ocidBunndleID) isDirectory:(true)
#通常用
set strSetValue to ((ocidUTI as text) & ".iconset") as text
set ocidSaveDirPathURL to ocidAppDirPathURL's URLByAppendingPathComponent:(strSetValue) isDirectory:(true)
#ダーク用
set strSetValue to ((ocidUTI as text) & "_Dark.iconset") as text
set ocidSaveDarkDirPathURL to ocidAppDirPathURL's URLByAppendingPathComponent:(strSetValue) isDirectory:(true)
#フォルダを作っておく
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
#通常用フォルダ
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#ダーク用フォルダ
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDarkDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
########################
#	Iconset作成開始
set ocidImageRepArray to ocidIconImage's representations()
set numCntDark to 0 as integer
repeat with itemImageRep in ocidImageRepArray
	#サイズ
	set ocidImageSize to itemImageRep's |size|()
	set numPointWide to (ocidImageSize's width) as integer
	set numPointHigh to (ocidImageSize's height) as integer
	#ピクセルサイズ
	set numPixelsWide to itemImageRep's pixelsWide() as integer
	set numPixelsHigh to itemImageRep's pixelsHigh() as integer
	#解像度の指数
	set numRatio to (numPixelsWide / numPointWide) as integer
	set numISIconImageRepWide to (numPointWide * numRatio) as integer
	set numISIconImageRepHigh to (numPointHigh * numRatio) as integer
	
	#保存用の解像度を加味したサイズ
	set ocidRatioSize to refMe's NSMakeSize(numPointWide, numPointHigh)
	#合成位置
	set ocidDrawRect to refMe's NSMakeRect(0, 0, numPixelsWide, numPixelsHigh)
	#アイコンデータ画像の読み取り位置
	set ocidFromRect to refMe's NSMakeRect(0, 0, numPointWide, numPointHigh)
	########################
	#	生成画像のサイズ
	set ocidAardboardSize to refMe's NSMakeSize(numPixelsWide, numPixelsHigh)
	#	保存される画像を生成
	set ocidAardboardImage to (refMe's NSImage's alloc()'s initWithSize:(ocidAardboardSize))
	#	画像生成
	set ocidAardboardRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numPixelsWide) pixelsHigh:(numPixelsHigh) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(refMe's NSCalibratedRGBColorSpace) bitmapFormat:(refMe's NSAlphaFirstBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
	########################
	# 画像合成の始まり
	set ocidGraphicsContext to refMe's NSGraphicsContext
	ocidGraphicsContext's saveGraphicsState()
	#コンテキストはアートボード保存用の画像
	(ocidGraphicsContext's setCurrentContext:(ocidGraphicsContext's graphicsContextWithBitmapImageRep:(ocidAardboardRep)))
	#↑このコンテキストに読み込んだアイコンイメージを合成する
	(itemImageRep's drawInRect:(ocidDrawRect) fromRect:(ocidFromRect) operation:(refMe's NSCompositeSourceOver) fraction:1.0 respectFlipped:false hints:(missing value))
	#画像合成の終わり
	ocidGraphicsContext's restoreGraphicsState()
	
	#出来上がった画像に解像度を付与
	(ocidAardboardRep's setSize:(ocidRatioSize))
	#解像度の違いによるファイル名の相違
	if numRatio = 1 then
		set strFileName to ("icon_" & numPixelsWide & "x" & numPixelsHigh) as text
	else
		set strFileName to ("icon_" & numPixelsWide & "x" & numPixelsHigh & "@" & numRatio & "x") as text
	end if
	#保存用のPNGフォーマットのプロパティ
	set ocidProperties to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidProperties's setObject:(2.2) forKey:(refMe's NSImageGamma))
	(ocidProperties's setObject:(0) forKey:(refMe's NSImageInterlaced))
	set ocidType to (refMe's NSBitmapImageFileTypePNG)
	set ocidSaveData to (ocidAardboardRep's representationUsingType:(ocidType) |properties|:(ocidProperties))
	set ocidOption to (refMe's NSDataWritingAtomic)
	
	if numCntDark = 0 then
		#保存先URL 通常用
		set ocidSaveBaseFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false))
		set ocidSaveFilePathURL to (ocidSaveBaseFilePathURL's URLByAppendingPathExtension:("png"))
		set numCntDark to numCntDark + 1 as integer
	else if numCntDark = 1 then
		#保存先URL ダーク用
		set ocidSaveBaseFilePathURL to (ocidSaveDarkDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false))
		set ocidSaveFilePathURL to (ocidSaveBaseFilePathURL's URLByAppendingPathExtension:("png"))
		set numCntDark to 0 as integer
	end if
	set listDone to (ocidSaveData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	
end repeat
########################
#icnsファイル生成開始

#入力フォルダパス
set strSaveDirPath to (ocidSaveDirPathURL's |path|()) as text
set strSaveDarkDirPath to (ocidSaveDarkDirPathURL's |path|()) as text
#出力ファイルURL
set ocidSaveIconsFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:("DocIcon.icns") isDirectory:(false))
set ocidSaveDarkIconsFilePathURL to (ocidSaveDarkDirPathURL's URLByAppendingPathComponent:("DocIcon.icns") isDirectory:(false))
#出力ファイルパス
set strSaveIconsFilePath to (ocidSaveIconsFilePathURL's |path|()) as text
set strSaveDarkIconsFilePath to (ocidSaveDarkIconsFilePathURL's |path|()) as text
#コマンド実行
set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strSaveDirPath & "/\" -o \"" & strSaveIconsFilePath & "\"") as text
do shell script strCommandText
set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strSaveDarkDirPath & "/\" -o \"" & strSaveDarkIconsFilePath & "\"") as text
do shell script strCommandText


###保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidOpenURLsArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
(ocidOpenURLsArray's addObject:(ocidSaveDarkDirPathURL))
(ocidOpenURLsArray's addObject:(ocidSaveDirPathURL))
appSharedWorkspace's activateFileViewerSelectingURLs:(ocidOpenURLsArray)






