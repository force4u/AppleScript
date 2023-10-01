#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

tell application id "com.apple.AddressBook"
	###自分のカード
	tell my card
		set strVcardText to vcard as text
	end tell
end tell

####Vcardの内容をリスト化（改行がWINDOWS）
set AppleScript's text item delimiters to "\r\n"
set listVcardText to every text item of strVcardText
set AppleScript's text item delimiters to ""
###EMAIL取得用
set strOutPutText to "" as text
####Vcardの数だけ繰り返し
repeat with itemVcardText in listVcardText
	##テキストで確定させて
	set strItemVcardText to itemVcardText as text
	##EMAILから始まる場合
	if strItemVcardText starts with "ADR" then
		###カンマで区切って
		set AppleScript's text item delimiters to ":"
		set listItemVcardText to every text item of strItemVcardText
		set AppleScript's text item delimiters to ""
		set strADR to (item 2 of listItemVcardText)
		set AppleScript's text item delimiters to ";"
		set listItemADRText to every text item of strADR
		set AppleScript's text item delimiters to ""
		set numCntAdd to count of listItemADRText
		repeat numCntAdd times
			set strLineText to (item numCntAdd of listItemADRText) as text
			if strLineText is not "" then
				set strLineText to (strLineText & "\n") as text
				set strOutPutText to strOutPutText & strLineText as text
			end if
			set numCntAdd to (numCntAdd - 1) as integer
		end repeat
		
	end if
end repeat


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
set aliasIconPath to POSIX file "/System/Applications/Contacts.app/Contents/Resources/Contacts.icns"

set strMes to ("戻り値です") as text

set recordResult to (display dialog strMes with title "bundle identifier" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

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

