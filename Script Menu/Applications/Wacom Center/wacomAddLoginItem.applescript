#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

####アプリケーションフォルダ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidApplicationDirPathURL to ocidURLsArray's firstObject()
####
set ocidTabletDriverURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Wacom Tablet.localized/.Tablet/TabletDriver.app")
set ocidWacomTabletDriverURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Wacom Tablet.localized/.Tablet/WacomTabletDriver.app")
set ocidWacomTouchDriverURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Wacom Tablet.localized/.Tablet/WacomTouchDriver.app")
###
try
	set strTabletDriverURL to (ocidTabletDriverURL's |path|()) as text
	set strWacomTabletDriverURL to (ocidWacomTabletDriverURL's |path|()) as text
	set strWacomTouchDriverURL to (ocidWacomTouchDriverURL's |path|()) as text
on error
	return "WACOMのドライバーが正しくインストールされていません"
end try

tell application "System Events"
	make login item at end with properties {name:"TabletDriver.app", path:strTabletDriverURL, class:login item, kind:"アプリケーション", hidden:true}
end tell

tell application "System Events"
	make login item at end with properties {name:"WacomTabletDriver.app", path:strWacomTabletDriverURL, class:login item, kind:"アプリケーション", hidden:true}
end tell


tell application "System Events"
	make login item at end with properties {name:"WacomTouchDriver.app", path: strWacomTouchDriverURL, class:login item, kind:"アプリケーション", hidden:true}
end tell

