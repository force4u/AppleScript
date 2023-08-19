#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set listBundleID to {"com.microsoft.rdc.macos", "com.microsoft.rdc.macos.qlx"} as list

###まずは通常終了
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	try
		tell application id strBundleID to quit
	end try
end repeat
###通常終了
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	
end repeat

###強制終了
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate
	end repeat
	
end repeat
