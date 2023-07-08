#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

property strBundleID : "com.apple.ScriptEditor2" as text




set strInsertScript to "to doReplace(argOrignalText, argSearchText, argReplaceText)\r\tset strDelim to AppleScript's text item delimiters\r\tset AppleScript's text item delimiters to argSearchText\r\tset listDelim to every text item of argOrignalText\r\tset AppleScript's text item delimiters to argReplaceText\r\tset strReturn to listDelim as text\r\tset AppleScript's text item delimiters to strDelim\r\treturn strReturn\rend doReplace" as text

tell application id strBundleID
	tell the front document
		set strSelectedContents to the contents of selection
	end tell
end tell

set strSelectedContents to strSelectedContents & "\r" & strInsertScript & "\r" & "" as text

tell application id strBundleID
	tell the front document
		set contents of selection to strSelectedContents
		set selection to {}
	end tell
end tell
