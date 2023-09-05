#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
(*
SF Symbolsのダウンロードはこちらから
https://developer.apple.com/sf-symbols/
SF Pro フォントファイルはこちらから
https://developer.apple.com/fonts/
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


repeat with itemIntNo from 1048576 to 1058000 by 1
	log "character id " & itemIntNo & ": " & (character id itemIntNo)
end repeat





