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
### �ݒ�
############################
####���C���̃o���h��ID
set strBundleID to ("com.apple.printcenter") as text
###�w���p�[�̃o���h��ID
set listHelperBundleID to {"com.apple.printcenter", "com.apple.print.add"} as list
############################
###�@�{���� 
############################
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	###�I��
	tell application id strBundleID to quit
end if
delay 1
############################
###�@���]���r���΍�
############################
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
delay 1
############################
###�@�w���p�[�̔��]���r���΍�
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
tell application "System Events" to quit