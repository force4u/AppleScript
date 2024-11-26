#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argSuffxAndFilePath)
if (argSuffxAndFilePath as text) is "" then
log doPrintHelp()
return
else if (count of argSuffxAndFilePath) < 2 then
log doPrintHelp()
return
else if (count of argSuffxAndFilePath) = 2 then
	set {argSuffix, argFilePath} to argSuffxAndFilePath
	set strExtensionName to argSuffix as text
else
log doPrintHelp()
return
	end if

	#####
	set strFilePath to argFilePath as text
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	#今の拡張子を取る 追加がいい場合は取る
	set ocidBaseFilePath to ocidFilePath's stringByDeletingPathExtension()
	#####
	set strSuffix to argSuffix as text
	set ocidDistFilePath to ocidBaseFilePath's stringByAppendingPathExtension:(strSuffix)
	#####
	set appFileManager to current application's NSFileManager's defaultManager()
	set listDone to (appFileManager's moveItemAtPath:(ocidFilePath) toPath:(ocidDistFilePath) |error|:(reference))
	if (item 1 of listDone) is true then
		return (ocidFilePathStr as text) & " --> " & (ocidDistFilePath as text)
	else if (item 1 of listDone) is false then
		set strErrorNO to (item 2 of listDone)'s code() as text
		set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
		current application's NSLog("■：" & strErrorNO & " : " & strErrorMes)
		return "エラーしました" & strErrorNO & strErrorMes
	end if
	return 0
end run


on doPrintHelp()
	set strHelpText to ("
ファイルに拡張子を付けます。今ある拡張子を置き換えます
使用方法:
  setsuffix.applescript 拡張子 /パス/ファイル 

引数:
  拡張子　付与したい拡張子をテキストで
  /パス/ファイル  ファイルでもフォルダでも可能

例:
setsuffix.applescript suffix /some/path/file

注意:
- 拡張子の追加にはなりません　今ある拡張子は置換されます
") as text
	return strHelpText
end doPrintHelp

