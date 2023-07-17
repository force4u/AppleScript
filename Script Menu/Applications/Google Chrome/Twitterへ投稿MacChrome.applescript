#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

tell application "Google Chrome"
	activate
	tell front window
		tell active tab
			set strCurrentTabUrl to URL as text
			set strCurrentTabTitle to title as text
		end tell
	end tell
end tell

###区切り文字を入れて改行
set strCurrentTabTitle to ("\n--\n" & strCurrentTabTitle) as text
###エンコードして
set strCurrentTabUrl to doUrlEncode(strCurrentTabUrl) as text
set strCurrentTabTitle to doUrlEncode(strCurrentTabTitle) as text
###送信用URLに整形して
set strBaseUrl to "https://twitter.com/intent/tweet?" as text
set strOpenUrl to ("" & strBaseUrl & "url=" & strCurrentTabUrl & "&text=" & strCurrentTabTitle & "") as text
###Chromeに渡す
tell application "Google Chrome"
	activate
	tell window 1
		set objNewTab to make new tab
		tell objNewTab to set URL to strOpenUrl
	end tell
end tell
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
