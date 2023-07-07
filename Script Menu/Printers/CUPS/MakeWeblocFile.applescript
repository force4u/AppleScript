#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


set strURL to "http://localhost:631" as text
set strTitle to "CUPSを開く" as text


###保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()

set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Scripts/Printers/CUPS") isDirectory:true
#保存先ディレクトリを作る 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###ファイル
set strFileName to (strTitle & ".webloc") as text
set ocidFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

###レコードにして
set recordURL to {|URL|:strURL, title:strTitle} as record
###ディクショナリにして
set ocidDictionary to refMe's NSDictionary's alloc()'s initWithDictionary:(recordURL)
###PLISTにして
set ocidPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidDictionary) format:(refMe's NSPropertyListXMLFormat_v1_0) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray
####保存
set boolDone to ocidPlistEditData's writeToURL:(ocidFilePathURL) options:0 |error|:(reference)
######################
##CUPS WebInterface有効化
######################
set strCommandText to ("/usr/sbin/cupsctl  WebInterface=true")
set ocidAppName to refMe's NSString's stringWithString:strCommandText
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidAppName})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
if (item 2 of listDoneReturn) is not (missing value) then
	try
		set theComand to ("/usr/sbin/cupsctl  WebInterface=true") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
end if

###Finderで開く　FinderのURL取得
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set strBundleID to "com.apple.finder" as text
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
##WEBLOCを開く
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
appShardWorkspace's openURLs:({ocidFilePathURL}) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
##保存先を示す
set boolSelectFileResults to appShardWorkspace's selectFile:(ocidFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())
if boolSelectFileResults = false then
	####エイリアスにして
	set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
	tell application "Finder"
		set refNewWindow to make new Finder window
		set target of refNewWindow to aliasFilePath
	end tell
	
end if
