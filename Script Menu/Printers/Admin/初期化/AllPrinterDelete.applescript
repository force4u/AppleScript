#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	プリンタ環境を初期化します
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###プリンタ名をリストで取得
set ocidPrinterNameArray to refMe's NSPrinter's printerNames()
set listPrinterName to ocidPrinterNameArray as list

##プリンタのジョブの受付を停止させる
repeat with itemPrinterName in listPrinterName
	set strPrinterName to itemPrinterName as text
	set strCommandText to ("/usr/sbin/cupsreject \"" & strPrinterName & "\"") as text
	log strCommandText
	set ocidAppName to (refMe's NSString's stringWithString:strCommandText)
	set ocidTermTask to refMe's NSTask's alloc()'s init()
	(ocidTermTask's setLaunchPath:"/bin/zsh")
	(ocidTermTask's setArguments:({"-c", ocidAppName}))
	set listDoneReturn to (ocidTermTask's launchAndReturnError:(reference))
	set ocidNSErrorData to item 2 of listDoneReturn
	log (item 2 of listDoneReturn)
	if ocidNSErrorData is not (missing value) then
		doGetErrorData(ocidNSErrorData)
	end if
end repeat

###プリンタをdisableにする
repeat with itemPrinterName in listPrinterName
	set strPrinterName to itemPrinterName as text
	set strCommandText to ("/usr/sbin/cupsdisable \"" & strPrinterName & "\"") as text
	log strCommandText
	set ocidAppName to (refMe's NSString's stringWithString:strCommandText)
	set ocidTermTask to refMe's NSTask's alloc()'s init()
	(ocidTermTask's setLaunchPath:"/bin/zsh")
	(ocidTermTask's setArguments:({"-c", ocidAppName}))
	set listDoneReturn to (ocidTermTask's launchAndReturnError:(reference))
	set ocidNSErrorData to item 2 of listDoneReturn
	log (item 2 of listDoneReturn)
	if ocidNSErrorData is not (missing value) then
		doGetErrorData(ocidNSErrorData)
	end if
end repeat


###ジョブを削除
set strCommandText to ("/usr/bin/cancel -a -x")
log strCommandText
set ocidAppName to refMe's NSString's stringWithString:strCommandText
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidAppName})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
set ocidNSErrorData to item 2 of listDoneReturn
log (item 2 of listDoneReturn)
if ocidNSErrorData is not (missing value) then
	doGetErrorData(ocidNSErrorData)
end if

###プリンタをlprmする
repeat with itemPrinterName in listPrinterName
	set strPrinterName to itemPrinterName as text
	set strCommandText to ("/usr/bin/lprm -P  \"" & strPrinterName & "\"") as text
	log strCommandText
	set ocidAppName to (refMe's NSString's stringWithString:strCommandText)
	set ocidTermTask to refMe's NSTask's alloc()'s init()
	(ocidTermTask's setLaunchPath:"/bin/zsh")
	(ocidTermTask's setArguments:({"-c", ocidAppName}))
	set listDoneReturn to (ocidTermTask's launchAndReturnError:(reference))
	set ocidNSErrorData to item 2 of listDoneReturn
	log (item 2 of listDoneReturn)
	if ocidNSErrorData is not (missing value) then
		doGetErrorData(ocidNSErrorData)
	end if
end repeat


###プリンタをpadmin -xする
repeat with itemPrinterName in listPrinterName
	set strPrinterName to itemPrinterName as text
	set strCommandText to ("/usr/sbin/lpadmin -x  \"" & strPrinterName & "\"") as text
	log strCommandText
	set ocidAppName to (refMe's NSString's stringWithString:strCommandText)
	set ocidTermTask to refMe's NSTask's alloc()'s init()
	(ocidTermTask's setLaunchPath:"/bin/zsh")
	(ocidTermTask's setArguments:({"-c", ocidAppName}))
	set listDoneReturn to (ocidTermTask's launchAndReturnError:(reference))
	set ocidNSErrorData to item 2 of listDoneReturn
	log (item 2 of listDoneReturn)
	if ocidNSErrorData is not (missing value) then
		doGetErrorData(ocidNSErrorData)
	end if
end repeat

###CUPSをリセットする
set strCommandText to ("/System/Library/Frameworks/ApplicationServices.framework/Frameworks/PrintCore.framework/Versions/A/printtool --reset -f") as text
log strCommandText
set ocidAppName to refMe's NSString's stringWithString:strCommandText
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidAppName})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
set ocidNSErrorData to item 2 of listDoneReturn
log (item 2 of listDoneReturn)
if ocidNSErrorData is not (missing value) then
	doGetErrorData(ocidNSErrorData)
end if
#############################
###CFPreferencesを再起動
#############################
#####CFPreferencesを再起動させて変更後の値をロードさせる
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

delay 2


####プリンタのシステム環境設定を開く
###起動
tell application id "com.apple.systempreferences"
	launch
end tell
###起動待ち
tell application id "com.apple.systempreferences"
	###起動確認　最大１０秒
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell
tell application "System Settings"
	reveal anchor "print" of pane id "com.apple.Print-Scan-Settings.extension"
end tell

display notification "処理終了" with title "処理が終了" subtitle "処理が終了しました" sound name "Sonumi"
log "\r\r>>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<\r\r"



to doGetErrorData(ocidNSErrorData)
	#####個別のエラー情報
	log "エラーコード：" & ocidNSErrorData's code() as text
	log "エラードメイン：" & ocidNSErrorData's domain() as text
	log "Description:" & ocidNSErrorData's localizedDescription() as text
	log "FailureReason:" & ocidNSErrorData's localizedFailureReason() as text
	log ocidNSErrorData's localizedRecoverySuggestion() as text
	log ocidNSErrorData's localizedRecoveryOptions() as text
	log ocidNSErrorData's recoveryAttempter() as text
	log ocidNSErrorData's helpAnchor() as text
	set ocidNSErrorUserInfo to ocidNSErrorData's userInfo()
	set ocidAllValues to ocidNSErrorUserInfo's allValues() as list
	set ocidAllKeys to ocidNSErrorUserInfo's allKeys() as list
	repeat with ocidKeys in ocidAllKeys
		if (ocidKeys as text) is "NSUnderlyingError" then
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedDescription() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedFailureReason() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoverySuggestion() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoveryOptions() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s recoveryAttempter() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s helpAnchor() as text
		else
			####それ以外の値はそのままテキストで読める
			log (ocidKeys as text) & ": " & (ocidNSErrorUserInfo's valueForKey:ocidKeys) as text
		end if
	end repeat
	
end doGetErrorData
