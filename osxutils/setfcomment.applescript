#!/usr/bin/osascript
use AppleScript version "2.8"
use scripting additions


on run (argFilePathAndComment)
	if (argFilePathAndComment as text) is "" then
		log doPrintHelp()
		return 0
	else if (argFilePathAndComment as text) is "-h" then
		log doPrintHelp()
		return 0
	else if (count of argFilePathAndComment) = 2 then
		set {argFilePath, argComment} to argFilePathAndComment
		set strFilePath to argFilePath as text
		set strFilePath to doReplace(strFilePath, "\\ ", " ")
		set strComment to argComment as text
		set aliasFilePath to (POSIX file strFilePath) as alias
		tell application "Finder"
			set comment of aliasFilePath to strComment
		end tell
		return 0
	else if (count of argFilePathAndComment) = 1 then
		set strFilePath to argFilePathAndComment as text
		set aliasFilePath to (POSIX file strFilePath) as alias
		tell application "Finder"
			set strComment to comment of aliasFilePath
		end tell
		return strComment
	end if
	return 0
end run

on doPrintHelp()
	set strHelpText to ("
Finderコメントの読み取り　書き込みをします

setfcomment.applescript /some/file 設定されているコメントを戻します
setfcomment.applescript /some/file コメント コメントを設定します


") as text
	return strHelpText
end doPrintHelp

to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace