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

tell application id "com.adobe.Acrobat.Pro"
	#	activate
	do script ("app.execMenuItem(\"ShowRulers\");")
	do script ("app.execMenuItem(\"ShowGuides\");")
	do script ("app.execMenuItem(\"Wireframe\");")
	tell menu item "ShowHideSubMenu" of menu "View"
		has submenu
		every menu item
	end tell
end tell



