#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけで
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set strFilePath to "/private/etc/cups/ppd"
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:true

set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
appNSWorkspace's openURL:ocidFilePathURL
