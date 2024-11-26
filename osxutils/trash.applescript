#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argFilePath)
	if (argFilePath as text) is "" then
		log doPrintHelp()
		return 0
	end if
	set strFilePath to argFilePath as text
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePathStr to (ocidFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath)
	set appFileManager to current application's NSFileManager's defaultManager()
	set ListDone to (appFileManager's trashItemAtURL:(ocidFilePathURL) resultingItemURL:(missing value) |error|:(reference))
	if (item 2 of ListDone) ≠ (missing value) then
		set strErrorNO to (item 2 of ListDone)'s code() as text
		set strErrorMes to (item 2 of ListDone)'s localizedDescription() as text
		current application's NSLog("■：" & strErrorNO & strErrorMes)
		return "エラーしました" & strErrorNO & strErrorMes
	end if
	
	return 0
end run

on doPrintHelp()
	set strHelpText to ("
fileに設定されている項目をゴミ箱に入れます
使用方法:
  trash.applescript /パス/ファイル またはフォルダ

引数:
  /パス/ファイル      ゴミ箱に入れたいファイルのパス

例:
    trash.applescript /Users/example/document.txt 

注意:
-削除はしません　あくまでもゴミ箱に入れるだけ

") as text
	return strHelpText
end doPrintHelp

