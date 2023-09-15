#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


## set strBundleID to ("com.apple.FaceTime") as text
set strBundleID to ("com.apple.FaceTime") as text



###################################
#####�N��
tell application "System Events"
	set listBundleID to (bundle identifier of every process) as list
	set listProcess to (name of every process) as list
end tell
if listBundleID contains strBundleID then
	##�N�����Ă���Ȃ�
	###�E�B���h�E�̐��𐔂���
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	###�E�B���h�E�̐���3�ȉ��̏ꍇ
else
	tell application id strBundleID to launch
	tell application id strBundleID to activate
end if
return



############################
###�@com.apple.systemevents���
############################
set strBundleIDSystemEvent to ("com.apple.systemevents") as text
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleIDSystemEvent)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat

tell application "System Events" to quit
