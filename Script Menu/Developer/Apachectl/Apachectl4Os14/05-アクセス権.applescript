#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####ローカルサイト
set strCommandText to "/usr/bin/sudo /bin/chmod 777 \"/Library/WebServer/Documents\""
do shell script strCommandText 
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp www \"/Library/WebServer/Documents\""
do shell script strCommandText 

####共有サイトフォルダ作成
set strCommandText to "/usr/bin/sudo /bin/mkdir -p /Users/Shared/Sites"
do shell script strCommandText 
set strCommandText to "/usr/bin/sudo /bin/chmod -Rf 755 /Users/Shared/Sites"
do shell script strCommandText 
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www /Users/Shared/Sites"
do shell script strCommandText 


########ローカルユーザー名取得
set strCommandText to "/usr/bin/dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'"
set strLocalUser to do shell script strCommandText
set AppleScript's text item delimiters to "\r"
set listLocalUser to every text item of strLocalUser
set AppleScript's text item delimiters to ""
########ユーザーサイトフォルダ作成
repeat with itemLocalUser in listLocalUser
	set strLocalUser to itemLocalUser as text
	set strCommandText to "/usr/bin/sudo /bin/mkdir -p \"/Users/" & strLocalUser & "/Sites\""
	do shell script strCommandText 
	set strCommandText to "/usr/bin/sudo /usr/bin/touch \"/Users/" & strLocalUser & "/Sites/.localized\""
	do shell script strCommandText 
	set strCommandText to "/usr/bin/sudo /usr/sbin/chown -Rf " & strLocalUser & " \"/Users/" & strLocalUser & "/Sites\""
	do shell script strCommandText 
	set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www \"/Users/" & strLocalUser & "/Sites\""
	do shell script strCommandText 
	set strCommandText to "/usr/bin/sudo /bin/chmod 755 \"/Users/" & strLocalUser & "/Sites\""
	do shell script strCommandText 
	
end repeat



