#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


tell application "Jedit Ω"
	tell front document
		set strSelextedText to selected text as text
	end tell
end tell

set strDeEncodedText to unicodeDecodeData(strSelextedText) as text

tell application "Jedit Ω"
	tell front document
		set selected text to strDeEncodedText
	end tell
end tell


on unicodeDecodeData(argInputText)
	set strInputText to argInputText as text
	set ocidInputStr to refMe's NSMutableString's stringWithString:(argInputText)
	### \\U30a4 形式の場合
	if strInputText contains "\\\\U" then
		set ocidDataStr to ocidInputStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set ocidDataStr to ocidDecodeStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set strDecodeText to ocidDecodeStr as text
		### \U30a4 形式の場合
	else if strInputText contains "\\U" then
		set ocidDataStr to ocidInputStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set strDecodeText to ocidDecodeStr as text
	else
		log "何もしないで戻す"
		set strDecodeText to strInputText as text
	end if
	return strDecodeText
end unicodeDecodeData
