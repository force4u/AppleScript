#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*
書き出し　アプリケーションで
起動時に隠す設定ができます
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##タッチドライバ用
set listUTI to {"com.wacom.WacomCenter", "com.wacom.wacomtablet", "com.wacom.IOManager", "com.wacom.WacomTouchDriver"} as list
##タブレットドライバ用
set listUTI to {"com.wacom.WacomCenter", "com.wacom.wacomtablet", "com.wacom.IOManager", "com.wacom.TabletDriver"} as list

repeat with itemUTI in listUTI
	tell application id itemUTI
		launch
	end tell
end repeat
###起動


###隠す処理
tell application "System Events"
	tell application process "Wacom Center"
		set visible to false
	end tell
end tell



