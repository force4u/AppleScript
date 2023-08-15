#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set strCommandText to ("/usr/bin/pmset sleepnow") as text
##	do shell script strCommandText

####
set ocidCommandText to refMe's NSString's stringWithString:(strCommandText)
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidCommandText})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)

return
