#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
trackName: Linearity Curve Graphic Design
trackId: 1219074514
bundleId: com.linearity.vn
version: 5.0.2
artistId: 1219074513
artistName: Linearity GmbH
macappstores://itunes.apple.com/app/id1219074514
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.AppStore") as text
###オープンするURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("macappstore")
ocidURLComponents's setHost:("itunes.apple.com")
ocidURLComponents's setPath:("/app/id1219074514")
set ocidURL to (ocidURLComponents's |URL|())
set strURL to ocidURL's absoluteString() as text
log strURL
-->(*macappstore://showUpdatesPage*)
###起動
tell application id strBundleID to launch
###起動待ち　最大１０秒
repeat 10 times
	tell application id strBundleID to activate
	tell application id strBundleID
		set boolFrontMost to frontmost as boolean
	end tell
	if boolFrontMost = false then
		delay 0.5
	else
		exit repeat
	end if
end repeat
###URLを開く
tell application id strBundleID
	open location strURL
end tell


