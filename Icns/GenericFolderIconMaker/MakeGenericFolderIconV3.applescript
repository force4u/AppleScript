#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# https://github.com/force4u/AppleScript/tree/main/Icns/GenericFolderIconMaker
#	デフォルトのアイコンイメージを生成して作成するように変更
#	アイコンイメージにドロップシャドウが入るようにした
# JPEGとPNGの画像　縦横比が同じでない画像に対応した
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application

###########################################
### フォルダ色選択
###########################################
set listGenericFolderIcon to {"ダーク通常", "ライト通常", "ダークサーチ", "ライトサーチ"} as list

###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listGenericFolderIcon with title "選んでください" with prompt "元になるアイコンを選択" default items (item 2 of listGenericFolderIcon) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text

if strResponse is "ダーク通常" then
	set boolLight to false as boolean
	set boolSmartFolder to false as boolean
else if strResponse is "ライト通常" then
	set boolLight to true as boolean
	set boolSmartFolder to false as boolean
else if strResponse is "ダークサーチ" then
	set boolLight to false as boolean
	set boolSmartFolder to true as boolean
else if strResponse is "ライトサーチ" then
	set boolLight to true as boolean
	set boolSmartFolder to true as boolean
end if
###########################################
###デフォルトアイコンデータ取得
###########################################
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDir to (container of aliasPathToMe) as alias
end tell
###保存先確保
set strContainerDirPath to (POSIX path of aliasContainerDir) as text
set ocidContainerDirPathStr to refMe's NSString's stringWithString:(strContainerDirPath)
set ocidContainerDirPath to ocidContainerDirPathStr's stringByStandardizingPath()
set ocidContainerDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true)
set ocidSaveDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("Images")
##
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
##
###########################################
###Assets.carからIconイメージを書き出す
###########################################
set strAssetsFilePath to ("/System/Library/PrivateFrameworks/IconFoundation.framework/Versions/A/Resources/Assets.car") as text
set listIconSetName to {"Folder", "FolderDark", "SmartFolder", "SmartFolderDark"} as list
repeat with itemIconSetName in listIconSetName
	###アイコン名
	set strIconSetName to itemIconSetName as text
	###保存先名　iconset
	set strIconSetDirName to (itemIconSetName & ".iconset") as text
	set ocidIconSaveDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strIconSetDirName))
	set strIconSetSaveDirPath to (ocidIconSaveDirPathURL's |path|()) as text
	###フォルダを作る
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidIconSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
	set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strAssetsFilePath & "\" " & strIconSetName & " -o \"" & strIconSetSaveDirPath & "\"") as text
	do shell script strCommandText
	
end repeat
###########################################
###元になるフォルダーのアイコンイメージ
###########################################


##ここでアイコンのサイズ決めている
set numWidth to 512 as integer
set numHight to 512 as integer
####ライト　か　ダークか
if boolLight is true then
	if boolSmartFolder is true then
		set ocidGenericFolderIconPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("SmartFolder.iconset/icon_512x512.png")
	else
		set ocidGenericFolderIconPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("Folder.iconset/icon_512x512.png")
	end if
else if boolLight is false then
	if boolSmartFolder is true then
		set ocidGenericFolderIconPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("SmartFolderDark.iconset/icon_512x512.png")
	else
		set ocidGenericFolderIconPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("FolderDark.iconset/icon_512x512.png")
	end if
end if
##
set ocidGenIconImage to refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidGenericFolderIconPathURL)
set ocidGenIconImageRepArray to ocidGenIconImage's representations()
set ocidGenIconImageRep to (ocidGenIconImageRepArray's firstObject())

###########################################
###合成するアイコンファイルを選択
###########################################
set appFileManager to refMe's NSFileManager's defaultManager()
###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidApplicationDirPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidApplicationDirPathURL's absoluteURL()) as alias
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listUTI to {"com.apple.icns", "public.png", "public.jpeg"}
set strMes to ("拡張子icnsのファイルを選んでください") as text
set strPrompt to ("拡張子icnsのファイルを選んでください") as text
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strAddImagePath to (POSIX path of aliasFilePath) as text
set ocidAddImagePathStr to refMe's NSString's stringWithString:(strAddImagePath)
set ocidAddImagePath to ocidAddImagePathStr's stringByStandardizingPath()
set ocidAddImagePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddImagePath) isDirectory:false)
set ocidFileName to ocidAddImagePathURL's lastPathComponent()


