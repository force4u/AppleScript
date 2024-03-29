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
#####本処理
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/com.apple.LSSharedFileList.RecentHosts.sfl3") as text
set ocidFilePathURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false

# NSDataに読み込んで
set ocidReadData to refMe's NSData's dataWithContentsOfURL:(ocidFilePathURL)
# unarchivedObjectOfClassで解凍する
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidReadData) |error|:(reference)
set ocidPlistDict to (item 1 of listResponse)
if ocidPlistDict = (missing value) then
	return "解凍に失敗しました"
end if
#propertiesの値は
set ocidProperties to ocidPlistDict's objectForKey:("properties")
#引き継ぐ
set ocidSaveDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidSaveDict's setObject:(ocidProperties) forKey:("properties")
#itemsは空のArrayをセット＝リセット
set ocidItemsArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidSaveDict's setObject:(ocidItemsArray) forKey:("items")
#アーカイブする
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidSaveDict) requiringSecureCoding:(false) |error|:(reference)
set ocidSfl3Data to (item 1 of listResponse)
if ocidSfl3Data = (missing value) then
	return "アーカイブに失敗しました"
end if
#ファイル保存
set listDone to ocidSfl3Data's writeToURL:(ocidFilePathURL) options:0 |error|:(reference)
if (item 1 of listDone) is false then
	return "保存に失敗しました"
end if


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
#
do shell script "/usr/bin/killall Finder"