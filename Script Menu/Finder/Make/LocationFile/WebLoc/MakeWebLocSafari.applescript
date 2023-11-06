#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#########################
tell application "Safari"
	set strTITLE to "" as text
	set strURL to "" as text
	set numCntWindow to (count of every window) as integer
end tell
###Safariのウィンドウが無いならダイアログを出す
##本当は  ≤ としたいところだが…
if numCntWindow < 1 then
	##デフォルトクリップボードから
	set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
	try
		set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
	on error
		set ocidPasteboardStrings to "" as text
	end try
	set strDefaultAnswer to ocidPasteboardStrings as text
else
	tell application "Safari"
		####タイトル　と　URLを取得
		every document
		set numWindowID to id of front window
		tell window id numWindowID
			set objCurrentTab to current tab
			tell objCurrentTab
				set strURL to URL
				set strTITLE to name
			end tell
		end tell
	end tell
	if strURL is (missing value) then
		set strDefaultAnswer to "https://"  as text
	else
		set strDefaultAnswer to strURL as text
	end if
end if
################################
######ダイアログ
################################
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
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
try
	set recordResponse to (display dialog "WEBページのURLを入力してください\n例：\nhttps://news.yahoo.co.jp\nhttp://localhost:631\nhttps://www.google.com/search?q=今日" with title "URLを入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "キャンセルしました"
	return "キャンセルしました"
end if
#########################
###タブと改行を除去しておく
set ocidResponseText to refMe's NSString's stringWithString:(strResponse)
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
set strResponse to ocidTextM as text
if strResponse starts with "http" then
	###URLがすでにエンコードされているか？の確認
	set ocidChkURL to refMe's NSURL's alloc()'s initWithString:(ocidTextM)
else
	return "httpURL以外は処理しない"
end if
#########################
###
if ocidChkURL = (missing value) then
	##URL
	set strURL to doUrlDecode(strURL)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(strURL)
	set ocidArgTextArray to ocidArgText's componentsSeparatedByString:("?")
	set numCntArray to (count of ocidArgTextArray) as integer
	####クエリーがある場合
	if numCntArray > 1 then
		###最初のArrayitemがURL部
		set ocidBaseURLstr to ocidArgTextArray's firstObject()
		ocidArgTextArray's removeObjectAtIndex:(0)
		####最初の?以降がクエリーなので？でリスト化したので？を足してテキストに
		set ocidQueryStr to ocidArgTextArray's componentsJoinedByString:("?")
		log ocidQueryStr as text
		###【B】クエリーのnameとvalueの区切り文字でリスト化
		set ocidArgTextArray to ocidQueryStr's componentsSeparatedByString:("=")
		set numCntArray to (count of ocidArgTextArray) as integer
		###複数クエリーがある場合
		if numCntArray > 1 then
			log ocidArgTextArray as list
			###【格納】最初の項目はnameだけになるので格納しておく
			set strNewQuery to ((ocidArgTextArray's firstObject() as text) & "=") as text
			repeat with itemIntNo from 1 to (numCntArray - 2) by 1
				###【B】のリストを順番に処理
				set ocidItem to (ocidArgTextArray's objectAtIndex:(itemIntNo))
				log ocidItem as text
				####【C】&で区切ってリストに
				set ocidItemArray to (ocidItem's componentsSeparatedByString:("&"))
				set numCntArray to (count of ocidItemArray) as integer
				####複数ある場合＝クエリーのvalueに値として＆がある場合
				if numCntArray > 1 then
					###最後の値を格納しておく
					set ocidNextQue to ocidItemArray's lastObject()
					###最後の値を削除＝次のクエリーのNameだから
					(ocidItemArray's removeLastObject())
					####残った値がValueになるので【C】で＆でリストにしたので＆を足してテキストに戻す
					set ocidItemQueryStr to (ocidItemArray's componentsJoinedByString:("&"))
					###VALUE＝クエリーの値をURLエンコードする
					set strEncValue to doUrlEncode(ocidItemQueryStr as text)
					###エンコード済みの値をストリングスにして
					set ocidEncValue to (refMe's NSString's stringWithString:(strEncValue))
					###Valueの中にある＆を個別でエンコードしておく
					set ocidEncValue to (ocidEncValue's stringByReplacingOccurrencesOfString:("&") withString:("%26"))
					####【格納】出来上がった値をクエリー用に格納
					set strNewQuery to strNewQuery & ((ocidEncValue as text) & "&" & (ocidNextQue as text) & "=") as text
				else
					####クエリーが１つだけの場合
					####【格納】出来上がった値をクエリー用に格納
					set strNewQuery to strNewQuery & ((ocidItemArray's firstObject() as text) & "&" & (ocidItemArray's lastObject() as text) & "=") as text
				end if
			end repeat
			####【格納】出来上がった値をクエリー用に格納
			set strNewQuery to (strNewQuery & (ocidArgTextArray's lastObject() as text)) as text
			####ベースになるURLにクエリーの値を戻してURLを再定義
			set strEncText to ((ocidBaseURLstr as text) & "?" & strNewQuery) as text
		end if
		##URLのクエリーにNameが無い場合
		set strEncText to ((ocidBaseURLstr as text) & "?" & (ocidQueryStr as text)) as text
		set strURL to doUrlDecode(strEncText)
		set strEncText to doUrlEncode(strURL)
	else
		##URLに？がない＝クエリーがない場合
		set ocidBaseURLstr to ocidArgTextArray's firstObject()
		set strURL to doUrlDecode(ocidBaseURLstr)
		set strEncText to doUrlEncode(strURL)
	end if
	
	set strURL to strEncText as text
else
	set strURL to ocidTextM as text
end if



#########################
set ocidURLString to refMe's NSString's alloc()'s initWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set strURL to ocidURL's absoluteString() as text

set ocidHostName to (ocidURL's |host|())

##保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirURL to ocidURLsArray's firstObject()
set ocidWebLocDirPathURL to ocidDocumentDirURL's URLByAppendingPathComponent:("Apple/Webloc/")
set ocidSaveDirPathURL to ocidWebLocDirPathURL's URLByAppendingPathComponent:(ocidHostName)
##フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set aliasSaveDirPathURL to (ocidSaveDirPathURL's absoluteURL()) as alias
#########################
###ファイル名
set strFileName to ocidHostName as text
set strDateno to doGetDateNo("yyyyMMdd")
set strSaveWeblocFileName to (strFileName & "." & strDateno & ".webloc") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveWeblocFileName)
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")
##これも自分用
if strTITLE is "" then
	log "何もしない"
else if strTITLE is (missing value) then
	log "何もしない"
else
	ocidPlistDict's setValue:(strTITLE) forKey:("name")
end if
#########################
####weblocファイルを作る
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)
(*
tell application "Finder"
	make new internet location file to strURL at aliasSaveDirPathURL with properties {name:"" & strTITLE & "", creator type:"MACS", stationery:false, location:strURL}
end tell
*)
#########################
set strSaveUrlFileName to (strFileName & "." & strDateno & ".url") as text
####URLファイルを作る
set strShortCutFileString to ("[InternetShortcut]\r\nURL=" & strURL & "\r\n") as text
set ocidUrlFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveUrlFileName)

set ocidShortCutFileString to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidShortCutFileString's setString:(strShortCutFileString)

##保存
set boolDone to ocidShortCutFileString's writeToURL:(ocidUrlFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

#########################

####保存先を開く
tell application "Finder"
	set aliasSaveFile to (file strSaveWeblocFileName of folder aliasSaveDirPathURL) as alias
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPathURL
	set selection to aliasSaveFile
end tell

#########################
####バージョンで使う日付
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
####################################
###### ％でコード
####################################

on doUrlDecode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##デコード
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end doUrlDecode


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
	##テキスト形式に確定
	set strTextToEncode to ocidArgTextEncoded as text
	###値を戻す
	return strTextToEncode
end doUrlEncode

(*

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
	set recordPercentMap to {|+|:"%2B", |&|:"%26", |$|:"%24"} as record
	set recordPercentMap to {|+|:"%2B", |$|:"%24"} as record
	##	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
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

*)