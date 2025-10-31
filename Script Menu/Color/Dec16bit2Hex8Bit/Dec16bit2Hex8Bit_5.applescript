#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(* 
16bitのdec１０進数を 8bitのhex１６進数に変換します
カラーピッカーからの戻り値を想定

swift ワンライナーを利用　初回コンパイルに時間がかかるので
あまりいい方法とはいえない

com.cocolog-nifty.quicktimer.icefloe　*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions



set listDec16bitRGB to (choose color)

return do16bitDec2Hex(listDec16bitRGB)


on do16bitDec2Hex(list16BitDec)
	
	set strDec16BitR to (1st item of list16BitDec) as text
	set strDec16BitG to (2nd item of list16BitDec) as text
	set strDec16BitB to (3rd item of list16BitDec) as text
	set strCommandText to ("/bin/echo  'import Foundation; let rgb=[" & strDec16BitR & "," & strDec16BitG & "," & strDec16BitB & "]; let hex=rgb.map{String(format:\\\"%02X\\\", Int(round(Double(\\$0)/257.0)))}.joined(); print(\\\"\\\\(hex)\\\")'") as text
	set strExec to ("/bin/zsh -c \"" & strCommandText & "\" | /usr/bin/swift -") as text
	set strHexValue to (do shell script strExec) as text
	
	return strHexValue
end do16bitDec2Hex