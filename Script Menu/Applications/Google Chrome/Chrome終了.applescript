#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set listUTI to {"com.google.Chrome", "com.google.Chrome.helper.renderer", "com.google.GoogleUpdater", "com.google.Chrome.helper", "com.google.Chrome.helper.plugin", "chrome_crashpad_handler"}

repeat with itemUTI in listUTI
	try
		log itemUTI
		tell application id itemUTI to quit
	end try
end repeat
delay 3
repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	log itemUTI
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat
