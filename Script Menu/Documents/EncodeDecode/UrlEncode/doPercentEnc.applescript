#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

################################
##デフォルトクリップボードからテキスト取得
################################
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidTypeArray to appPasteboard's types()
set boolContain to ocidTypeArray's containsObject:("public.utf8-plain-text")
if boolContain = true then
	try
		set ocidPasteboardArray to appPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set ocidPasteboardStrings to ocidPasteboardArray's firstObject()
	on error
		set ocidStringData to appPasteboard's stringForType:("public.utf8-plain-text")
		set ocidPasteboardStrings to (refMe's NSString's stringWithString:(ocidStringData))
	end try
else
	set ocidPasteboardStrings to (refMe's NSString's stringWithString:(""))
end if
set strDefaultAnswer to ocidPasteboardStrings as text

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
	set strMes to ("読める文字を％エンコードしますnテキストやURL等を入力してください") as text
	
	set recordResponse to (display dialog strMes with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
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

##############################
###URLと通常テキストの処理を分岐する
##URLの場合
if strResponse starts with "http" then
	###タブと改行を除去しておく
	set ocidResponseText to refMe's NSString's stringWithString:(strResponse)
	set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
	ocidTextM's appendString:(ocidResponseText)
	##改行除去
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("n") withString:("")
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("r") withString:("")
	##タブ除去
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("t") withString:("")
	set strURL to ocidTextM as text
	set strURL to doUrlDecode(strURL)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(strURL)
	set ocidArgTextArray to ocidArgText's componentsSeparatedByString:("?")
	set numCntArray to (count of ocidArgTextArray) as integer
	if numCntArray > 1 then
		set ocidBaseURLstr to ocidArgTextArray's firstObject()
		ocidArgTextArray's removeObjectAtIndex:(0)
		set ocidQueryStr to ocidArgTextArray's componentsJoinedByString:("?")
		log ocidQueryStr as text
		set ocidArgTextArray to ocidQueryStr's componentsSeparatedByString:("=")
		set numCntArray to (count of ocidArgTextArray) as integer
		if numCntArray > 1 then
			log ocidArgTextArray as list
			set strNewQuery to ((ocidArgTextArray's firstObject() as text) & "=") as text
			repeat with itemIntNo from 1 to (numCntArray - 2) by 1
				set ocidItem to (ocidArgTextArray's objectAtIndex:(itemIntNo))
				log ocidItem as text
				set ocidItemArray to (ocidItem's componentsSeparatedByString:("&"))
				set numCntArray to (count of ocidItemArray) as integer
				if numCntArray > 1 then
					set ocidNextQue to ocidItemArray's lastObject()
					(ocidItemArray's removeLastObject())
					set ocidItemQueryStr to (ocidItemArray's componentsJoinedByString:("&"))
					set strEncValue to doUrlEncode(ocidItemQueryStr as text)
					set ocidEncValue to (refMe's NSString's stringWithString:(strEncValue))
					set ocidEncValue to (ocidEncValue's stringByReplacingOccurrencesOfString:("&") withString:("%26"))
					set strNewQuery to strNewQuery & ((ocidEncValue as text) & "&" & (ocidNextQue as text) & "=") as text
				else
					set strNewQuery to strNewQuery & ((ocidItemArray's firstObject() as text) & "&" & (ocidItemArray's lastObject() as text) & "=") as text
				end if
			end repeat
			set strNewQuery to (strNewQuery & (ocidArgTextArray's lastObject() as text)) as text
			log strNewQuery
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
else
	##通常テキストの場合
	set strText to strResponse as text
	set strText to doUrlDecode(strText) as text
	set strEncText to doTextEncode(strText) as text
end if
log strEncText
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
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
set strMes to ("戻り値ですr" & strEncText) as text

set recordResult to (display dialog strMes with title "%エンコード結果" default answer strEncText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strEncText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strEncText as text
		end tell
	end try
end if






####################################
###### ％デコード
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
####################################
###### ％エンコード
####################################
on doTextEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## 置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|!|:"%21", |#|:"%23", |$|:"%24", |&|:"%26", |'|:"%27", |(|:"%28", |)|:"%29", |*|:"%2A", |+|:"%2B", |,|:"%2C", |:|:"%3A", |;|:"%3B", |=|:"%3D", |?|:"%3F", |@|:"%40", | |:"%20"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		set strItemKey to itemAllKey as text
		##キーの値を取り出して
		if strItemKey is "@" then
			##置換
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:("@") withString:("%40"))
		else
			set ocidMapValue to (ocidPercentMap's valueForKey:(strItemKey))
			##置換
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(strItemKey) withString:(ocidMapValue))
		end if
		
		##次の変換に備える
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##テキスト形式に確定
	set strTextToEncode to ocidEncodedText as text
	###値を戻す
	return strTextToEncode
end doTextEncode

