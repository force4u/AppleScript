#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argOption)
	if (argOption as text) is "-h" then
		log doPrintHelp()
		return
	else if (argOption as text) is "" then
		set appFileManager to current application's NSFileManager's defaultManager()
		set ocidCurrentDirPath to appFileManager's currentDirectoryPath()
		set appPasteboard to current application's NSPasteboard's generalPasteboard()
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidCurrentDirPath) forType:(current application's NSPasteboardTypeString)
		return
	else
		set strFilePath to argOption as text
		set ocidFilePath to current application's NSString's stringWithString:(strFilePath)
		set appPasteboard to current application's NSPasteboard's generalPasteboard()
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidFilePath) forType:(current application's NSPasteboardTypeString)
		return
	end if
	
end run


on doPrintHelp()
	set strHelpText to ("\nクリップボードにターミナル上のカレントディレクトリをコピーします\n例:\ncpath.applescript /some/file/path \n\n\n") as text
	return strHelpText
end doPrintHelp