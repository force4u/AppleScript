#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##############################################
## Finderを再起動
##############################################

set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppList to ocidRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
	###２秒まって
	delay 2
	###起動させる
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
else if (count of ocidAppList) = 0 then
	###Finderが無いなら起動
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
end if
#############起動確認　１０回１０秒間
repeat 10 times
	set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
	if (count of ocidAppList) = 0 then
		###Finderが無いなら起動
		set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
		ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
	else
		###あるなら起動確認終了
		exit repeat
	end if
	delay 1
end repeat
