#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

##############################
###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserApplicationDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidUserApplicationDirPathArray's firstObject()
set aliasDesktopDirPath to ocidDesktopDirPathURL's absoluteURL() as alias
##############################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if


set strPromptText to "フォルダを選んで下さい。" as text
set strMesText to "不可視属性を解除します" as text
set aliasFilePath to (choose folder strMesText default location aliasDesktopDirPath with prompt strPromptText with invisibles without multiple selections allowed and showing package contents) as alias
try
	set aliasFilePath to result as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
if aliasFilePath is false then
	return "エラーしました"
end if

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
set strFilePath to (ocidFilePathURL's |path|()) as text


set strLine3 to ("/usr/bin/chflags nohidden \"" & strFilePath & "\"") as text
set strLine1 to ("/usr/bin/xattr -c \"" & strFilePath & "\"") as text
set strLine2 to ("/usr/bin/SetFile -a v  \"" & strFilePath & "\"") as text

set strMes to (strLine1 & "\r" & strLine2 & "\r" & strLine3) as text

###ICONがみつかない時用にデフォルトを用意する
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" as alias
set recordResult to (display dialog "コマンド戻り値" with title "コマンド整形" default answer strMes buttons {"クリップボードにコピー", "キャンセル", "ターミナルで実行"} default button "ターミナルで実行" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if
if button returned of recordResult is "ターミナルで実行" then
	set strResult to strMes as text
	set AppleScript's text item delimiters to "\r"
	set listCommandText to every text item of strResult
	set AppleScript's text item delimiters to ""
	repeat with itemCommandText in listCommandText
		
		tell application "Terminal"
			set objNewWindow to (do script "\n\n")
		end tell
		delay 0.5
		tell application "Terminal"
			do script itemCommandText in objNewWindow
		end tell
		delay 0.5
		tell application "Terminal"
			do script "\n\n" in objNewWindow
		end tell
		
	end repeat
	
	
end if

