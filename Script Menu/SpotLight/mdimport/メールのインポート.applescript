#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()

#########
set ocidMailDirPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Group Containers/UBF8T346G9.Office/Outlook") isDirectory:true
#########
set coidDirPath to ocidMailDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(coidDirPath) isDirectory:(true)
set strDirPath to coidDirPath as text
if boolExists is true then
	set theCommandText to ("/usr/bin/mdimport -i \"" & strDirPath & "\"") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script theCommandText in objWindowID
		delay 1
		do script "\n\n" in objWindowID
		delay 2
		do script "exit" in objWindowID
		delay 2
		close front window saving no
	end tell
	delay 1
end if
#########
set ocidMailDirPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Mail") isDirectory:true
#########
set coidDirPath to ocidMailDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(coidDirPath) isDirectory:(true)
set strDirPath to coidDirPath as text
if boolExists is true then
	set theCommandText to ("/usr/bin/mdimport -i \"" & strDirPath & "\"") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script theCommandText in objWindowID
		delay 1
		do script "\n\n" in objWindowID
		delay 2
		do script "exit" in objWindowID
		delay 2
		close front window saving no
	end tell
	delay 1
end if
#########
set ocidMailDirPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Application Support/Thunderbird/Profiles") isDirectory:true
#########
set coidDirPath to ocidMailDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(coidDirPath) isDirectory:(true)
set strDirPath to coidDirPath as text
if boolExists is true then
	set theCommandText to ("/usr/bin/mdimport -i \"" & strDirPath & "\"") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script theCommandText in objWindowID
		delay 1
		do script "\n\n" in objWindowID
		delay 2
		do script "exit" in objWindowID
		delay 2
		close front window saving no
	end tell
	delay 1
end if
#########
set ocidMailDirPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Thunderbird/Profiles") isDirectory:true
#########
set coidDirPath to ocidMailDirPathURL's |path|()
set boolExists to appFileManager's fileExistsAtPath:(coidDirPath) isDirectory:(true)
set strDirPath to coidDirPath as text
if boolExists is true then
	set theCommandText to ("/usr/bin/mdimport -i \"" & strDirPath & "\"") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script theCommandText in objWindowID
		delay 1
		do script "\n\n" in objWindowID
		delay 2
		do script "exit" in objWindowID
		delay 2
		close front window saving no
	end tell
	delay 1
end if
#########
return "処理終了"
