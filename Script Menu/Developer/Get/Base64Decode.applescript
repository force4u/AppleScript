#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

########################
## クリップボードの中身取り出し
########################
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "検索文字列を入力" as text
	end if
end if
##############################
#####ダイアログ
##############################
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
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ClippingText.icns") as alias
try
	
	set strMes to "base６４にエンコードします" as text
	
	set recordResult to (display dialog strMes with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
on error
	log "エラーしました"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else
	return "キャンセル"
end if


################################
## 本処理
################################
set strDecodeString to doBase64Decde(strReturnedText)

################################
## 
################################
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
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ClippingText.icns") as alias
try
	set strMes to "デコード済みテキストです" as text
	
	set recordResult to (display dialog strMes with title "bundle identifier" default answer strDecodeString buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
on error
	log "エラーしました"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
else
	return "キャンセル"
end if

####################################
###### base64　エンコード
####################################
on doBase64Enc(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##データにして
	set ocidTextData to ocidArgText's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
	##エンコードテキストにする
	set ocidOption to (refMe's NSDataBase64Encoding64CharacterLineLength)
	set ocidBase64String to ocidTextData's base64EncodedStringWithOptions:(ocidOption)
	##テキスト形式に確定
	set strBase64String to ocidBase64String as text
	###値を戻す
	return strBase64String
end doBase64Enc


####################################
###### base64　デコード
####################################
on doBase64Decde(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##データにして
	set ocidOption to (refMe's NSDataBase64DecodingIgnoreUnknownCharacters)
	set ocidTextData to refMe's NSData's alloc()'s initWithBase64EncodedString:(ocidArgText) options:(ocidOption)
	##デコード済みテキストにする
	set ocidDecodeString to refMe's NSString's alloc()'s initWithData:(ocidTextData) encoding:(refMe's NSUTF8StringEncoding)
	##テキスト形式に確定
	set strDecodeString to ocidDecodeString as text
	###値を戻す
	return strDecodeString
end doBase64Decde
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
	set recordPercentMap to {|!|:"%21", |#|:"%23", |$|:"%24", |&|:"%26", |'|:"%27", |(|:"%28", |)|:"%29", |*|:"%2A", |+|:"%2B", |,|:"%2C", |:|:"%3A", |;|:"%3B", |=|:"%3D", |?|:"%3F", |@|:"%40", | |:"%20", |/|:"%2F"} as record
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