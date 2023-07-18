#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

log doDemi2Oct(493)
-->755

###################################
##	パーミッション１０進数 →８進数  　
##	Decimal to Octal
###################################
to doDemi2Oct(argDemiNo)
	set numDemiNo to argDemiNo as number
	set numDiv1 to (numDemiNo div 8) as number
	set numMod1 to (numDemiNo mod 8) as number
	set numDiv2 to (numDiv1 div 8) as number
	set numMod2 to (numDiv1 mod 8) as number
	set numDiv3 to (numDiv2 div 8) as number
	set numMod3 to (numDiv2 mod 8) as number
	set strOctNo to (numMod3 & numMod2 & numMod1) as text
	return strOctNo
	
end doDemi2Oct

