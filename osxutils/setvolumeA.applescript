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
	
	set recodSetting to (do shell script "/usr/bin/osascript -e 'get volume settings'")
	if recodSetting contains "missing value" then
		return "出力先がボリューム変更できないデバイスです"
	end if
	
	try
		set strSetOutPut to ("set volume output volume " & strNo & "") as text
		do shell script "/usr/bin/osascript -e '" & strSetOutPut & "'"
		set strSetAlert to ("set volume alert volume " & strNo & "") as text
		do shell script "/usr/bin/osascript -e '" & strSetAlert & "'"
	on error
		return "変更時にエラーになりました"
	end try
	return 0
end run

on doPrintHelp()
	set strHelpText to ("setvolume.applescript 0-100 で音量を0から100に設定します") as text
	return strHelpText
end doPrintHelp

