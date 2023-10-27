#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application




###スクリプトパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidScriptsDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Scripts/Color")
###フォルダを作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidScriptsDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)


set aliasScriptsFolder to (ocidScriptsDirPathURL's absoluteURL()) as alias

set listBundleID to {"com.apple.ColorSyncUtility", "com.apple.DigitalColorMeter", "com.apple.ColorSyncCalibrator"} as list

tell application "Finder"
	set boolFolderChk to (exists of (folder "ColorSync" of folder aliasScriptsFolder)) as boolean
	if (boolFolderChk is false) then
		make new folder at aliasScriptsFolder with properties {name:"ColorSync"}
	end if
	set aliasColorFolder to folder "ColorSync" of folder aliasScriptsFolder as «class furl»
end tell
set aliasOrigFilePath to (POSIX file "/System/Applications/Utilities/ColorSync Utility.app") as alias

tell application "Finder"
	set boolFolderChk to (exists of (file "ColorSyncユーティリティ.app" of folder "ColorSync" of folder aliasScriptsFolder)) as boolean
	if (boolFolderChk is false) then
		make alias at aliasColorFolder to aliasOrigFilePath
	end if
end tell

set aliasOrigFilePath to (POSIX file "/System/Library/ColorSync/Calibrators/Display Calibrator.app") as alias

tell application "Finder"
	set boolFolderChk to (exists of (file "ディスプレイキャリブレータ.app" of folder "ColorSync" of folder aliasScriptsFolder)) as boolean
	if (boolFolderChk is false) then
		make alias at aliasColorFolder to aliasOrigFilePath
	end if
end tell


set aliasOrigFilePath to (POSIX file "/System/Applications/Utilities/Digital Color Meter.app") as alias

tell application "Finder"
	set boolFolderChk to (exists of (file "Digital Color Meter.app" of folder "ColorSync" of folder aliasScriptsFolder)) as boolean
	if (boolFolderChk is false) then
		make alias at aliasColorFolder to aliasOrigFilePath
	end if
end tell
