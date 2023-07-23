#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##要　管理者権限
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


set strCommandText to "/usr/bin/sudo /usr/sbin/arp -a -d" as text

set strResponse to (do shell script strCommandText with administrator privileges) as text

tell application "TextEdit"
	activate
	properties
	make new document with properties {name:"arp", text:strResponse}
end tell

tell application "TextEdit"
activate
	tell front document
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
end tell
