#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	com.adobe.Acrobat.Pro
#	com.adobe.Reader
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

#####################################
#####デバッガー　コンソール起動
#####################################

tell application id "com.adobe.Reader"
	launch
	activate
	do script "console.show();"
	do script "console.clear();"
end tell

return
