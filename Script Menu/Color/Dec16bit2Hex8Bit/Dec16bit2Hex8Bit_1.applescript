#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(* 
16bitのdec１０進数を 8bitのhex１６進数に変換します
カラーピッカーからの戻り値を想定

リストから選択

こちらを参考にしました
https://www.macscripter.net/t/rgb-color-values-to-hexadecimal/73746

com.cocolog-nifty.quicktimer.icefloe　*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

set listDec16bitRGB to (choose color)

return do16bitDec2Hex(listDec16bitRGB)

on do16bitDec2Hex(list16BitDec)
	set strHexValue to ("") as text
	set listHexNo to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"} as list
	repeat with item16BitDec in list16BitDec
		set num8BitDec to ((item16BitDec / 65535) * 255) as number
		set numPosMSB to ((num8BitDec div 16) + 1) as integer
		set numPosLSB to ((num8BitDec mod 16) + 1) as integer
		set strHexValue to (strHexValue & (item numPosMSB of listHexNo) & (item numPosLSB of listHexNo)) as text
	end repeat
	return strHexValue
end do16bitDec2Hex