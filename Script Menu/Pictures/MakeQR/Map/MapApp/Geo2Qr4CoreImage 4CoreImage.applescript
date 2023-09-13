#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
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
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Map")
##フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

#####################
### リセット
tell application id "com.apple.Maps" to activate
set strURL to "" as text
tell application "Finder"
	set the clipboard to the strURL as string
end tell
#####################
###コピーのサブへ
doCopyMap()

###クリップボードからURLを取得する
tell application "Finder"
	repeat 10 times
		set strURL to (the clipboard) as text
		if strURL is "" then
			delay 0.1
		else
			log "strURL:" & strURL
			exit repeat
		end if
	end repeat
end tell

if strURL is "" then
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidStringData to appPasteboard's stringForType:("public.utf8-plain-text")
	set ocidText to (refMe's NSString's stringWithString:(ocidStringData))
	set strURL to ocidText
end if

#####################
if strURL is "" then
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
	set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" as alias
	set strDefaultAnswer to "https://maps.apple.com/?ll=35.658558,139.745504" as text
	try
		set objResponse to (display dialog "URLの取得" with title "QRテキスト" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	on error
		log "エラーしました"
		return
	end try
	if true is equal to (gave up of objResponse) then
		return "時間切れですやりなおしてください"
	end if
	if "OK" is equal to (button returned of objResponse) then
		set strURL to (text returned of objResponse) as text
	else
		return "キャンセル"
	end if
end if

############################
##値がコピー出来なかったときエラーになるので
##ここはトライ
try
	####################################
	###URLをNSURLに格納
	set ocidURL to refMe's NSURL's alloc's initWithString:(strURL)
	log className() of ocidURL as text
	--> NSURL
	####################################
	###クエリー部を取り出し
	set ocidQueryUrl to ocidURL's query
	log className() of ocidQueryUrl as text
	--> __NSCFString
	log ocidQueryUrl as text
on error
	###エラーしたらコピー取り直し
	tell application "Maps"
		tell application "System Events"
			tell process "Maps"
				key code 53
			end tell
		end tell
	end tell
	doCopyMap()
	tell application "Finder"
		repeat 10 times
			set strURL to (the clipboard) as text
			if strURL is "" then
				delay 0.1
			else
				log "strURL:" & strURL
				exit repeat
			end if
		end repeat
	end tell
	####################################
	###URLをNSURLに格納
	set ocidURLstr to refMe's NSString's alloc()'s initWithString:(strURL)
	set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLstr)
	log ocidURL's absoluteString() as text
	
	
	####################################
	###クエリー部を取り出し
	set ocidQueryUrl to ocidURL's query
	log className() of ocidQueryUrl as text
	--> __NSCFString
	log ocidQueryUrl as text
end try

