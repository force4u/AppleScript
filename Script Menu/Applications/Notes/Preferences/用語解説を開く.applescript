#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

set strBundleID to ("com.apple.Notes") as text

###インストール先
tell application "Finder"
	set aliasAppPath to (application file id strBundleID) as alias
end tell
###
set strAppPath to (POSIX path of aliasAppPath) as text
set ocidAppPathStr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()
set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:true)
set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist")
###
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set strOSAScriptingDefinition to (ocidPlistDict's valueForKey:("OSAScriptingDefinition")) as text
if strOSAScriptingDefinition is "midding value" then
	return "用語解説が見つかりませんでした"
end if


####用語解説を開く
tell application "Finder"
	set aliasResourcePath to (path to resource strOSAScriptingDefinition in bundle aliasAppPath) as alias
end tell


tell application "Script Editor"
	activate
	open aliasResourcePath
end tell
