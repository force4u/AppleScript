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

set StrCommandText to "Ä"" & theBinPath & "Ä" --paired"
set strResponcet to (do shell script StrCommandText) as text

set AppleScript's text item delimiters to "Är"
set tmpResponcet to every text item of strResponcet
set AppleScript's text item delimiters to ""

if tmpResponcet is {} then
	return "ÉyÉAÉäÉìÉOçœÇ›ÉfÉoÉCÉXÇ™Ç†ÇËÇ‹ÇπÇÒ"
end if

try
	set objResponse to (choose from list tmpResponcet with title "íZÇﬂ" with prompt "í∑Çﬂ" default items (item 1 of tmpResponcet) OK button name "OK" cancel button name "ÉLÉÉÉìÉZÉã" with multiple selections allowed without empty selection allowed)
on error
	log "ÉGÉâÅ[ÇµÇ‹ÇµÇΩ"
	return "ÉGÉâÅ[ÇµÇ‹ÇµÇΩ"
end try
if objResponse is false then
	return
end if

set theResponse to (objResponse) as text
set AppleScript's text item delimiters to ","
set listDevice to every text item of theResponse
set AppleScript's text item delimiters to ""
set strID to text item 1 of listDevice
set strID to doReplace(strID, "address:", "")
set strID to doReplace(strID, " ", "")



try
	set theComandText to ("Ä"" & theBinPath & "Ä" --unpair Ä"" & strID & "Ä"") as text
	do shell script theComandText
on error
	log "unpairÉGÉâÅ["
end try







to doReplace(theText, orgStr, newStr)
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to orgStr
	set tmpList to every text item of theText
	set AppleScript's text item delimiters to newStr
	set tmpStr to tmpList as text
	set AppleScript's text item delimiters to oldDelim
	return tmpStr
end doReplace
