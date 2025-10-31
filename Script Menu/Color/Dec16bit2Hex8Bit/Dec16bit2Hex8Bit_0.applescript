#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(* 
16bitÇÃdecÇPÇOêiêîÇ 8bitÇÃhexÇPÇUêiêîÇ…ïœä∑ÇµÇ‹Ç∑
ÉJÉâÅ[ÉsÉbÉJÅ[Ç©ÇÁÇÃñﬂÇËílÇëzíË

JavaScriptÇÃÉèÉìÉâÉCÉiÅ[Ç≈èàóù

com.cocolog-nifty.quicktimer.icefloeÅ@*)
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
	
	#ÉRÉ}ÉìÉhêÆå`
	set strJsScript to ("function fnc_decToHex(dec) {let hex = dec.toString(16).toUpperCase();return hex.padStart(2, '0');}function fnc_dec2hex() {let dec_array =[" & strDec8BitR & ", " & strDec8BitG & ", " & strDec8BitB & "];let hex_string = dec_array.map(v => fnc_decToHex(v)).join('');return hex_string;} fnc_dec2hex();") as text
	#ÉRÉ}ÉìÉhé¿çs
	set strHexValue to (do shell script "/usr/bin/osascript -l JavaScript -e Ä"" & strJsScript & "Ä"") as text
	
	
	
	return strHexValue
end do16bitDec2Hex

