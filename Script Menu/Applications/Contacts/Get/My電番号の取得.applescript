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
set listEmailAdd to {} as list
set strHomeEmail to "" as text
set strWORKEmail to "" as text
####Vcardの数だけ繰り返し
repeat with itemVcardText in listVcardText
	##テキストで確定させて
	set strItemVcardText to itemVcardText as text
	##EMAILから始まる場合
	if strItemVcardText starts with "TEL" then
		###カンマで区切って
		set AppleScript's text item delimiters to ":"
		set listItemVcardText to every text item of strItemVcardText
		set AppleScript's text item delimiters to ""
		set strType to (item 1 of listItemVcardText) as text
		###後半部分が電番
		set strEmail to (item 2 of listItemVcardText) as text
		####リストに格納して
		copy strEmail to end of listEmailAdd
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
try
	set listResponse to (choose from list listEmailAdd with title "選んでください" with prompt "メールを選んでください" default items (item 1 of listEmailAdd) OK button name "クリップボードにコピー" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if

try
	set strText to (item 1 of listResponse) as text
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


