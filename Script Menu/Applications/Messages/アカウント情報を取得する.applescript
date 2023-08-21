#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


set strOutPutText to ("") as text

tell application id "com.apple.MobileSMS"
	set listAccount to every account as list
	repeat with itemAccount in listAccount
		tell itemAccount
			set strOutPutText to strOutPutText & "サービスタイプ:" & (service type as text) & "\r"
			set strOutPutText to strOutPutText & "アカウントID:" & (id as text) & "\r"
			set strOutPutText to strOutPutText & "詳細:" & (description as text) & "\r"
			set strOutPutText to strOutPutText & "----+----1----+----2----+-----3----+----4----+----5\r"
		end tell
	end repeat
end tell

################################
######ダイアログ
################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
set aliasIconPath to POSIX file "/Applications/Messenger.app/Contents/Resources/messenger.icns" as alias

try
	set recordResponse to (display dialog "詳しく" with title "入力してください" default answer strOutPutText buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else if button returned of recordResponse is "クリップボードにコピー" then
	set strText to text returned of recordResponse as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	##結果をペーストボードにテキストで入れる
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	return
else
	log "キャンセルしました"
	return "キャンセルしました"
end if


