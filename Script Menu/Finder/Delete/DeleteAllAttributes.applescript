#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias

###ANY
set listUTI to {"public.item"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでくださいAttributesを削除します") as text


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

set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles and multiple selections allowed without showing package contents) as list


repeat with itemFilePath in listAliasFilePath
	###パス
	set aliasFilePath to itemFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	###コマンド
	set strCommandText to ("/usr/bin/xattr \"" & strFilePath & "\"") as text
	set strResponse to (do shell script strCommandText) as text
	###コマンド戻り値をリストに
	set AppleScript's text item delimiters to "\r"
	set listUTI to every text item of strResponse
	set AppleScript's text item delimiters to ""
	###戻り値のAttributesの数だけ繰り返し
	repeat with itemUTI in listUTI
		###Attributesを削除
		set strCommandText to ("/usr/bin/xattr -rd " & itemUTI & "  \"" & strFilePath & "\"") as text
		do shell script strCommandText
	end repeat
	
end repeat
