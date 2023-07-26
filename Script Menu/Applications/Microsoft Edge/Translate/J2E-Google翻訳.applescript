#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# quicktimer.cocolog-nifty.com
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###アプリケーションのバンドルID
set strChkBundleID to "com.microsoft.edgemac"

#########################
tell application id strChkBundleID
	set numCntWindow to (count of every window) as integer
end tell
###Safariのウィンドウが無いならダイアログを出す
if numCntWindow < 1 then
	##デフォルトクリップボードから
	set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
	try
		set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
	on error
		set ocidPasteboardStrings to "" as text
	end try
	set strDefaultAnswer to ocidPasteboardStrings as text
	################################
	######ダイアログ
	################################
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
	set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
	try
		set recordResponse to (display dialog "URLをペーストしてください" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れですやりなおしてください"
	end if
	if "OK" is equal to (button returned of recordResponse) then
		set strURL to (text returned of recordResponse) as text
	else
		log "キャンセルしました"
		return "キャンセルしました"
	end if
	
	
else
	tell application "Microsoft Edge"
		tell front window
			tell active tab
				set strURL to URL as text
				set strTITLE to title as text
			end tell
		end tell
	end tell
end if


####翻訳ページURL

set strTranslateURL to "https://translate.google.com/?sl=auto&tl=en&text=" & strURL & "&op=translate" as text

log strTranslateURL
###OPEN
tell application "Microsoft Edge"
	activate
	tell front window
		set objNewTab to make new tab
		tell objNewTab to set URL to strTranslateURL
	end tell
end tell
