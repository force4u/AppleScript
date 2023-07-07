#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	デフォルトのプリンタ名
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#	デフォルトのプリンタ名
#
set ocidPrintInfo to refMe's NSPrintInfo's sharedPrintInfo()
set ocidPrinter to ocidPrintInfo's printer()
log ocidPrinter's |name|() as text


#	デフォルトのプリンタドライバ名
#
set ocidPrintInfo to refMe's NSPrintInfo's sharedPrintInfo()
set ocidPrinter to ocidPrintInfo's printer()
log ocidPrinter's type() as text
