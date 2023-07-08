#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


set strCommandText to ("/usr/bin/cancel -a -x")
set ocidAppName to refMe's NSString's stringWithString:strCommandText
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidAppName})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)

if (item 2 of listDoneReturn) is not (missing value) then
	try
		set theComand to ("/usr/bin/cancel -a -x") as text
		set theLog to (do shell script theComand) as text
		log theLog
	on error
		set appFileManager to refMe's NSFileManager's defaultManager()
		set ocidUserName to refMe's NSUserName()
		set strUserName to ocidUserName as text
		set theComand to ("/usr/bin/cancel -u " & strUserName & "") as text
		set theLog to (do shell script theComand) as text
		log theLog
	end try
end if

if (item 2 of listDoneReturn) is not (missing value) then
	set strMesText to ""
	set strErrorCode to (item 2 of listDoneReturn)'s code() as text
	set strErrorDomain to (item 2 of listDoneReturn)'s domain() as text
	set strErrorDescription to (item 2 of listDoneReturn)'s localizedDescription() as text
	set strErrorFailureReason to (item 2 of listDoneReturn)'s localizedFailureReason() as text
	log "エラーコード：" & strErrorCode
	log "エラードメイン：" & strErrorDomain
	log "Description:" & strErrorDescription
	log "FailureReason:" & strErrorFailureReason
	set strMesText to (strErrorCode & "\r" & strErrorDomain & "\r" & strErrorDescription & "\r" & strErrorFailureReason) as text
	
	display dialog "エラーレポート" with title "エラーレポート" default answer strMesText buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" giving up after 60 without hidden answer
	
end if