####################################
###取り出したクエリを＆を区切り文字でリストに
set ocidArrayComponent to (ocidQueryUrl's componentsSeparatedByString:"&")
log className() of ocidArrayComponent as text
--> __NSArrayM
log ocidArrayComponent as list

####################################
####可変レコードを作成
set ocidRecordQuery to refMe's NSMutableDictionary's alloc()'s init()
####値が空のレコードを定義
set recordQuery to {t:"", q:"", address:"", near:"", ll:"", z:"18", spn:"", saddr:"", daddr:"", dirflg:"", sll:"", sspn:"", ug:""} as record
####↑の定義で値が空の可変レコードを作成
set ocidRecordQuery to refMe's NSMutableDictionary's dictionaryWithDictionary:recordQuery
####################################
###ここからクエリー分繰り返し
repeat with objArrayComponent in ocidArrayComponent
	#####渡されたクエリーを＝を境に分割してArray＝リストにする
	set ocidArrayFirstObject to (objArrayComponent's componentsSeparatedByString:"=")
	
	####まずは順番に　キー　と　値　で格納
	set ocidKey to item 1 of ocidArrayFirstObject
	log ocidKey as text
	
	set ocidValue to item 2 of ocidArrayFirstObject
	log ocidValue as text
	
	#########位置情報　緯度 経度
	if (ocidKey as text) = "ll" then
		set ll of ocidRecordQuery to ocidValue
		####カンマでわけて緯度 経度に
		set ocidArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidArrayLL as list
		###最初の項目
		set ocidLatitude to item 1 of ocidArrayLL
		log "Latitude:" & ocidLatitude as text
		###あとの項目
		set ocidLongitude to item 2 of ocidArrayLL
		log "Longitude:" & ocidLongitude as text
		
		#########Address String  住所
	else if (ocidKey as text) = "address" then
		set address of ocidRecordQuery to ocidValue
		set ocidAddEnc to ocidValue's stringByRemovingPercentEncoding
		log "AddressString:" & ocidAddEnc as text
		
		#########The zoom level.　高さ方向
	else if (ocidKey as text) = "z" then
		set z of ocidRecordQuery to ocidValue
		set ocidZoomValue to ocidValue
		log "ZoomValue:" & ocidZoomValue
		
		#########マップビュー 
	else if (ocidKey as text) = "t" then
		set t of ocidRecordQuery to ocidValue
		set ocidMapType to ocidValue
		log "MapType:" & ocidMapType
		(*
		m (standard view)
		k (satellite view)
		h (hybrid view)
		r (transit view)
		goole
		map_action=pano
		map_action=map
		basemap=satellite
		terrain
		roadmap
		*)
		####################################
		#########dirflg 移動方法	
	else if (ocidKey as text) = "dirflg" then
		set dirflg of ocidRecordQuery to ocidValue
		set ocidDirflgType to ocidValue
		log "DirflgType:" & ocidDirflgType
		(*
		d (by car)
		w (by foot) 
		r (by public transit)
		
		goole
		travelmode=driving
		walking
		transit
			*)
		
		#########Dirflg Parameters 出発点
	else if (ocidKey as text) = "saddr" then
		set saddr of ocidRecordQuery to ocidValue
		set strSaddrEnc to ocidValue as text
		set ocidSaddrEnc to ocidValue's stringByRemovingPercentEncoding
		log "StartingPoint:" & ocidSaddrEnc as text
		
		#########Destination  到着店
	else if (ocidKey as text) = "daddr" then
		set daddr of ocidRecordQuery to ocidValue
		set strDaddrEnc to ocidValue as text
		set ocidDaddrEnc to ocidValue's stringByRemovingPercentEncoding
		log "DestinationPoint:" & ocidDaddrEnc as text
		
		#########Search Query　検索語句
	else if (ocidKey as text) = "q" then
		set q of ocidRecordQuery to ocidValue
		set strRecordQuery to ocidValue as text
		set ocidSearchQueryEnc to ocidValue's stringByRemovingPercentEncoding
		log "SearchQuery" & ocidSearchQueryEnc as text
		
		####################################
		#########語句検索時の周辺情報の有無による分岐
		
	else if (ocidKey as text) = "sll" then
		set sll of ocidRecordQuery to ocidValue
		####カンマでわけて緯度 経度に
		set ocidSearchArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidSearchArrayLL as list
		####最初の項目
		set ocidNearLatitude to item 1 of ocidSearchArrayLL
		log "NearLatitude:" & ocidNearLatitude as text
		####あとの項目
		set ocidNearLongitude to item 2 of ocidSearchArrayLL
		log "NearNearLongitude:" & ocidNearLongitude as text
		
	else if (ocidKey as text) = "spn" then
		####周囲情報の範囲
		set spn of ocidRecordQuery to ocidValue
		
		
		####################################
		#########during search周辺 位置情報 緯度 経度
		
	else if (ocidKey as text) = "near" then
		set near of ocidRecordQuery to ocidValue
		####カンマでわけて緯度 経度に
		set ocidNearArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidNearArrayLL as list
		###最初の項目
		set ocidNearLatitude to item 1 of ocidNearArrayLL
		log "NearLatitude:" & ocidNearLatitude as text
		###あとの項目
		set ocidNearLongitude to item 2 of ocidNearArrayLL
		log "NearNearLongitude:" & ocidNearLongitude as text
		
		####################################
		#########ガイド時のug
	else if (ocidKey as text) = "ug" then
		set ug of ocidRecordQuery to ocidValue
		
	end if
	
end repeat

log ocidRecordQuery as record


####################################################
#########対応アプリの分岐
###ホスト名を取り出し
set ocidHostUrl to ocidURL's |host|
log className() of ocidHostUrl as text
--> __NSCFString
log ocidHostUrl as text
####################################
###ホストによる分岐
if (ocidHostUrl as text) is "guides.apple.com" then
	-->このままの値でバーコードを作成する
	set listButtonAset to {"AppleMapガイド用"} as list
	set strAlertMes to "ガイドリンクはAppleMap専用です"
	
else if (ocidHostUrl as text) is "collections.apple.com" then
	-->コレクションは現在は『ガイド』になった？
	set listButtonAset to {"AppleMapガイド用"} as list
	set strAlertMes to "ガイドリンクはAppleMap専用です"
	
else if (ocidHostUrl as text) is "maps.apple.com" then
	-->ガイド以外
	-->処理する
	####################################
	###内容によっての分岐
	if (ll of ocidRecordQuery as text) is not "" then
		######緯度経度がある場合
		set listButtonAset to {"AppleMap用", "GoogleMap用", "GeoQR"} as list
		set strAlertMes to "GeoQRは対応していない機種やアプリがあります"
		
	else if (q of ocidRecordQuery as text) is not "" then
		######検索語句がある場合
		set listButtonAset to {"AppleMap用", "GoogleMap用", "汎用"} as list
		set strAlertMes to "iOS用AppleMapのQRコードを作成する OR 一般的なQRコードを作成する"
		
	else if (daddr of ocidRecordQuery as text) is not "" then
		set listButtonAset to {"AppleMap経路", "GoogleMap経路"} as list
		set strAlertMes to "経路情報用のMapになります"
		
	else
		######緯度経度無し検索語句無しだとAppleMapのみ
		set listButtonAset to {"AppleMap用のみ"} as list
		set strAlertMes to "ガイドリンクはAppleMap専用です"
		
	end if
end if
##############################################
log listButtonAset
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
try
	##	set objAns to (display alert "どちら用のQRコードを作成しますか？" message strAlertMes default button 1 buttons listButtonAset)
	set listResponse to (choose from list listButtonAset with title "短め" with prompt strAlertMes default items (item 1 of listButtonAset) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	
on error
	log "エラーしました"
	return
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set objResponse to (item 1 of listResponse) as text

## 	set objResponse to (button returned of objAns) as text
##############################################

if objResponse is "GeoQR" then
	### 緯度経度でGEOバーコード　対応機種に制限がある場合あり
	set theChl to ("GEO:" & (ocidLatitude as text) & "," & (ocidLongitude as text) & "," & (z of ocidRecordQuery as text) & "") as text
	###経路情報　Map
else if objResponse is "AppleMap経路" then
	set theChl to ("http://maps.apple.com/?daddr=" & (ocidDaddrEnc as text) & "&saddr=" & (ocidSaddrEnc as text) & "") as text
	###経路情報　Google
else if objResponse is "GoogleMap経路" then
	set theChl to ("https://www.google.com/maps/?daddr=" & (ocidDaddrEnc as text) & "&saddr=" & (ocidSaddrEnc as text) & "") as text
	####AppleMapのガイドリンク
else if objResponse is "AppleMapガイド用" then
	set theChl to ("" & strURL & "") as text
	
else if objResponse is "GoogleMap用" then
	##############################################
	###GoogleMap用の小数点以下の桁揃え
	###逆ゼロサプレス
	set theLatitude to (ocidLatitude as text)
	set AppleScript's text item delimiters to "."
	set listLatitude to every text item of theLatitude as list
	set AppleScript's text item delimiters to ""
	set strLatitudeInt to text item 1 of listLatitude as text
	set strLatitudeDecimal to text item 2 of listLatitude as text
	set strLatitudeDecimal to (text 1 through 7 of (strLatitudeDecimal & "000000000")) as text
	set theLatitude to ("" & strLatitudeInt & "." & strLatitudeDecimal & "")
	
	set theLongitude to (ocidLongitude as text)
	set AppleScript's text item delimiters to "."
	set listLongitude to every text item of theLongitude as list
	set AppleScript's text item delimiters to ""
	set strLongitudeInt to text item 1 of listLongitude as text
	set strLongitudeDecimal to text item 2 of listLongitude as text
	set strLongitudeDecimal to (text 1 through 7 of (strLongitudeDecimal & "000000000")) as text
	set theLongitude to ("" & strLongitudeInt & "." & strLongitudeDecimal & "")
	
	set theGooglemapParts to ("@" & theLatitude & "," & theLongitude & "," & (z of ocidRecordQuery as text) & "z")
	
	set theChl to ("https://www.google.com/maps/" & theGooglemapParts & "") as text
else
	set theChl to ("http://maps.apple.com/?q=" & (ocidLatitude as text) & "," & (ocidLongitude as text) & "," & (z of ocidRecordQuery as text) & "z") as text
end if
#####################################################
#####QRコード保存要ファイル名
if (q of ocidRecordQuery as text) is not "" then
	###検索語句あり
	if (count of (ocidSearchQueryEnc as text)) < 8 then
		set strQueryEnc to (ocidSearchQueryEnc as text) as text
	else
		set strQueryEnc to characters 1 thru 8 of (ocidSearchQueryEnc as text) as text
	end if
	set strFileName to ("" & strQueryEnc & ".png")
	refMe's NSLog("■:osascript: ocidSearchQueryEnc " & (ocidSearchQueryEnc as text) & "")
	
else if (daddr of ocidRecordQuery as text) is not "" then
	###行き先語句あり
	set strDaddrEnc to characters 1 thru 8 of (ocidDaddrEnc as text) as text
	set strFileName to ("" & strDaddrEnc & ".png")
	refMe's NSLog("■:osascript: ocidDaddrEnc " & (ocidDaddrEnc as text) & "")
else
	###語句の無い場合は日付をファイル名にする
	set strDateFormat to "yyyy年MMMMdd日hh時mm分" as text
	set ocidForMatter to refMe's NSDateFormatter's alloc()'s init()
	ocidForMatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidForMatter's setDateFormat:(strDateFormat)
	set objDate to (current date)
	set strDateTime to (ocidForMatter's stringFromDate:(objDate)) as text
	set strFileName to ("" & strDateTime & ".png")
end if
####################################
###ファイル名の接頭語
if objResponse is "GeoQR" then
	### 緯度経度でGEOバーコード　対応機種に制限がある場合あり
	set strFileName to ("GeoQR." & strFileName) as text
	###経路情報　Map
else if objResponse is "AppleMap経路" then
	set strFileName to ("A経路." & strFileName) as text
	###経路情報　Google
else if objResponse is "GoogleMap経路" then
	set strFileName to ("G経路." & strFileName) as text
	####AppleMapのガイドリンク
else if objResponse is "AppleMapガイド用" then
	set strFileName to ("Guide." & strFileName) as text
else if objResponse is "GoogleMap用" then
	set strFileName to ("Google." & strFileName) as text
else
	set strFileName to ("Google." & strFileName) as text
end if
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName)

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

##############################################
set strInputText to theChl as text
####テキストをNSStringに
set ocidInputString to refMe's NSString's stringWithString:strInputText
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
set numScaleMax to 720
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
###左右に３セル分づつ余白 quiet zoneを足す
####まずは元のQRコードのサイズに６セルサイズ分足したサイズの画像を作って
set ocidNSBitmapImagePadRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:numPadWidth pixelsHigh:numPadHight bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(refMe's NSCalibratedRGBColorSpace) bitmapFormat:(refMe's NSAlphaFirstBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###初期化
refMe's NSGraphicsContext's saveGraphicsState()
###ビットマップイメージ
(refMe's NSGraphicsContext's setCurrentContext:(refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:ocidNSBitmapImagePadRep))
###塗り色を『白』に指定して
refMe's NSColor's whiteColor()'s |set|()
##画像にする
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



return true

########################
### リンクコピー　ForMaps
########################
to doCopyMap()
	
	tell application "System Events"
		launch
	end tell
	tell application "Maps"
		activate
	end tell
	tell application "Maps"
		tell application "System Events"
			tell process "Maps"
				key code 53
			end tell
		end tell
	end tell
	try
		tell application "System Events"
			tell process "Maps"
				##	get every menu bar
				tell menu bar 1
					##	get every menu bar item
					tell menu bar item "編集"
						##	get every menu bar item
						tell menu "編集"
							##	get every menu item
							tell menu item "リンクをコピー"
								click
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
	on error
		try
			tell application id "com.apple.Maps"
				activate
				tell application "System Events"
					tell process "Maps"
						activate
						click menu item "リンクをコピー" of menu 1 of menu bar item "編集" of menu bar 1
					end tell
				end tell
			end tell
		end try
	end try
end doCopyMap