#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(* 
16bitのdec１０進数を 8bitのhex１６進数に変換します
カラーピッカーからの戻り値を想定
パールのワンライナーで処理

com.cocolog-nifty.quicktimer.icefloe　*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions


set listDec16bitRGB to (choose color)

return do16bitDec2Hex(listDec16bitRGB)


on do16bitDec2Hex(list16BitDec)
	set listDec8Bit to {} as list
	repeat with itemNo from 1 to 3 by 1
		set numDec16Bit to (item itemNo of list16BitDec) as integer
		set num8BitDec to ((numDec16Bit / 65535) * 255) as integer
		set end of listDec8Bit to num8BitDec
	end repeat
	set strDec8BitR to (1st item of listDec8Bit) as text
	set strDec8BitG to (2nd item of listDec8Bit) as text
	set strDec8BitB to (3rd item of listDec8Bit) as text
	set strHexValue to (do shell script "/usr/bin/perl -e 'printf \"%02X%02X%02X\", " & strDec8BitR & ", " & strDec8BitG & ", " & strDec8BitB & "'" without altering line endings) as text
	return strHexValue
end do16bitDec2Hex

