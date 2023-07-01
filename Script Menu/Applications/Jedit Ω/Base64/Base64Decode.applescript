#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
## com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


tell application "Jedit Ω"
	tell front document
		###選択中のテキストを
		set TheTextToDecode to selected text
		###デコードして
		set theResult to my decodeBase64(TheTextToDecode)
		###上書きで戻す
		set selected text to theResult
	end tell
end tell

on decodeBase64(argText)
	###テキストにして
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	###デコードして
	set ocidArgData to refMe's NSData's alloc()'s initWithBase64EncodedString:(ocidArgText) options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters)
	###UTF８にして
	set ocidDecodedString to refMe's NSString's alloc()'s initWithData:ocidArgData encoding:(refMe's NSUTF8StringEncoding)
	###テキストで戻す
	set strDecodedString to ocidDecodedString as text
	return strDecodedString
end decodeBase64
