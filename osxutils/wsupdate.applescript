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
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
	appSharedWorkspace's noteFileSystemChanged:(ocidFilePath)
			return 0
end run

on doPrintHelp()
	set strHelpText to ("
fileの内容が変更されていることを通知します
使用方法:
  wsupdate.applescript /パス/ファイル
引数:
  /パス/ファイル アプリケーションにファイルが更新されたことを通知したいパス
例:
  wsupdate.applescript /some/file 
注意:
  通知はセキュリティ設定に依存します

") as text
	return strHelpText
end doPrintHelp

