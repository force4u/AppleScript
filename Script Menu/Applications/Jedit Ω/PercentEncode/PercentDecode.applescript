#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#Jedit用のURLエンコード
#	選択テキストを変換
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


tell application "Jedit Ω"
	tell front document
		set TheTextToEncode to selected text as text
	end tell
end tell
set TheTextToEncode to urlEncode(TheTextToEncode) as text
tell application "Jedit Ω"
	tell front document
		set selected text to TheTextToEncode
	end tell
end tell


on urlEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##デコード
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end urlEncode
