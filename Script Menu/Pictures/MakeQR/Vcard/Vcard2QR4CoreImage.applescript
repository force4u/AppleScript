#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807
#####################
### QRコード保存先　NSPicturesDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Contacts")
##フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################
###ダイアログのデフォルトロケーション
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
#######
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
set strPrompt to "QRコードを作成します。"
set strMes to "QRコードを作成します。"
set listUTI to {"public.vcard"} as list
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI without invisibles, showing package contents and multiple selections allowed) as alias
#####################
###　ファイルのパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
#####################
###	テキストで読み込み
set listReadString to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidReadString to (item 1 of listReadString)
#####################
###	データ整形
set strChl to "BEGIN:VCARD\nVERSION:3.0" as text
###
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidStringsArray to ocidReadString's componentsSeparatedByCharactersInSet:(ocidChrSet)
###
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "FN:")
set ocidFullName to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
###
if (count of ocidFullName) = 0 then
	return "【エラー】フルネームが取得できませんでした"
else
	set ocidFullNameArray to (ocidFullName's firstObject())'s componentsSeparatedByString:(":")
	set strFullName to (last item of ocidFullNameArray) as list
	##ファイル名に開始日時を使う
	set strSaveFileName to ("VcardQR_" & strFullName & ".png") as text
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
	##
	set strChl to (strChl & "\n" & (ocidFullName's firstObject() as text)) as text
end if
####
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "N:")
set ocidN to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidN) > 0 then
	set strChl to (strChl & "\n" & (ocidN's firstObject() as text)) as text
end if
####
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "EMAIL;")
set ocidEMAIL to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidEMAIL) = 1 then
	set strChl to (strChl & "\n" & (ocidEMAIL's firstObject() as text)) as text
else if (count of ocidEMAIL) > 1 then
	set strChl to (strChl & "\n" & (ocidEMAIL's firstObject() as text)) as text
	set strChl to (strChl & "\n" & (ocidEMAIL's lastObject() as text)) as text
end if
##
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "TEL;")
set ocidTEL to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidTEL) = 1 then
	set strChl to (strChl & "\n" & (ocidTEL's firstObject() as text)) as text
else if (count of ocidTEL) > 1 then
	set strChl to (strChl & "\n" & (ocidTEL's firstObject() as text)) as text
	set strChl to (strChl & "\n" & (ocidTEL's lastObject() as text)) as text
end if
##
set strChl to (strChl & "\n" & "END:VCARD") as text
######################################
### 色決め　切り捨ての都合上指定のニア
######################################
###URLの取得に失敗しているパターン
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
tell application "Finder"
	set the listRGB16bitColor to (choose color default color {0, 0, 0, 1}) as list
end tell
##########Color Picker Value 16Bit
set numRcolor16Bit to item 1 of listRGB16bitColor as number
set numGcolor16Bit to item 2 of listRGB16bitColor as number
set numBcolor16Bit to item 3 of listRGB16bitColor as number
set numAcolor16Bit to 65535 as number
##########Standard RGB Value 8Bit
set numRcolor8Bit to numRcolor16Bit / 256 div 1 as number
set numGcolor8Bit to numGcolor16Bit / 256 div 1 as number
set numBcolor8Bit to numBcolor16Bit / 256 div 1 as number
set numAcolor8Bit to numAcolor16Bit / 256 div 1 as number
##########NSColorValue Float
set numRcolorFloat to numRcolor8Bit / 255 as number
set numGcolorFloat to numGcolor8Bit / 255 as number
set numBcolorFloat to numBcolor8Bit / 255 as number
set numAcolorFloat to numAcolor8Bit / 255 as number
####色指定
##	色指定値はこちらを利用
##	https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-d68270.html
###色指定する場合
##	set ocidQrColor to refMe's CIColor's colorWithRed:0.101960784314 green:0.752941176471 blue:0.262745098039 alpha:1.0
###
set ocidQrColor to refMe's CIColor's colorWithRed:numRcolorFloat green:numGcolorFloat blue:numBcolorFloat alpha:numAcolorFloat

#####################
###出来上がったEventテキスト
log strChl
set ocidInputString to refMe's NSString's stringWithString:(strChl)

####テキストをUTF8に
set ocidUtf8InputString to ocidInputString's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
####CIQRCodeGenerator初期化
set ocidQRcodeImage to refMe's CIFilter's filterWithName:"CIQRCodeGenerator"
ocidQRcodeImage's setDefaults()
###テキスト設定
ocidQRcodeImage's setValue:ocidUtf8InputString forKey:"inputMessage"
###読み取り誤差値設定L, M, Q, H
ocidQRcodeImage's setValue:"Q" forKey:"inputCorrectionLevel"
###QRコード本体のイメージ
set ocidCIImage to ocidQRcodeImage's outputImage()
-->ここで生成されるのはQRのセルが1x1pxの最小サイズ
###################################
#####色の置き換え
###################################

###置き換わる色＝この場合は黒
set ocidBlackColor to refMe's CIColor's colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0
###CIFalseColorで色を塗ります
set ocidFilterColor to refMe's CIFilter's filterWithName:"CIFalseColor"
ocidFilterColor's setDefaults()
ocidFilterColor's setValue:ocidQrColor forKey:"inputColor0"
ocidFilterColor's setValue:ocidBlackColor forKey:"inputColor1"
ocidFilterColor's setValue:ocidCIImage forKey:"inputImage"
###フィルタをかけた画像をoutputImageから取り出します
set ocidCIImage to ocidFilterColor's valueForKey:"outputImage"
###QRコードの縦横取得
set ocidCIImageDimension to ocidCIImage's extent()
set ocidCIImageWidth to (item 1 of item 2 of ocidCIImageDimension) as integer
set ocidCIImageHight to (item 2 of item 2 of ocidCIImageDimension) as integer
###最終的に出力したいpxサイズ
set numScaleMax to 580
###整数で拡大しないとアレなので↑の値のニアなサイズになります
set numWidth to ((numScaleMax / ocidCIImageWidth) div 1) as integer
set numHight to ((numScaleMax / ocidCIImageHight) div 1) as integer
###↑サイズの拡大縮小する場合はここで値を調整すれば良い
####変換スケール作成-->拡大
set recordScalse to refMe's CGAffineTransform's CGAffineTransformMakeScale(numWidth, numHight)
##変換スケールを適応（元のサイズに元のサイズのスケール適応しても意味ないけど
set ocidCIImageScaled to ocidCIImage's imageByApplyingTransform:recordScalse
#######元のセルが1x1pxの最小サイズで出したいときはここで処理
##set ocidCIImageScaled to ocidCIImage
###イメージデータを展開
set ocidNSCIImageRep to refMe's NSCIImageRep's imageRepWithCIImage:ocidCIImageScaled
###出力用のイメージの初期化
set ocidNSImageScaled to refMe's NSImage's alloc()'s initWithSize:(ocidNSCIImageRep's |size|())
###イメージデータを合成
ocidNSImageScaled's addRepresentation:ocidNSCIImageRep
###出来上がったデータはOS_dispatch_data 
set ocidOsDispatchData to ocidNSImageScaled's TIFFRepresentation()
####NSBitmapImageRepに
set ocidNSBitmapImageRep to refMe's NSBitmapImageRep's imageRepWithData:ocidOsDispatchData
#################################################################
###quiet zone用に画像をパディングする
set numPadWidth to ((ocidCIImageWidth * numWidth) + (numWidth * 6)) as integer
set numPadHight to ((ocidCIImageHight * numHight) + (numHight * 6)) as integer
###左右に4セル分づつ余白 quiet zoneを足す
####まずは元のQRコードのサイズに8セルサイズ分足したサイズの画像を作って
set ocidNSBitmapImagePadRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:numPadWidth pixelsHigh:numPadHight bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(refMe's NSCalibratedRGBColorSpace) bitmapFormat:(refMe's NSAlphaFirstBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###ビットマップイメージ
(refMe's NSGraphicsContext's setCurrentContext:(refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:ocidNSBitmapImagePadRep))
###塗り色を『白』に指定して
refMe's NSColor's whiteColor()'s |set|()
###画像にする
refMe's NSRectFill({origin:{x:0, y:0}, |size|:{width:numPadWidth, height:numPadHight}})
###出来上がった画像にQRバーコードを左右３セル分ずらした位置にCompositeSourceOverする
ocidNSBitmapImageRep's drawInRect:{origin:{x:(numWidth * 3), y:(numHight * 3)}, |size|:{width:numPadWidth, Hight:numPadHight}} fromRect:{origin:{x:0, y:0}, |size|:{width:numPadWidth, height:numPadHight}} operation:(refMe's NSCompositeSourceOver) fraction:1.0 respectFlipped:true hints:(missing value)
####画像作成終了
refMe's NSGraphicsContext's restoreGraphicsState()

#################################################################
####JPEG用の圧縮プロパティ
##set ocidNSSingleEntryDictionary to refMe's NSDictionary's dictionaryWithObject:1 forKey:(refMe's NSImageCompressionFactor)
####PNG用の圧縮プロパティ
set ocidNSSingleEntryDictionary to refMe's NSDictionary's dictionaryWithObject:true forKey:(refMe's NSImageInterlaced)

#####出力イメージへ変換
set ocidNSInlineData to (ocidNSBitmapImagePadRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:ocidNSSingleEntryDictionary)
(*
NSBitmapImageFileTypeJPEG
NSBitmapImageFileTypePNG
NSBitmapImageFileTypeGIF
NSBitmapImageFileTypeBMP
NSBitmapImageFileTypeTIFF
NSBitmapImageFileTypeJPEG2000
*)
###	保存
set ocidOption to (refMe's NSDataWritingAtomic)
set boolDone to ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
#####################
###Preview で開く
###
tell application "Preview"
	launch
	activate
	open aliasSaveFilePath
end tell

#####################
### Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())

---URLエンコードのサブルーチン
####################################
###### ％エンコード
####################################
on doUrlEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## 置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24", |\\n|:"%0A", |\\r|:"%0D"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidPercentMap's valueForKey:(itemAllKey))
		##置換
		set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##テキスト形式に確定
	set strTextToEncode to ocidEncodedText as text
	###値を戻す
	return strTextToEncode
end doUrlEncode
