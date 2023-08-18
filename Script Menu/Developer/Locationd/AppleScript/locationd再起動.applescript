#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####################################
##	locationd　再起動
####################################
##コマンド
set strCommandText to ("/usr/bin/sudo /usr/bin/killall -HUP locationd") as text
set strResponse to (do shell script strCommandText with administrator privileges) as text
log strResponse
