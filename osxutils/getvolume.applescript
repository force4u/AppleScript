#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argNo)
	if (argNo as text) is "-h" then
		log doPrintHelp()
		return
	end if


set recodSetting to (do shell script  "/usr/bin/osascript -e 'get volume settings'") 
if recodSetting contain "missing value" then
	return "出力先がボリューム変更できないデバイスです"
else if recodSetting contain "muted:true" then
	return "ミュート中　音量0です"
else
return recodSetting
end if
	return
end run

on doPrintHelp()
	set strHelpText to ("
音声出力の現在のボリューム音量値を0-100で戻します
使用方法:　オプションなし
setvolume.applescript

") as text
	return strHelpText
end doPrintHelp

