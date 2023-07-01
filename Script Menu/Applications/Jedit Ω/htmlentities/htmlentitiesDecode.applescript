#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###置換レコード
set recordEntityMap to {|&|:"&amp;", |<|:"&lt;", |>|:"&gt;", |"|:"&quot;", |'|:"&apos;", |=|:"&#x3D;", |+|:"&#x2B;"} as record
###ディクショナリにして
set ocidEntityMap to refMe's NSDictionary's alloc()'s initWithDictionary:recordEntityMap
###キーの一覧を取り出します
set ocidAllKeys to ocidEntityMap's allKeys()


tell application "Jedit Ω"
	tell front document
		set strSelectedText to selected text
	end tell
end tell

###選択中テキスト
set ocidSelectedText to refMe's NSString's stringWithString:strSelectedText
###可変テキストにして
set ocidTextToEncode to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidTextToEncode's setString:ocidSelectedText

###取り出したキー一覧を順番に処理
repeat with itemAllKey in ocidAllKeys
	##キーの値を取り出して
	set ocidMapValue to (ocidEntityMap's valueForKey:itemAllKey)
	##置換
	set ocidEncodedText to (ocidTextToEncode's stringByReplacingOccurrencesOfString:(ocidMapValue) withString:(itemAllKey))
	##次の変換に備える
	set ocidTextToEncode to ocidEncodedText
end repeat

set strEncodedText to ocidEncodedText as text

tell application "Jedit Ω"
	tell front document
		set selected text to strEncodedText
	end tell
end tell

