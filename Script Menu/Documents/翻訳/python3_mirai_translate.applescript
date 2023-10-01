#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# 		USE
#		https://pypi.org/project/mirai-translate/
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

########################
## クリップボードの中身取り出し
###初期化
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to appPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "入力してください" as text
	end if
end if


###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/Tips.app/Contents/Resources/AppIcon.icns") as alias
set strTitle to ("入力してください") as text
set strMes to ("【日→英】翻訳します\r少し時間がかかります\r約５秒") as text
set recordResult to (display dialog strMes with title strTitle default answer strReadString buttons {"キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 30 with icon aliasIconPath without hidden answer)

if (gave up of recordResult) is true then
	return "時間切れです"
else if (button returned of recordResult) is "キャンセル" then
	return "キャンセルです"
else
	set strReturnedText to (text returned of recordResult) as text
end if
set strResponseText to doReplace(strReturnedText, "\"", "\\\"")
set strResponseText to doReplace(strResponseText, "\r", " ")
set strResponseText to doReplace(strResponseText, "\n", " ")
############
set strCommandText to ("/usr/bin/which python3") as text
try
	set strBinPath to (do shell script strCommandText) as text
on error
	try
		##	do shell script "/usr/bin/xcode-select --install"
	end try
	return "python3未インストールです"
end try

set strCommandText to ("\"" & strBinPath & "\" -c \"from mirai_translate import Client; cli = Client(); print(cli.translate('" & strResponseText & "', 'ja', 'en'));\"") as text
set strResponse to (do shell script strCommandText) as text

set strResponse to (strReturnedText & "\n" & strResponse & "\n")

###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/Tips.app/Contents/Resources/AppIcon.icns") as alias
set strTitle to ("戻り値です") as text
set strMes to ("戻り値です") as text
set recordResult to (display dialog strMes with title strTitle default answer strResponse buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

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




#################################
##クオテーションの置換用
to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace


