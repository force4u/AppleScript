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
https://apps.apple.com/app/apple-store/id1219074514

https://developer.apple.com/library/archive/qa/qa1633/_index.html
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.finder") as text
set strCountry to ("jp") as text
###オープンするURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("https")
ocidURLComponents's setHost:("apps.apple.com")
##ocidURLComponents's setPath:("/" & strCountry & "/app/apple-store/id1219074514")
ocidURLComponents's setPath:("/" & strCountry & "/app/id1219074514")
###
set ocidQueryItemMT to refMe's NSURLQueryItem's alloc()'s initWithName:("mt") value:("12")
(*
1	Music
2	Podcasts
3	Audiobooks
4	TV Shows
5	Music Videos
6	Movies
7	iPod Games
8	Mobile Software Applications
9	Ringtones
10	iTunes U
11	E-Books
12	Desktop Apps
*)
##AppStoreを起動させない
set ocidQueryItemLS to refMe's NSURLQueryItem's alloc()'s initWithName:("ls") value:("0")
ocidURLComponents's setQueryItems:({ocidQueryItemMT, ocidQueryItemLS})
##ocidURLComponents's setQuery:("mt=12&ls=0")
##
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


