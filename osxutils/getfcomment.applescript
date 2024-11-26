#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argFilePath)
	if (argFilePath as text) is "-h" then
		log doPrintHelp()
		return
	end if
	set strFilePath to argFilePath as text
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePathStr to (ocidFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set strFilePath to ocidFilePath as text
	set strCommandText to ("/usr/bin/xattr -px \"com.apple.metadata:kMDItemFinderComment\" \"" & strFilePath & "\" |  /usr/bin/xxd -r -p | /usr/bin/plutil -convert xml1 -o - -")
	set strCommandResponse to doExecTask(strCommandText) as text
	set ocidPlistString to current application's NSString's stringWithString:(strCommandResponse)
	set ocidPlistData to ocidPlistString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
	set listRespopnse to current application's NSPropertyListSerialization's propertyListWithData:(ocidPlistData) options:(current application's NSPropertyListImmutable) format:(missing value) |error|:(reference)
	set strCommentText to (item 1 of listRespopnse) as text
	if strCommentText is "" then
		set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
		tell application "Finder"
				set strCommentText to comment of aliasFilePath
		end tell
	end if
	return strCommentText
end run


on doPrintHelp()
	set strHelpText to ("
fileに設定されているFinderコメントを戻します

例:
getfcomment.applescript /some/file
getfcomment.applescript /some/file 入れたいコメント


") as text
	return strHelpText
end doPrintHelp


to doExecTask(argCommandText)
	set strExecCommandText to argCommandText as text
	set ocidComString to current application's NSString's stringWithString:(strExecCommandText)
	set ocidTermTask to current application's NSTask's alloc()'s init()
	ocidTermTask's setLaunchPath:("/bin/zsh")
	set ocidArgumentsArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidArgumentsArray's addObject:("-c")
	ocidArgumentsArray's addObject:(ocidComString)
	ocidTermTask's setArguments:(ocidArgumentsArray)
	set ocidOutPut to current application's NSPipe's pipe()
	set ocidError to current application's NSPipe's pipe()
	ocidTermTask's setStandardOutput:(ocidOutPut)
	ocidTermTask's setStandardError:(ocidError)
	set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
	if (item 1 of listDoneReturn) is (false) then
		log "エラーコード：" & (item 2 of listDoneReturn)'s code() as text
		log "エラードメイン：" & (item 2 of listDoneReturn)'s domain() as text
		log "Description:" & (item 2 of listDoneReturn)'s localizedDescription() as text
		log "FailureReason:" & (item 2 of listDoneReturn)'s localizedFailureReason() as text
	end if
	##################
	#終了待ち
	ocidTermTask's waitUntilExit()
	##################
	#標準出力をログに
	set ocidOutPutData to ocidOutPut's fileHandleForReading()
	set listResponse to ocidOutPutData's readDataToEndOfFileAndReturnError:(reference)
	set ocidStdOut to (item 1 of listResponse)
	set ocidStdOut to current application's NSString's alloc()'s initWithData:(ocidStdOut) encoding:(current application's NSUTF8StringEncoding)
	##これが戻り値
	return ocidStdOut
end doExecTask