#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##Ž©•ªŠÂ‹«‚ªos12‚È‚Ì‚Å2.8‚É‚µ‚Ä‚¢‚é‚¾‚¯‚Å‚·
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strCommandText to "/usr/bin/sudo /usr/sbin/apachectl restart"
do shell script strCommandText with administrator privileges


