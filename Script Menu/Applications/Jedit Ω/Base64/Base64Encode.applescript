#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


tell application "Jedit Ω"
	tell front document
		set TheTextToDecode to selected text
		set theResult to my decodeBase64(TheTextToDecode)
		set selected text to theResult
	end tell
end tell

on decodeBase64(argText)
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	set ocidArgData to ocidArgText's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
	(*
NSDataBase64Encoding64CharacterLineLength
NSDataBase64Encoding76CharacterLineLength
NSDataBase64EncodingEndLineWithCarriageReturn
NSDataBase64EncodingEndLineWithLineFeed
*)
	set ocidBase64EncodedString to ocidArgData's base64EncodedStringWithOptions:(refMe's NSDataBase64Encoding64CharacterLineLength)
	set strdBase64EncodedString to ocidBase64EncodedString as text
	return strdBase64EncodedString
end decodeBase64
