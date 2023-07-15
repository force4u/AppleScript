#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strURL to "https://www.cloudflare.com/cdn-cgi/trace?json" as text
set ocidURL to refMe's NSURL's URLWithString:(strURL)
###URLをリクエスト
set listContents to refMe's NSString's stringWithContentsOfURL:(ocidURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidContents to item 1 of listContents
if ocidContents = (missing value) then
	return "取得に失敗しました"
end if
###改行で
set ocidCharacterSet to refMe's NSCharacterSet's newlineCharacterSet
###リスト化して
set ocidStringArray to ocidContents's componentsSeparatedByCharactersInSet:(ocidCharacterSet)
###IPアドレスを取得
repeat with itemStringArray in ocidStringArray
	if (itemStringArray as text) starts with "ip" then
		set ocidIPArray to (itemStringArray's componentsSeparatedByString:"=")
		set ocidIPAdd to (ocidIPArray's objectAtIndex:1)
	end if
end repeat
###
set strIPAdd to ocidIPAdd as text
###ホスト名解決
set strCommandText to ("/usr/bin/dig -x " & strIPAdd & " +short")
set strHostName to (do shell script strCommandText) as text

set strCommandText to ("/sbin/ifconfig | grep \"inet.*broadcast\" |  awk '{print $2}'") as text
set strLocalIP to (do shell script strCommandText) as text

set strAns to (strHostName & "\r" & strIPAdd & "\r" & strLocalIP & "") as text
##############################
#####ダイアログを前面に出す
##############################
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
################################
######ダイアログ
################################
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" as alias
try
	set recordResponse to (display dialog strAns with title "IPアドレス" default answer strAns buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
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
	return strText
else
	log "キャンセルしました"
	return "キャンセルしました" & strText
end if

return strResponse



