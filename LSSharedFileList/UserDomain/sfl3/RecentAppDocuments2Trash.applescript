#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###################################
##スクリプトメニューから実行させない
###################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		set aliasPathToMe to path to me as alias
		tell application "Script Editor"
			open aliasPathToMe
		end tell
		return "中止しました"
	end tell
else
	tell current application
		activate
	end tell
end if
###################################
#####ファイル選択ダイアログ
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments") as text
set ocidRecentDocDirURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
##↑こちらのURLの場所のコンテンツの収集
set ocidOption to (refMe's NSDirectoryEnumerationSkipsHiddenFiles)
set ocidKeyArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidKeyArray's addObject:(refMe's NSURLPathKey)
set listResponse to appFileManager's contentsOfDirectoryAtURL:(ocidRecentDocDirURL) includingPropertiesForKeys:(ocidKeyArray) options:(ocidOption) |error|:(reference)
set ocidFilePathURLArray to (item 1 of listResponse)
##↑ここで収集したコンテンツをゴミ箱に入れる
repeat with itemArray in ocidFilePathURLArray
	##ゴミ箱に入れる
	set listDone to (appFileManager's trashItemAtURL:(itemArray) resultingItemURL:(itemArray) |error|:(reference))
end repeat
#######################################
###　リロード
#######################################
try
	do shell script "/usr/bin/killall sharedfilelistd"
on error
	set strAgentPath to "/System/Library/LaunchAgents/com.apple.coreservices.sharedfilelistd.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"") as text
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
end try