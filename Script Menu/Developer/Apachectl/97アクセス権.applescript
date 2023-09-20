#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##©•ªŠÂ‹«‚ªos12‚È‚Ì‚Å2.8‚É‚µ‚Ä‚¢‚é‚¾‚¯‚Å‚·
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####ƒ[ƒJƒ‹ƒTƒCƒg
set strCommandText to "/usr/bin/sudo /bin/chmod 777 €"/Library/WebServer/Documents€""
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp www €"/Library/WebServer/Documents€""
do shell script strCommandText with administrator privileges

####‹¤—LƒTƒCƒgƒtƒHƒ‹ƒ_ì¬
set strCommandText to "/usr/bin/sudo /bin/mkdir -p /Users/Shared/Sites"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod -Rf 755 /Users/Shared/Sites"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www /Users/Shared/Sites"
do shell script strCommandText with administrator privileges


########ƒ[ƒJƒ‹ƒ†[ƒU[–¼æ“¾
set strCommandText to "/usr/bin/dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'"
set strLocalUser to do shell script strCommandText
set AppleScript's text item delimiters to "€r"
set listLocalUser to every text item of strLocalUser
set AppleScript's text item delimiters to ""
########ƒ†[ƒU[ƒTƒCƒgƒtƒHƒ‹ƒ_ì¬
repeat with itemLocalUser in listLocalUser
	set strLocalUser to itemLocalUser as text
	set strCommandText to "/usr/bin/sudo /bin/mkdir -p €"/Users/" & strLocalUser & "/Sites€""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/bin/touch €"/Users/" & strLocalUser & "/Sites/.localized€""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/sbin/chown -Rf " & strLocalUser & " €"/Users/" & strLocalUser & "/Sites€""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www €"/Users/" & strLocalUser & "/Sites€""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /bin/chmod 755 €"/Users/" & strLocalUser & "/Sites€""
	do shell script strCommandText with administrator privileges
	
end repeat



