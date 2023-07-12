#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDocumentPathURL to ocidUserDocumentPathArray's firstObject()
set ocidSaveDirPathURL to ocidUserDocumentPathURL's URLByAppendingPathComponent:("Wifi/情報") isDirectory:true
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(missing value) |error|:(reference)

########################
######route
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("route.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/sbin/route -n get default" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"route", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell

########################
######ndp
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("ndp.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/usr/sbin/ndp -a" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"ndp", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell



########################
######networksetup
set strCommandText to "/usr/sbin/networksetup  -listallnetworkservices"
set strResults to (do shell script strCommandText) as text
set listServiceName to {} as list
set AppleScript's text item delimiters to "\r"
set listResults to every text item of strResults
set AppleScript's text item delimiters to ""
repeat with numCnt from 2 to (count of listResults)
	set itemServiceName to item numCnt of listResults
	copy itemServiceName to end of listServiceName
end repeat
log itemServiceName

repeat with strServiceName in listServiceName
	set strCommandText to "/usr/sbin/networksetup  -getinfo \"" & strServiceName & "\"" as text
	set strResponse to (do shell script strCommandText) as text
	
	if strResponse contains "Wi-Fi" then
		set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:("networksetup.rtf") isDirectory:true)
		set strSaveFilePath to ocidSaveFilePathURL's |path| as text
		set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
		tell application "TextEdit"
			activate
			properties
			set objNewDoc to (make new document with properties {name:"networksetup", text:strResponse, path:strSaveFilePath})
			tell objNewDoc
				tell its text
					set its font to "Osaka-mono"
					set its size to 14
				end tell
			end tell
			save objNewDoc in aliasSaveFilePath
		end tell
	end if
end repeat


########################
######airport
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("airport-i.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"airport-I", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell
########################
######airport S
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("airport-s.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"airport-s", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	tell front window
		set bounds to {72, 72, 920, 360}
	end tell
	save objNewDoc in aliasSaveFilePath
end tell



return



