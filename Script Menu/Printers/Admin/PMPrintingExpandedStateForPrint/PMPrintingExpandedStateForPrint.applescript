#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##############################
###PMPrintingExpandedStateForPrint
set strCommandText to ("/usr/bin/defaults read NSGlobalDomain PMPrintingExpandedStateForPrint -boolean") as text
try
	set strCommandResponse to (do shell script strCommandText) as text
	if strCommandResponse is "0" then
		set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -boolean true") as text
		do shell script strCommandText
	end if
on error
	set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -boolean true") as text
	do shell script strCommandText
end try
##############################
###PMPrintingExpandedStateForPrint2
set strCommandText to ("/usr/bin/defaults read NSGlobalDomain PMPrintingExpandedStateForPrint2 -boolean") as text
try
	set strCommandResponse to (do shell script strCommandText) as text
	if strCommandResponse is "0" then
		set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -boolean true") as text
		do shell script strCommandText
	end if
on error
	set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -boolean true") as text
	do shell script strCommandText
end try

return "ここまで"
##############################
###PMPrintingExpandedStateForPrint3
set strCommandText to ("/usr/bin/defaults read NSGlobalDomain PMPrintingExpandedStateForPrint3 -boolean") as text
try
	set strCommandResponse to (do shell script strCommandText) as text
	if strCommandResponse is "0" then
		set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint3 -boolean true") as text
		do shell script strCommandText
	end if
on error
	set strCommandText to ("/usr/bin/defaults write NSGlobalDomain PMPrintingExpandedStateForPrint3 -boolean true") as text
	do shell script strCommandText
end try
