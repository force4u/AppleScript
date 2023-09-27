#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

set strBundleID to "com.apple.wifi.diagnostics" as text


tell application "Finder"
	###UTIからアプリケーションのパスを取得
	set aliasAppBundlePath to application file id strBundleID
end tell
tell application "Finder"
	open aliasAppBundlePath
end tell

return

property refMe : a reference to current application
####UTIからアプリケーションのパスを求める
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is (missing value) then
	####この方法は予備
	set aliasAppPath to path to application strAppName as alias
	set strAppBundlePath to POSIX path of aliasAppPath as text
	set ocidAppBundlePath to (refMe's NSString's stringWithString:(strAppBundlePath))
	set ocidFilePath to ocidAppBundlePath's stringByStandardizingPath
	set ocidAppBundlePathURL to refNSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
else
	try
		set ocidAppBundlePathURL to ocidAppBundle's bundleURL()
	on error
		set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
		
		set ocidAppBundlePathURL to appNSWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
	end try
end if
set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
(ocidConfiguration's setActivates:(true as boolean))
(ocidConfiguration's setAddsToRecentItems:(true as boolean))
appNSWorkspace's openApplicationAtURL:(ocidAppBundlePathURL) configuration:(ocidConfiguration) completionHandler:(missing value)





