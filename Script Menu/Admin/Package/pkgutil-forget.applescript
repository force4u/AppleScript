#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

set strCommandText to ("/usr/sbin/pkgutil  --packages") as text
set strResponse to (do shell script strCommandText) as text

set AppleScript's text item delimiters to "\r"
set listPKGID to every text item of strResponse
set AppleScript's text item delimiters to ""



set ocidArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidArrayM's addObjectsFromArray:listPKGID

set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(yes) selector:"localizedStandardCompare:"
set ocidDescriptorArray to refMe's NSArray's arrayWithObject:(ocidDescriptor)
set ocidSortedArray to ocidArrayM's sortedArrayUsingDescriptors:(ocidDescriptorArray)

set listSortedArray to {} as list

repeat with itemArray in ocidSortedArray
	set end of listSortedArray to (itemArray as text)
end repeat


#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
try
	set listResponse to (choose from list listSortedArray with title "選んだください" with prompt "pkgを忘れます" default items (item 1 of listSortedArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strPKID to listResponse as text
set strCommandText to ("/usr/bin/sudo /usr/sbin/pkgutil -v  --forget '" & strPKID & "'") as text
set strResponse to (do shell script strCommandText) as text
if strResponse is "false" then
	set strCommandText to ("/usr/sbin/pkgutil -v --forget " & strPKID & "") as text
	set strResponse to (do shell script strCommandText) as text
end if

return
