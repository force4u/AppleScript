#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###################################
#####パス
###################################
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
###どっちが正解なのか？わからない
set ocidCloudStorageDirURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:"CloudStorage"

###################################
#####開く
###################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidOpenURLsArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
(ocidOpenURLsArray's addObject:(ocidCloudStorageDirURL))
appSharedWorkspace's activateFileViewerSelectingURLs:(ocidOpenURLsArray)

return
###この方法でもちろんOK
set aliasFilePathURL to (ocidCloudStorageDirURL's absoluteURL()) as alias
set boolResults to (appShardWorkspace's openURL:ocidCloudStorageDirURL)
if boolResults is false then
	tell application "Finder"
		make new Finder window to aliasFilePathURL
	end tell
end if







