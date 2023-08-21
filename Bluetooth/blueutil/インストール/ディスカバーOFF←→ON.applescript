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
set theComandText to ("€"" & theBinPath & "€" -d") as text
set numBlueStatus to (do shell script theComandText) as text

### OFF ‚¾‚Á‚½‚çON
if numBlueStatus is "0" then
	try
		set theComandText to ("€"" & theBinPath & "€" -d 1") as text
		do shell script theComandText
	end try
else
	### ON ‚¾‚Á‚½‚ç OFF
	try
		set theComandText to ("€"" & theBinPath & "€" -d 0") as text
		do shell script theComandText
	end try
end if



