#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

property strBundleID : "com.apple.ScriptEditor2" as text







set strInsertScript to "set strFilePath to \"~/Library/Preferences/com.apple.dock.plist\" as text\rset ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)\rset ocidFilePath to ocidFilePathStr's stringByStandardizingPath()\rset ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)\rset strFilePath to ocidFilePathURL's |path| as text\rset strFilePath to ocidFilePathURL's absoluteString() as text\rset aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias\rset ocidExtensionName to ocidFilePathURL's pathExtension()\rset ocidFileName to ocidFilePathURL's lastPathComponent()\rset ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()\rset ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()\rset ocidNewFilePathURL to ocidContainerDirURL's URLByAppendingPathComponent:(\"NoName.txt\") isDirectory:false\rset ocidNewFilePathURL to ocidContainerDirURL's URLByAppendingPathExtension:(\"text\")" as text

tell application id strBundleID
	tell the front document
		set strSelectedContents to the contents of selection
	end tell
end tell

set strSelectedContents to strSelectedContents & "\r" & strInsertScript & "\r" & "" as text

tell application id strBundleID
	tell the front document
		set contents of selection to strSelectedContents
		set selection to {}
	end tell
end tell
