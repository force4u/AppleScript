#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to ("com.microsoft.edgemac") as text

###インストール先
tell application "Finder"
	set aliasAppPath to (application file id strBundleID) as alias
end tell
set strAppPath to (POSIX path of aliasAppPath) as text

####用語解説を開く
tell application "Finder"
	set aliasResourcePath to (path to resource "scripting.sdef" in bundle aliasAppPath) as alias
end tell


tell application "Script Editor"
	activate
	open aliasResourcePath
end tell
