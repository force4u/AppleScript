#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

set strDirPath to "~/Library/ColorSync/Profiles/"
set ocidDirPathStr to refMe's NSString's stringWithString:(strDirPath)
set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath) isDirectory:true)



set aliasOpenDirPath to (ocidDirPathURL's absoluteURL()) as alias

tell application "Finder"
	open folder aliasOpenDirPath
end tell