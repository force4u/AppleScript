#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property objMe : a reference to current application
property objNSString : a reference to objMe's NSString


tell application "Jedit Ω"
	tell front document
		set theTextToEncode to selected text as text
	end tell
end tell
set theTextToEncode to unicodeDecode(theTextToEncode) as text
tell application "Jedit Ω"
	tell front document
		set selected text to theTextToEncode
	end tell
end tell


on unicodeDecode(input)
	set objDecode to objNSString's stringWithString:input
	set theDecodedURL to (objDecode's stringByApplyingTransform:"Hex-Any" |reverse|:true) as text
	return theDecodedURL as text
end unicodeDecode
