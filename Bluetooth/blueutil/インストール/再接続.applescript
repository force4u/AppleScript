#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

try
	tell application "Finder"
		set aliasPathToMe to path to me as alias
		set thePathToMe to (POSIX path of aliasPathToMe) as text
		set aliasPathToDir to (container of aliasPathToMe) as alias
		set aliasBinPathDir to (folder "bin" of folder aliasPathToDir) as alias
		set aliasBinPath to path to resource "blueutil" in bundle alias aliasBinPathDir
	end tell
	set theBinPath to POSIX path of aliasBinPath as text
on error
	set strFilePath to ("~/bin/blueutil/blueutil") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set theBinPath to ocidFilePath as text
end try

###PoweStatur 1on 0off
set theComandText to ("�"" & theBinPath & "�"  --paired") as text
set thePaiedDevices to (do shell script theComandText) as text
set AppleScript's text item delimiters to "�r"
set listPaiedDevices to every text item of thePaiedDevices
set AppleScript's text item delimiters to ""

if listPaiedDevices is {} then
	return "�y�A�����O�ς݃f�o�C�X������܂���"
end if


### OFF ��������ON
repeat with objDevices in listPaiedDevices
	set AppleScript's text item delimiters to ","
	set listDevicesInfo to every text item of objDevices
	set AppleScript's text item delimiters to ""
	set theDevicesAddInfo to text item 1 of listDevicesInfo
	set AppleScript's text item delimiters to "address: "
	set theDevicesAdd to text item 2 of theDevicesAddInfo
	set AppleScript's text item delimiters to ""
	try
		set theComandText to ("�"" & theBinPath & "�" --connect �"" & theDevicesAdd & "�"") as text
		do shell script theComandText
	on error
		log "connect�G���["
	end try
	try
		set theComandText to ("�"" & theBinPath & "�" --add-favourite �"" & theDevicesAdd & "�"") as text
		do shell script theComandText
	on error
		log "add-favourite�G���["
	end try
	
	
end repeat


