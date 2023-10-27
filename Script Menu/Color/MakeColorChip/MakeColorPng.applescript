#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application


##############################
#####ダイアログ
##############################
##前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###カラーピッカー
try
	set the listRGB16bitColor to (choose color) as list
on error
	return "キャンセルしました"
end try

##########Color Picker Value 16Bit
set numRcolor16Bit to item 1 of listRGB16bitColor as number
set numGcolor16Bit to item 2 of listRGB16bitColor as number
set numBcolor16Bit to item 3 of listRGB16bitColor as number
##########Standard RGB Value 8Bit
set numRcolor8Bit to numRcolor16Bit / 256 div 1 as number
set numGcolor8Bit to numGcolor16Bit / 256 div 1 as number
set numBcolor8Bit to numBcolor16Bit / 256 div 1 as number
set strRcolor8Bit to numRcolor8Bit as text
set strGcolor8Bit to numGcolor8Bit as text
set strBcolor8Bit to numBcolor8Bit as text
##########NSColorValue Float
set numRcolorFloat to numRcolor8Bit / 255 as number
set numGcolorFloat to numGcolor8Bit / 255 as number
set numBcolorFloat to numBcolor8Bit / 255 as number
###
set strRGB8Bit to ((strRcolor8Bit) & "," & (strGcolor8Bit) & "," & (strBcolor8Bit)) as text
###
set strCommandText to ("/usr/bin/perl -e 'printf(\"%02X%02X%02X\"," & strRGB8Bit & ")'") as text
set strRGBHEX to (do shell script strCommandText) as text
set strRGBHEXenc to ("%23" & strRGBHEX) as text
set strRGBHEX to ("#" & strRGBHEX) as text
################################################
###画像サイズ
set intWidthPx to 720 as integer
set intHightPx to 960 as integer

