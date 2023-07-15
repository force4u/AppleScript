#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application




set strFilePath to "/System/Library/ScriptingAdditions/StandardAdditions.osax/Contents/Resources/StandardAdditions.sdef" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###エリアスにして
set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
###アプリケーションをスクリプトエディタで開く
tell application "Script Editor"
	open aliasFilePath
end tell