#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
ダイアログ部ベーススクリプト
https://www.macscripter.net/t/edit-db123s-dialog-for-use-with-asobjc/73636/2
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
#use framework "Carbon"
use framework "CoreImage"
use scripting additions
#####################
###　基本設定
##	set strHidden to ("TRUE") as text
set strHidden to ("FALSE") as text
##	set strEncryption to ("WEP") as text
set strEncryption to ("WPA") as text

#####################
### 
property refMe : a reference to current application
property appDialogWindow : missing value
property strOneTextField : missing value
property strTwoTextField : missing value
property appCancelButton : missing value
property appOkButton : missing value
property strOne : missing value
property strTwo : missing value
property appOkClicked : false
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807
#####################
### QRコード保存先　NSPicturesDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Wifi")
##フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################
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

set dialogResult to my doShowDialog()
if dialogResult is missing value then
	return "【エラー】キャンセルしました"
end if
set strSSID to strOne of dialogResult
set strPSkey to strTwo of dialogResult
(*
1. S: SSID
2. T: WEPのセキュリティプロトコル
3. P: WIFIのパスワード
4. H: サネットワークを隠す※非推奨
5. Hidden: ネットワークを隠す※一般的ではない
6. EAP: 認証方法
7. EAP-Method:EAP認証メソッド
*)
set strQRContents to ("WIFI:S:" & strSSID & ";T:" & strEncryption & ";P:" & strPSkey & ";H:" & strHidden & ";") as text
##############################
###保存ファイル名
set strDateNo to doGetDateNo({"yyyyMMddhhmmss", 1})
set strSaveFileName to ("WIFI" & "." & strSSID & "." & strDateNo & ".png") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
######################################
### 色決め　切り捨ての都合上指定のニア
######################################
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

############################
####テキストをNSStringに
set ocidInputString to refMe's NSString's stringWithString:(strQRContents)
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


###################
###Preview で開く
tell application "Preview"
	launch
	activate
	open aliasSaveFilePath
end tell
###
#####################
### Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())

return true



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
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterNoStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterShortStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterMediumStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterLongStyle)
	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterFullStyle)
	###渡された値でフォーマット定義
	ocidFormatterJP's setDateFormat:(strDateFormat)
	###フォーマット適応
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


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
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
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


####################################
###### ダイアログ
####################################

on doShowDialog()
	if refMe's AEInteractWithUser(-1, missing value, missing value) ≠ 0 then
		return missing value
	end if
	if refMe's NSThread's isMainThread() then
		my doPerformDialog:(missing value)
	else
		its performSelectorOnMainThread:("doPerformDialog:") withObject:(missing value) waitUntilDone:true
	end if
	if my appOkClicked then
		return {strOne:my strOne as text, strTwo:my strTwo as text}
	end if
	return missing value
end doShowDialog

on doPerformDialog:(args)
	set strOneLabel to refMe's NSTextField's labelWithString:("SSIS:")
	strOneLabel's setFrame:(refMe's NSMakeRect(20, 85, 70, 20))
	
	set my strOneTextField to refMe's NSTextField's textFieldWithString:""
	strOneTextField's setFrame:(refMe's NSMakeRect(87, 85, 245, 20))
	strOneTextField's setEditable:true
	strOneTextField's setBordered:true
	strOneTextField's setPlaceholderString:("WIFIのアクセスポイント名")
	strOneTextField's setDelegate:(me)
	
	set strTwoLabel to refMe's NSTextField's labelWithString:("PSKey:")
	strTwoLabel's setFrame:(refMe's NSMakeRect(20, 55, 70, 20))
	
	set my strTwoTextField to refMe's NSTextField's textFieldWithString:("")
	strTwoTextField's setFrame:(refMe's NSMakeRect(87, 55, 245, 20))
	strTwoTextField's setEditable:true
	strTwoTextField's setBordered:true
	strTwoTextField's setPlaceholderString:("接続用暗号化パスワード")
	
	set my appCancelButton to refMe's NSButton's buttonWithTitle:"Cancel" target:me action:"doButtonAction:"
	appCancelButton's setFrameSize:{94, 32}
	appCancelButton's setFrameOrigin:{150, 10}
	appCancelButton's setKeyEquivalent:(character id 27)
	
	set my appOkButton to refMe's NSButton's buttonWithTitle:"OK" target:me action:"doButtonAction:"
	appOkButton's setFrameSize:{94, 32}
	appOkButton's setFrameOrigin:{245, 10}
	appOkButton's setKeyEquivalent:return
	appOkButton's setEnabled:false
	
	set ocidWindowSize to refMe's NSMakeRect(0, 0, 355, 125)
	set ocidWinStyle to (refMe's NSWindowStyleMaskTitled as integer) + (refMe's NSWindowStyleMaskClosable as integer)
	set my appDialogWindow to refMe's NSWindow's alloc()'s initWithContentRect:(ocidWindowSize) styleMask:(ocidWinStyle) backing:(refMe's NSBackingStoreBuffered) defer:true
	
	appDialogWindow's contentView()'s addSubview:(strOneLabel)
	appDialogWindow's contentView()'s addSubview:(strOneTextField)
	appDialogWindow's contentView()'s addSubview:(strTwoLabel)
	appDialogWindow's contentView()'s addSubview:(strTwoTextField)
	appDialogWindow's contentView()'s addSubview:(appCancelButton)
	appDialogWindow's contentView()'s addSubview:(appOkButton)
	
	appDialogWindow's setTitle:"WIFI接続用QRバーコード作成"
	appDialogWindow's setLevel:(refMe's NSModalPanelWindowLevel)
	appDialogWindow's setDelegate:(me)
	appDialogWindow's orderFront:(me)
	appDialogWindow's |center|()
	
	refMe's NSApp's activateIgnoringOtherApps:true
	refMe's NSApp's runModalForWindow:(appDialogWindow)
end doPerformDialog:

on doButtonAction:(sender)
	if sender is my appOkButton then
		set my strOne to strOneTextField's stringValue()
		set my strTwo to strTwoTextField's stringValue()
		set my appOkClicked to true
	end if
	my appDialogWindow's |close|()
end doButtonAction:

on controlTextDidChange:(objNotification)
	set sender to objNotification's object()
	if sender is my strOneTextField then
		if sender's stringValue() as text ≠ "" then
			my (appOkButton's setEnabled:true)
		else
			my (appOkButton's setEnabled:false)
		end if
	end if
end controlTextDidChange:

on windowWillClose:(objNotification)
	refMe's NSApp's stopModal()
end windowWillClose:
