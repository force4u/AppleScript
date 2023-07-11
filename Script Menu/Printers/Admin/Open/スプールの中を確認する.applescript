#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
/usr/sbin/lpmove 
/usr/sbin/lpinfo 
/usr/sbin/lpc 
/usr/sbin/lpadmin 
/usr/bin/lpstat 
/usr/bin/lprm 
/usr/bin/lpr 
/usr/bin/lpq 
/usr/bin/lpoptions 
/usr/bin/lp 
*)
# 要管理者権限
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions

property refMe : a reference to current application


set strFilePath to "/private/var/spool/cups"


try
	set theComandText to ("/usr/bin/sudo /bin/chmod 777 /private/var/spool/cups") as text
	do shell script theComandText with administrator privileges
on error
	return "スプールにアクセスできませんした"
end try


###設定先

set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
###開く
set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolSelectFileResults to ocidSharedWorkspace's selectFile:(ocidFilePath) inFileViewerRootedAtPath:(ocidFilePath)
if boolSelectFileResults = false then
	tell application "Finder"
		set refNewWindow to make new Finder window
		set target of refNewWindow to aliasFilePath
	end tell
	
end if
