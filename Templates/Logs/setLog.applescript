#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


set strCommandText to ("/bin/mkdir -p ~/Library/Logs/AppleScript")
do shell script strCommandText

set strCommandText to ("/bin/echo \"処理開始\" > ~/Library/Logs/AppleScript/com.some.log")
do shell script strCommandText
set strCommandText to ("/bin/echo \"処理1OK\" >> ~/Library/Logs/AppleScript/com.some.log")
do shell script strCommandText
set strCommandText to ("/bin/echo \"処理2OK\" >> ~/Library/Logs/AppleScript/com.some.log")
do shell script strCommandText


refMe's NSLog("■:osascript:Start Script XXXXXXXXX")
refMe's NSLog("■:osascript:End Script XXXXXXXXX")