###########################################
###合成するアイコンイメージを読み込む
###########################################
###CIイメージで読み込み
set ocidAddImageCI to (refMe's CIImage's imageWithContentsOfURL:(ocidAddImagePathURL) options:(missing value))
###ファイルのサイズを調べる
set ocidCGRect to ocidAddImageCI's extent()
####縦横の値を取得
set numImageWidth to refMe's CGRectGetWidth(ocidCGRect) as number
set numImageHeight to refMe's CGRectGetHeight(ocidCGRect) as number
if numImageWidth < numImageHeight then
	set numResizeScale to (256 / numImageHeight)
else
	####リサイズする指数
	set numResizeScale to (256 / numImageWidth)
end if

####Transform指定
set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationUp))
####Transform適応
set ocidCiImageData to (ocidAddImageCI's imageByApplyingTransform:recordCiImageData)
####Parameters
set listParameters to {inputImage:ocidCiImageData, inputScale:numResizeScale, inputAspectRatio:1.0}
####リサイズする指数でリサイズ
set ocidCiFilterData to (refMe's CIFilter's filterWithName:"CILanczosScaleTransform" withInputParameters:listParameters)
#####リサイズ済みイメージ
set ocidResizedCiImage to ocidCiFilterData's outputImage()
#####NSBitmapImageRepに変換して
set ocidResizedImagePep to refMe's NSBitmapImageRep's alloc()'s initWithCIImage:(ocidResizedCiImage)
set numResizedHigh to ocidResizedImagePep's pixelsHigh()
set numResizedWide to ocidResizedImagePep's pixelsWide()
if numImageWidth < numImageHeight then
	set numOffSetW to ((numResizedHigh - numResizedWide) / 2) as integer
	set numOffSetH to 0 as integer
else
	set numOffSetH to ((numResizedWide - numResizedHigh) / 2) as integer
	set numOffSetW to 0 as integer
end if


###########################################
###背景となる画像を作る
###########################################
set ocidSetColor to refMe's NSColor's colorWithDeviceRed:0 green:0 blue:0 alpha:1
set ocidBitmapFormat to refMe's NSBitmapFormatAlphaFirst
set ocidColorSpaceName to refMe's NSCalibratedRGBColorSpace
set ocidNSBitmapImageFileType to refMe's NSBitmapImageFileTypeTIFF
set ocidBitmapImageRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numWidth) pixelsHigh:(numHight) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(ocidColorSpaceName) bitmapFormat:(ocidBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
(refMe's NSGraphicsContext's setCurrentContext:(refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:ocidBitmapImageRep))
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

###########################################
###フォルダのイメージを重ねる
###########################################
refMe's NSGraphicsContext's saveGraphicsState()
###生成された画像でNSGraphicsContext初期化
set ocidContext to refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidBitmapImageRep)
refMe's NSGraphicsContext's setCurrentContext:(ocidContext)
set ocidFromRect to {origin:{x:0, y:0}, |size|:{width:512, Hight:512}}
set ocidDrawRect to {origin:{x:0, y:0}, |size|:{width:512, Hight:512}}
####フォルダ画像を背景画像上に配置する
set ocidOption to (refMe's NSCompositingOperationSourceOver)
log (ocidGenIconImageRep's drawInRect:(ocidDrawRect) fromRect:(ocidFromRect) operation:(ocidOption) fraction:1.0 respectFlipped:true hints:(missing value))
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

###########################################
###ドロップシャドウ生成
###########################################
set ocidShadow to refMe's NSShadow's alloc()'s init()
set ocidShadowColor to (refMe's NSColor's colorWithDeviceRed:0 green:0 blue:0 alpha:0.5)
ocidShadow's setShadowColor:(ocidShadowColor)
ocidShadow's setShadowBlurRadius:(4)
set ocidShadowSize to refMe's NSMakeSize(3, -3)
ocidShadow's setShadowOffset:(ocidShadowSize)
###########################################
###フォルダの上にアイコン画像を重ねる
###########################################
refMe's NSGraphicsContext's saveGraphicsState()
###生成された画像でNSGraphicsContext初期化
set ocidContext to refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidBitmapImageRep)
refMe's NSGraphicsContext's setCurrentContext:(ocidContext)
set ocidFromRect to {origin:{x:0, y:0}, |size|:{width:512, Hight:512}}
####
set numXoffSet to (128 + numOffSetW) as integer
set numYoffSet to (110 + numOffSetH) as integer
set ocidDrawRect to {origin:{x:(numXoffSet), y:(numYoffSet)}, |size|:{width:(256 * 2), Hight:(256 * 2)}}
###コマ画像を背景画像上に配置する
set ocidOption to (refMe's NSCompositingOperationSourceOver)
###ドロップシャドウ適応
ocidShadow's |set|()
log (ocidResizedImagePep's drawInRect:(ocidDrawRect) fromRect:(ocidFromRect) operation:(ocidOption) fraction:1.0 respectFlipped:true hints:(missing value))
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

###########################################
###出力用にTIFFに変換する
###########################################
set ocidNSBitmapImageRepPropertyKey to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####TIFF用の圧縮プロパティ(NSImageCompressionFactor)
ocidNSBitmapImageRepPropertyKey's setObject:0 forKey:(refMe's NSImageCompressionFactor)
####インラインデータに変換
set ocidNSBitmapImageFileType to refMe's NSBitmapImageFileTypeTIFF
set ocidNSInlineData to (ocidBitmapImageRep's representationUsingType:(ocidNSBitmapImageFileType) |properties|:(ocidNSBitmapImageRepPropertyKey))

###########################################
###フォルダにする
###########################################
set strDirName to doGetDateNo({"GGyy年MM月dd日EEEEahh時mm分ss秒", 2})
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set ocidMakeDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strDirName)
###フォルダ作って
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###########################################
###合成したアイコン画像はフォルダの中に
###########################################
set strTiffFileName to ((ocidFileName as text) & ".tiff") as text
set ocidSaveImagePathURL to ocidMakeDirPathURL's URLByAppendingPathComponent:(strTiffFileName)
###保存
set booleDone to (ocidNSInlineData's writeToURL:(ocidSaveImagePathURL) atomically:true)

###########################################
###フォルダにアイコンを付与する
###########################################
##NSIMAGEにして
set ocidAddIconImageSize to ocidBitmapImageRep's |size|()
set ocidAddIconImageData to refMe's NSImage's alloc()'s initWithSize:(ocidAddIconImageSize)
ocidAddIconImageData's addRepresentation:(ocidBitmapImageRep)
###フォルダにアイコン付与
set ocidAddIconDirPath to ocidMakeDirPathURL's |path|
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set booleDone to (appSharedWorkspace's setIcon:(ocidAddIconImageData) forFile:(ocidAddIconDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

return


################################
# 日付 doGetDateNo(argDateFormat,argCalendarNO)
# argCalendarNO 1 NSCalendarIdentifierGregorian 西暦
# argCalendarNO 2 NSCalendarIdentifierJapanese 和暦
################################
to doGetDateNo({argDateFormat, argCalendarNO})
	##渡された値をテキストで確定させて
	set strDateFormat to argDateFormat as text
	set intCalendarNO to argCalendarNO as integer
	###日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義（日本語）
	set ocidFormatterJP to current application's NSDateFormatter's alloc()'s init()
	###和暦　西暦　カレンダー分岐
	if intCalendarNO = 1 then
		set ocidCalendarID to (current application's NSCalendarIdentifierGregorian)
	else if intCalendarNO = 2 then
		set ocidCalendarID to (current application's NSCalendarIdentifierJapanese)
	else
		set ocidCalendarID to (current application's NSCalendarIdentifierISO8601)
	end if
	set ocidCalendarJP to current application's NSCalendar's alloc()'s initWithCalendarIdentifier:(ocidCalendarID)
	set ocidTimezoneJP to current application's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
	set ocidLocaleJP to current application's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
	###設定
	ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
	ocidFormatterJP's setLocale:(ocidLocaleJP)
	ocidFormatterJP's setCalendar:(ocidCalendarJP)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterNoStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterShortStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterMediumStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterLongStyle)
	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterFullStyle)
	###渡された値でフォーマット定義
	ocidFormatterJP's setDateFormat:(strDateFormat)
	###フォーマット適応
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
