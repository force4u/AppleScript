#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# dumpbtmの内容をテキストエディタに書き出します
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##### 
set strCommandText to "/usr/bin/sudo /usr/bin/sfltool dumpbtm"
set strResponse to (do shell script strCommandText with administrator privileges) as text

tell application "TextEdit"
	activate
	properties
	make new document with properties {name:"dumpbtm", text:strResponse}
end tell

tell application "TextEdit"
	tell front document
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
end tell
return
###
