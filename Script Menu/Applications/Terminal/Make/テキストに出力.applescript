#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*	Base Script 
https://www.macscripter.net/t/lets-say-you-like-to-copy-text-from-terminal-app/74984
*)
# 
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

###ファイル名
set strDateNo to doGetDateNo("yyyyMMddhhmmss")
set strFileName to "ターミナル出力." & strDateNo & ".txt"


###デスクトップフォルダ　に保存
set appFileManager to refMe's NSFileManager's defaultManager()
set listResponse to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserDesktopPathURL to (item 1 of listResponse)
###ファイルパスURL
set ocidSaveFilePathURL to ocidUserDesktopPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set ocidSaveFilePath to ocidSaveFilePathURL's |path|()
set strSaveFilePath to ocidSaveFilePath as text
###本処理
set strText to its doGetAttributesOfProcess("Terminal")
###戻り値をテキストエディタに展開
tell application "TextEdit"
	make new document with properties {name:strFileName, path:strSaveFilePath, text:strText}
	tell document strFileName
		activate
		###保存して初めて確定
		save in (POSIX file strSaveFilePath)
		close
	end tell
	open (POSIX file strSaveFilePath)
	activate
end tell







on doGetAttributesOfProcess(argProcessName)
	tell application "System Events"
		set listAttributeName to name of attributes of process argProcessName
		
		repeat with itemAttribute in listAttributeName
			tell (attribute itemAttribute of process argProcessName)
				
				log its value as list
				log itemAttribute
			end tell
		end repeat
		
		if "AXFocusedUIElement" is in listAttributeName then
			tell value of attribute "AXFocusedUIElement" of process argProcessName
				return its value
			end tell
		end if
	end tell
end doGetAttributesOfProcess





to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