###################################################
##【１】カラーチップ用画像生成
set ocidBitmapFormat to refMe's NSBitmapFormatAlphaFirst
set ocidColorSpaceName to refMe's NSDeviceRGBColorSpace
set ocidNSBitmapImageFileType to refMe's NSBitmapImageFileTypePNG
set ocidColorBoardRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(intWidthPx) pixelsHigh:(intWidthPx) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(ocidColorSpaceName) bitmapFormat:(ocidBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###Context 
set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidColorBoardRep))
###生成された画像でNSGraphicsContext初期化
(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
###塗り色
set ocidSetColor to (refMe's NSColor's colorWithDeviceRed:(numRcolorFloat) green:(numGcolorFloat) blue:(numBcolorFloat) alpha:1)
ocidSetColor's |set|()
##画像にする
refMe's NSRectFill({origin:{x:0, y:0}, |size|:{width:intWidthPx, height:intWidthPx}})
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

###################################################
##【２】アートボード画像生成開始
set ocidArtBoardRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(intWidthPx) pixelsHigh:(intHightPx) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(ocidColorSpaceName) bitmapFormat:(ocidBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###Context 
set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidArtBoardRep))
###生成された画像でNSGraphicsContext初期化
(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
###塗り色
set ocidSetColor to (refMe's NSColor's colorWithDeviceRed:(1) green:(1) blue:(1) alpha:1)
ocidSetColor's |set|()
##画像にする
refMe's NSRectFill({origin:{x:0, y:0}, |size|:{width:intWidthPx, height:intHightPx}})
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

###################################################
##【３】テキスト生成
###設定用のレコード
set ocidTextAttr to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
###################
###文字色
set ocidTextColor to (refMe's NSColor's colorWithSRGBRed:(numRcolorFloat) green:(numGcolorFloat) blue:(numBcolorFloat) alpha:(1))
(ocidTextAttr's setObject:(ocidTextColor) forKey:(refMe's NSForegroundColorAttributeName))
###################
##行間
set ocidStyle to refMe's NSParagraphStyle's defaultParagraphStyle
(ocidTextAttr's setObject:(ocidStyle) forKey:(refMe's NSParagraphStyleAttributeName))
###################
##カーニング
set ocidKern to 0
(ocidTextAttr's setObject:(ocidKern) forKey:(refMe's NSKernAttributeName))
##ドロップシャドウ
set ocidShadow to refMe's NSShadow's alloc()'s init()
set ocidShadowColor to (refMe's NSColor's colorWithDeviceRed:0 green:0 blue:0 alpha:0.5)
(ocidShadow's setShadowColor:(ocidShadowColor))
(ocidShadow's setShadowOffset:(refMe's NSMakeSize(1, -1)))
(ocidShadow's setShadowBlurRadius:4)
(ocidTextAttr's setObject:(ocidShadow) forKey:(refMe's NSShadowAttributeName))
###描画するテキスト
set ocidTextHEX to (refMe's NSString's stringWithString:(strRGBHEX))
##フォント サイズ
set ocidFont to (refMe's NSFont's fontWithName:("Helvetica-Bold") |size|:144)
(ocidTextAttr's setObject:(ocidFont) forKey:(refMe's NSFontAttributeName))
####描画されるテキストボックスのサイズ
set ocidTextSizeHEX to (ocidTextHEX's sizeWithAttributes:(ocidTextAttr))
set ocidTextCgPointHEX to refMe's NSMakePoint(20, 100)

###################################
#####テキスト描画　本処理 HEX
####NSGraphicsContextは２で作ったアートボード
set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidArtBoardRep))
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###透明アートボードでNSGraphicsContext初期化
(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
###テキスト描画する
(ocidTextHEX's drawAtPoint:(ocidTextCgPointHEX) withAttributes:(ocidTextAttr))
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()
#####################
###描画するテキスト
set ocidTextRGB to (refMe's NSString's stringWithString:("rgb(" & strRcolor8Bit & ", " & strGcolor8Bit & ", " & strBcolor8Bit & ")"))
##フォント サイズ
set ocidFont to (refMe's NSFont's fontWithName:("Helvetica-Bold") |size|:72)
(ocidTextAttr's setObject:(ocidFont) forKey:(refMe's NSFontAttributeName))
####描画されるテキストボックスのサイズ
set ocidTextSizeRGB to (ocidTextRGB's sizeWithAttributes:(ocidTextAttr))
set ocidTextCgPointRGB to refMe's NSMakePoint(20, 20)
###################################
#####テキスト描画　本処理　RGB
####NSGraphicsContextは２で作ったアートボード
set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidArtBoardRep))
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###透明アートボードでNSGraphicsContext初期化
(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
###テキスト描画する
(ocidTextRGB's drawAtPoint:(ocidTextCgPointRGB) withAttributes:(ocidTextAttr))
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()


###################################################
##【４】１で作った色画像を２で作ったアートボードにペーストNSCompositeSourceOver
###初期化 CodeBase
refMe's NSGraphicsContext's saveGraphicsState()
###Context
set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidArtBoardRep))
###生成された画像でNSGraphicsContext初期化
(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
###出来上がった画像にQRバーコードをCompositeSourceOverする
ocidColorBoardRep's drawInRect:{origin:{x:(0), y:(240)}, |size|:{width:(intWidthPx), Hight:(intWidthPx)}} fromRect:{origin:{x:0, y:0}, |size|:{width:(intWidthPx), height:(intWidthPx)}} operation:(refMe's NSCompositeSourceOver) fraction:1.0 respectFlipped:true hints:(missing value)
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

#############################
### 【５】画像データ保存
### ４で生成された画像に対を
### 指定のフォルダに保存する
#############################
####PNG用の圧縮プロパティ
set ocidNSSingleEntryDictionary to refMe's NSDictionary's dictionaryWithObject:true forKey:(refMe's NSImageInterlaced)
#####出力イメージへ変換
set ocidNSInlineData to (ocidArtBoardRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:ocidNSSingleEntryDictionary)
#####################
### 保存先　NSDownloadsDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
###保存ファイル名
set strSaveFileName to (strRGBHEX & ".png") as text
set ocidSaveFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
### 保存
set ocidOption to (refMe's NSDataWritingAtomic)
set boolDone to ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias



##################
##リンクさせる場合（レスポンシブ）
set strHTML to ("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>" & strRGBHEX & "</title><style>body{background-color: #FFFFF;}</style></head><body><img src=\"./" & strRGBHEXenc & ".png\" style=\"height: 82vh; margin-top: 9vh; margin-left: 9vh\"><p>" & strRGBHEX & "</p><p>" & "rgb(" & strRcolor8Bit & ", " & strGcolor8Bit & ", " & strBcolor8Bit & ")" & "</p></body></html>") as text


##データにして
set ocidSaveHTML to refMe's NSString's stringWithString:(strHTML)
##保存
set strFileName to (strRGBHEX & ".html") as text
set ocidHTMLFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strFileName)
set listDone to (ocidSaveHTML's writeToURL:(ocidHTMLFilePathURL) atomically:(refMe's NSNumber's numberWithBool:true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))

###保存先を開く
set appSharedWorkSpave to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkSpave's selectFile:(ocidSaveFilePathURL's |path|) inFileViewerRootedAtPath:(ocidDownloadsDirPathURL's |path|)

