#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###パスURL
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSupportDirPathURL to ocidURLsArray's firstObject()
set ocidTemplatesDirPathURL to ocidAppSupportDirPathURL's URLByAppendingPathComponent:("Script Editor/Templates/")
###パスにして
set ocidTemplatesDirPath to ocidTemplatesDirPathURL's |path|()
###有無を調べる
set boolDirExists to appFileManager's fileExistsAtPath:(ocidTemplatesDirPath) isDirectory:(true)
if boolDirExists = true then
	log "指定フォルダはあります"
else if boolDirExists = false then
	log "指定フォルダを作ります"
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidTemplatesDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
end if
set aliasTemplatesDirPath to (ocidTemplatesDirPathURL's absoluteURL()) as alias



tell application "Finder"
	set aliasAppSupDir to path to application support folder from user domain
	open folder "Templates" of folder "Script Editor" of folder aliasAppSupDir
end tell

