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
	
else if (daddr of ocidRecordQuery as text) is not "" then
	###行き先語句あり
	set strDaddrEnc to characters 1 thru 8 of (ocidDaddrEnc as text) as text
	set strFileName to ("" & strDaddrEnc & ".png")
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


#####################
###出来上がったMATMSGテキスト
log theChl
##MATMSGの内容テキストエンコード
set strChlEnc to doUrlEncode(theChl) as text
##BASE URL
set theApiUrl to "https://chart.googleapis.com/chart?" as text
##API名
set theCht to "qr" as text
##仕上がりサイズpx(72の倍数推奨)　72 144 288 360 576 720 1080
set theChs to "540x540" as text
## テキストのエンコード ガラ携対応するならSJISを選択
set theChoe to "UTF-8" as text
##誤差補正　L M Q R
set theChld to "M" as text
##URLを整形
set strURL to ("" & theApiUrl & "&cht=" & theCht & "&chs=" & theChs & "&choe=" & theChoe & "&chld=" & theChld & "&chl=" & strChlEnc & "") as text
log strURL

#####################
###　NSURL
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
#####################
###　データを読み込む
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidReadData to (item 1 of listReadData)
set ocidOption to (refMe's NSDataWritingAtomic)
###	保存
set boolDone to ocidReadData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set strFilePath to ocidSaveFilePathURL's absoluteString() as text

#####################
###サファリで開く
tell application "Safari"
	activate
	make new document with properties {name:"QR-CODE by Google API"}
	tell front window
		open location strFilePath
	end tell
end tell
###
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
