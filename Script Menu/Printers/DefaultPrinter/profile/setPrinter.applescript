#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##############################
set thePrinterList to (do shell script "lpstat -e") as text
set AppleScript's text item delimiters to "\r"
set listPrinterList to every text item of thePrinterList as list
set AppleScript's text item delimiters to ""
log listPrinterList as list

try
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	set listResponse to (choose from list listPrinterList with title "選んでください" with prompt "デフォルトプリンタは？" default items (item 1 of listPrinterList) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text



##############################
###	profile　PRINTER行削除
##############################
set strCommandText to ("date +%Y%m%d-%H%M%S") as text
set strDate to (do shell script strCommandText) as text

set strCommandText to ("/bin/mkdir -pm 700  ~/.profile_backup") as text
do shell script strCommandText

set listProfile to {".profile", ".bash_profile", ".zshrc"} as list

repeat with itemProfile in listProfile
	set strProfilePath to ("~/" & itemProfile & "") as text
	set strBackUpPath to "~/.profile_backup/" & itemProfile & "." & strDate & ".backup"
	set strCommandText to ("/usr/bin/touch " & strProfilePath & "") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/ditto " & strProfilePath & "  " & strBackUpPath & "") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/grep -v \"export PRINTER\" " & strBackUpPath & "  >  " & strProfilePath & "") as text
	try
		do shell script strCommandText
	end try
end repeat

set listProfile to {".tcshrc", ".cshrc"} as list

repeat with itemProfile in listProfile
	set strProfilePath to ("~/" & itemProfile & "") as text
	set strBackUpPath to "~/.profile_backup/" & itemProfile & "." & strDate & ".backup"
	set strCommandText to ("/usr/bin/touch " & strProfilePath & "") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/ditto " & strProfilePath & "  " & strBackUpPath & "") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/grep -v \"setenv PRINTER\" " & strBackUpPath & "  >  " & strProfilePath & "") as text
	try
		do shell script strCommandText
	end try
end repeat

delay 1
##############################
###	lpadmin CUPSデフォルト設定
##############################
do shell script "/usr/sbin/lpadmin  -d \"" & strResponse & "\""

##############################
###	profile PRINTER行
##############################
set listProfile to {".profile", ".bash_profile", ".zshrc"} as list

repeat with itemProfile in listProfile
	set strProfilePath to ("~/" & itemProfile & "") as text
	set strCommandText to ("/bin/echo \"export PRINTER=" & strResponse & "\" >> " & strProfilePath & "") as text
	do shell script strCommandText
end repeat

set listProfile to {".tcshrc", ".cshrc"} as list

repeat with itemProfile in listProfile
	set strProfilePath to ("~/" & itemProfile & "") as text
	set strCommandText to ("/bin/echo \"setenv PRINTER " & strResponse & "\" >> " & strProfilePath & "") as text
	do shell script strCommandText
end repeat


##############################
###	profile リロード 
##############################
set listPath to {"/bin/zsh", "/bin/tcsh", "/bin/sh", "/bin/dash", "/bin/csh", "/bin/bash", "/bin/ksh"}

repeat with itemPath in listPath
	set strBinPath to itemPath as text
	set strCommandText to ("exec " & strBinPath & " -l") as text
	try
		do shell script strCommandText
	end try
end repeat



