#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

property strBundleID : "com.apple.ScriptEditor2" as text


set strInsertScript to "set strDateNo to doGetDateNo(\"yyyyMMdd\") as text\rset intDateNo to doGetDateNo(\"yyyyMMdd\") as integer\r\rto doGetDateNo(argFormatStrings)\r\t####日付情報の取得\r\tset ocidDate to refMe's NSDate's |date|()\r\t###日付のフォーマットを定義\r\tset ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()\r\tocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:\"ja_JP_POSIX\")\r\tocidNSDateFormatter's setDateFormat:(argFormatStrings)\r\tset ocidDateAndTime to ocidNSDateFormatter's stringFromDate:(ocidDate)\r\tset strDateAndTime to ocidDateAndTime as text\r\treturn strDateAndTime\rend doGetDateNo" as text

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
