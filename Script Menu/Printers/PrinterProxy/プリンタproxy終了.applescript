#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


###NSRunningApplication
set ocidRunningApplication to refMe's NSRunningApplication
###起動中のすべてのリスト
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.print.PrinterProxy"))
###複数起動時も順番に終了
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
