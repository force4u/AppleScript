#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

set strScreenName to "内蔵Retinaディスプレイ"

property refMe : a reference to current application
###ディスクプレイを取得
set ocidScreenArray to refMe's NSScreen's screens()
##複数ある場合はカウント２とかになります
set numCntScreen to (count of ocidScreenArray) as integer
###ウィンドウの数だけ繰返して
repeat with itemScreenArray in ocidScreenArray
	set strItemScreenName to itemScreenArray's localizedName() as text
	log strItemScreenName
	###指定のディスプレイのサイズを取得します
	if strItemScreenName is strScreenName then
		set ocidDescription to itemScreenArray's deviceDescription()
		set ocidDeviceSize to (ocidDescription's valueForKey:"NSDeviceSize")
		log ocidDeviceSize as list
		####サイズ取得
		set ocidScreenSize to itemScreenArray's frame()
	end if
end repeat
###モニタの縦横サイズ
set numScreenW to (item 1 of (item 2 of ocidScreenSize)) as integer
set numScreenH to (item 2 of (item 2 of ocidScreenSize)) as integer

###小さい方のサイズをとって正方形エリアを作る
if numScreenW ≥ numScreenH then
	set numSetW to numScreenH as integer
	##メニューバー分引く
	set numSetH to numScreenH - 25 as integer
else
	set numSetW to numScreenW as integer
	##メニューバー分引く
	set numSetH to numScreenW - 25 as integer
end if

###ウィンドウIDをリストで取得
tell application "Terminal"
	set listWindowID to id of every window
end tell
###ウィンドウの数
set numCntWindow to (count of listWindowID) as integer

###左右の分で２で割る
set numRaw to (round numCntWindow / 2 rounding up) as integer

###加算用の値
set numHarfSize to (numSetW / 2) as integer
set numWindowP to (numSetH / numRaw) as integer
###ウィンドウサイズの初期値
set listBoundsL to {0, 25, numHarfSize, numWindowP + 25} as list
set listBoundsR to {numHarfSize, 25, numSetW, numWindowP + 25} as list

##処理は左から
set boolLeft to true as boolean
###ウィンドウの数だけ繰返し
repeat with itemWindowID in listWindowID
	
	###ウィンドウIDを取得数値で確定
	set strWindowID to itemWindowID as integer
	tell application "Terminal"
		tell window id strWindowID
			if boolLeft is true then
				###位置をセットして
				set bounds to listBoundsL
			else
				set bounds to listBoundsR
			end if
			###前面に出す
			set frontmost to true
		end tell
	end tell
	
	####ウィンドウ位置の加算
	if boolLeft is true then
		###左の次は右へ
		set boolLeft to false as boolean
		###値を取って
		set numSecond to (second item of listBoundsL) as integer
		set numFourth to (fourth item of listBoundsL) as integer
		###加算して
		set numSecond to numSecond + numWindowP as integer
		set numFourth to numFourth + numWindowP as integer
		###リストに戻す
		set (second item of listBoundsL) to numSecond as integer
		set (fourth item of listBoundsL) to numFourth as integer
	else
		###右の次は左へ
		set boolLeft to true as boolean
		###値を取って
		set numSecond to (second item of listBoundsR) as integer
		set numFourth to (fourth item of listBoundsR) as integer
		###加算して
		set numSecond to numSecond + numWindowP as integer
		set numFourth to numFourth + numWindowP as integer
		###リストに戻す
		set (second item of listBoundsR) to numSecond as integer
		set (fourth item of listBoundsR) to numFourth as integer
	end if
end repeat
