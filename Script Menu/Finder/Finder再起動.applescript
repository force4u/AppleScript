#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###設定項目
set strBundleID to "com.apple.finder" as text


###処理開始
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppList to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
###アプリケーションのURLを取得しておく
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppPathURL to appWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
end if
(*
NSRunningApplicationの戻り値にタイムラグがあるため
少し待つ処理を加えた
*)
repeat 5 times
	delay 1
	set ocidRunApp to refMe's NSRunningApplication
	set ocidAppList to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
	if (count of ocidAppList) = 0 then
		###Finderが無いなら起動
		set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
		ocidOpenConfig's setHides:(refMe's NSNumber's numberWithBool:false)
		ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
		ocidOpenConfig's setRequiresUniversalLinks:(refMe's NSNumber's numberWithBool:false)
		appWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
	else
		###あるなら起動確認終了
		delay 1
		set ocidAppList to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
		if (count of ocidAppList) = 0 then
			###Finderが無いなら起動
			set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
			set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
			ocidOpenConfig's setHides:(refMe's NSNumber's numberWithBool:false)
			ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
			ocidOpenConfig's setRequiresUniversalLinks:(refMe's NSNumber's numberWithBool:false)
			appWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
		end if
		exit repeat
	end if
	
end repeat
