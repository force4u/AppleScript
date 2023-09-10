#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
locate.databaseを削除して再構築します
再構築中はfindコマンドがフル駆動しますので昼休み前とか
しばらく操作しないタイミングがいいでしょう
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

try
	set strCommandText to ("/usr/bin/sudo /bin/launchctl stop -w /System/Library/LaunchDaemons/com.apple.locate.plist") as text
	do shell script strCommandText with administrator privileges
end try
try
	set strCommandText to ("/usr/bin/sudo  /bin/rm -f /var/db/locate.database") as text
	do shell script strCommandText with administrator privileges
end try
try
	set strCommandText to ("/usr/bin/sudo /bin/launchctl start -w /System/Library/LaunchDaemons/com.apple.locate.plist") as text
	do shell script strCommandText with administrator privileges
end try
try
	set strCommandText to ("/usr/bin/sudo /usr/libexec/locate.updatedb") as text
	do shell script strCommandText with administrator privileges
	set strCommandText to ("/usr/bin/sudo /usr/bin/killall locationd") as text
	do shell script strCommandText with administrator privileges
end try

return "処理は終わりました。この後findが起動します"


