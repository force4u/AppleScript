#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##要　管理者権限
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set strCommandText to "/usr/bin/sudo /usr/bin/dscacheutil -flushcache"
do shell script strCommandText with administrator privileges


set strCommandText to "/usr/bin/sudo /usr/bin/killall -HUP mDNSResponderHelper"
do shell script strCommandText with administrator privileges


