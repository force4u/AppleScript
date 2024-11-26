#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argNo)
	if (argNo as text) is "" then
		log doPrintHelp()
		return
	end if
	set strNo to argNo as text
	
	set ocidNoString to current application's NSString's stringWithString:(strNo)
	set ocidDemSet to current application's NSCharacterSet's characterSetWithCharactersInString:("0123456789")
	set ocidCharSet to ocidDemSet's invertedSet()
	set ocidOption to (current application's NSLiteralSearch)
	set ocidRange to ocidNoString's rangeOfCharacterFromSet:(ocidCharSet) options:(ocidOption)
	set ocidLocation to ocidRange's location() as text
	if ocidLocation ≠ "9.223372036855E+18" then
		return "数値以外の値があったの中止"
	else
		set numNo to strNo as integer
	end if
	
	##################　
	#設定問い合わせ
	set strCommandText to ("get volume settings") as text
	log "\r" & strCommandText & "\r"
	set ocidComString to current application's NSString's stringWithString:(strCommandText)
	set ocidTermTask to current application's NSTask's alloc()'s init()
	ocidTermTask's setLaunchPath:("/usr/bin/osascript")
	set ocidArgumentsArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidArgumentsArray's addObject:("-e")
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
	#終了待ち
	ocidTermTask's waitUntilExit()
	##################
	#標準出力
	set ocidOutPutData to ocidOutPut's fileHandleForReading()
	set listResponse to ocidOutPutData's readDataToEndOfFileAndReturnError:(reference)
	set ocidStdOut to (item 1 of listResponse)
	set ocidStdOut to current application's NSString's alloc()'s initWithData:(ocidStdOut) encoding:(current application's NSUTF8StringEncoding)
	##これが戻り値
	set recodSetting to ocidStdOut as text
	
	if recodSetting contains "missing value" then
		return "出力先がボリューム変更できないデバイスです"
	end if
	
	##################　
	#設定変更
	set strCommandText to ("set volume output volume " & strNo & "") as text
	log "\r" & strCommandText & "\r"
	set ocidComString to current application's NSString's stringWithString:(strCommandText)
	set ocidTermTask to current application's NSTask's alloc()'s init()
	ocidTermTask's setLaunchPath:("/usr/bin/osascript")
	set ocidArgumentsArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidArgumentsArray's addObject:("-e")
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
	#終了待ち
	ocidTermTask's waitUntilExit()
	##################
	#標準出力
	set ocidOutPutData to ocidOutPut's fileHandleForReading()
	set listResponse to ocidOutPutData's readDataToEndOfFileAndReturnError:(reference)
	set ocidStdOut to (item 1 of listResponse)
	set ocidStdOut to current application's NSString's alloc()'s initWithData:(ocidStdOut) encoding:(current application's NSUTF8StringEncoding)
	##これが戻り値
	set recodSetting to ocidStdOut as text
	
	##################　
	#設定変更
	set strCommandText to ("set volume alert volume " & strNo & "") as text
	log "\r" & strCommandText & "\r"
	set ocidComString to current application's NSString's stringWithString:(strCommandText)
	set ocidTermTask to current application's NSTask's alloc()'s init()
	ocidTermTask's setLaunchPath:("/usr/bin/osascript")
	set ocidArgumentsArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidArgumentsArray's addObject:("-e")
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
	#終了待ち
	ocidTermTask's waitUntilExit()
	##################
	#標準出力
	set ocidOutPutData to ocidOutPut's fileHandleForReading()
	set listResponse to ocidOutPutData's readDataToEndOfFileAndReturnError:(reference)
	set ocidStdOut to (item 1 of listResponse)
	set ocidStdOut to current application's NSString's alloc()'s initWithData:(ocidStdOut) encoding:(current application's NSUTF8StringEncoding)
	##これが戻り値
	set recodSetting to ocidStdOut as text
	
	return 0
end run

on doPrintHelp()
	set strHelpText to ("setvolume.applescript 0-100 で音量を0から100に設定します") as text
	return strHelpText
end doPrintHelp

