#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


set strCommandText to "/usr/sbin/arp -a" as text

set strResponse to (do shell script strCommandText) as text

tell application "TextEdit"
	activate
	properties
	make new document with properties {name:"arp", text:strResponse}
end tell

tell application "TextEdit"
	tell front document
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
end tell
