#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
itunes.apple.comのlookupについてはこちらを
https://quicktimer.cocolog-nifty.com/icefloe/2023/08/post-623246.html
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
####設定項目
set strAppID to ("id1436215702") as text


set strBundleID to ("com.apple.AppStore") as text
###オープンするURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("macappstore")
ocidURLComponents's setHost:("itunes.apple.com")
set strPath to ("/story/" & strAppID) as text
ocidURLComponents's setPath:(strPath)
set ocidURL to (ocidURLComponents's |URL|())
set strURL to ocidURL's absoluteString() as text
log strURL
-->(*macappstore://itunes.apple.com/story/id1436215702*)
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


