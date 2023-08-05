#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions



###オフセット値
set numXOffSet to 36 as integer
set numYOffSet to 58 as integer
###最初のウィンドウの位置
set listBounds to {0, 25, 620, 360} as list

###ウィンドウIDをリストで取得
tell application "Terminal"
	set listWindowID to id of every window
end tell
###ウィンドウの数だけ繰返し
repeat with itemWindowID in listWindowID
	###ウィンドウIDを取得数値で確定
	set strWindowID to itemWindowID as integer
	tell application "Terminal"
		tell window id strWindowID
			###位置をセットして
			set bounds to listBounds
			###前面に出す
			set frontmost to true
		end tell
	end tell
	###ウィンドウの位置を次のウィンドウ用に加算
	###値を取って
	set numFirst to (first item of listBounds) as integer
	set numSecond to (second item of listBounds) as integer
	set numThird to (third item of listBounds) as integer
	set numFourth to (fourth item of listBounds) as integer
	###加算して
	set numFirst to numFirst + numXOffSet as integer
	set numSecond to numSecond + numYOffSet as integer
	set numThird to numThird + numYOffSet as integer
	set numFourth to numFourth + numYOffSet as integer
	###リストに戻す
	set (first item of listBounds) to numFirst as integer
	set (second item of listBounds) to numSecond as integer
	set (third item of listBounds) to numThird as integer
	set (fourth item of listBounds) to numFourth as integer
	
end repeat
