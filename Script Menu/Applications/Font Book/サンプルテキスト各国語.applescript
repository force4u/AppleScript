#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
###PLISTファイルパス
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidApplicationDirPathURL to ocidURLsArray's firstObject()
set ocidPlistPathURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Font Book.app/Contents/Resources/Multipreview.loctable")
###PLIST読み込み
set listPlistDict to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to (item 1 of listPlistDict)
set ocidAllKey to ocidPlistDict's allKeys()
###
set ocidArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidArrayM's addObjectsFromArray:ocidAllKey
####
set listLoctable to (ocidAllKey as list)
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listLoctable with title "選んでください" with prompt "言語を選んでください" default items (item 1 of listLoctable) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
####
set ocidLangDict to ocidPlistDict's objectForKey:(strResponse)
set strSampleString to (ocidLangDict's valueForKey:("FB_SAMPLE_STRING")) as text
###
set aliasIconPath to POSIX file "/System/Applications/Font Book.app/Contents/Resources/AppIcon.icns"

set strMes to ("FB_SAMPLE_STRING 戻り値です") as text
set recordResult to (display dialog strMes with title "FB_SAMPLE_STRING" default answer strSampleString buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

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

return
