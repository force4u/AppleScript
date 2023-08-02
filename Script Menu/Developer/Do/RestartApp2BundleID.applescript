#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#バンドルIDのアプリケーションをリスタート
#起動していない場合は起動
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application


set strBundleID to "com.microsoft.VSCode" as text

log (doRestartApp2BundleID(strBundleID)) as text



################################
#### doRestartApp2BundleID
################################
to doRestartApp2BundleID(argBundleID)
	set strBundleID to argBundleID as text
	set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	if (count of ocidAppListArray) ≠ 0 then
		repeat with itemAppListArray in ocidAppListArray
			set booleDone to itemAppListArray's terminate()
		end repeat
	end if
	repeat 10 times
		delay 1
		set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
		if (count of ocidAppListArray) = 0 then
			###
			set ocidAppPathURL to doGetBundleID2AppURL(strBundleID)
			tell current application
				set strName to name as text
			end tell
			set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
			set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
			(ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true))
			if strName is "osascript" then
				set boolDone to (run script (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
			else
				set boolDone to (activate (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
			end if
			return "手動で起動"
		else
			exit repeat
		end if
	end repeat
	return "起動"
end doRestartApp2BundleID


###################################
### バンドルIDからアプリケーションURL
###################################
to doGetBundleID2AppURL(argBundleID)
	set strBundleID to argBundleID as text
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのURLを取得
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
				set strAppPath to (POSIX path of aliasAppApth) as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetBundleID2AppURL
