#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
############################
### 設定
############################
####メインのバンドルID
##2023.2.0.61611以前
set strBundleID to ("com.foxit-software.Foxit PDF Reader") as text
##2023.2.0.61611以降
set strBundleID to ("com.foxit-software.Foxit.PDF.Reader") as text
##2023.2.0.61611以前
###ヘルパーのバンドルID
set listHelperBundleID to {"com.foxit-software.Foxit PDF Reader", "com.foxit-software.Foxit SendCrashReport", "sss.FoxitPDFReaderUpdateService", "com.foxit-software.Foxit PDF Reader Updater", "com.foxit-software.Foxit PDF Reader Activation"} as list
##2023.2.0.61611以降
###ヘルパーのバンドルID
set listHelperBundleID to {"com.foxit-software.Foxit.PDF.Reader", "com.foxit-software.Foxit.SendCrashReport", "sss.FoxitPDFReaderUpdateService", "com.foxit-software.Foxit.PDF.Reader.Updater", "com.foxit-software.Foxit.PDF.Reader.Activation"} as list

############################
###　本処理 
############################
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	###終了
	try
		tell application id strBundleID to quit
	end try
end if
delay 1
############################
###　半ゾンビ化対策
############################
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
delay 1
############################
###　ヘルパーの半ゾンビ化対策
############################
repeat with itemHelperBundleID in listHelperBundleID
	set strHelperBundleID to itemHelperBundleID as text
	#####
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strHelperBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
end repeat
