#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#####################################
######コマンド実行
#####################################
set strCommandText to "/usr/sbin/system_profiler  SPHardwareDataType -xml"
set strReadString to (do shell script strCommandText) as text

#####################################
######PLIST　をDictで処理
#####################################
###戻り値をストリングに
set ocidReadString to refMe's NSString's stringWithString:(strReadString)
###NSDATAにして
set ocidReadData to ocidReadString's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###PLISTに変換
set listResults to refMe's NSPropertyListSerialization's propertyListWithData:(ocidReadData) options:0 format:(refMe's NSPropertyListXMLFormat_v1_0) |error|:(reference)
set ocidPlistDataArray to item 1 of listResults
##ここがroot
set ocidPlistRoot to ocidPlistDataArray's firstObject()
##item0
set ocidRootDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidPlistRoot))
##ITEMS
set ocidItemsArray to (ocidRootDict's objectForKey:("_items"))
##item0
set ocidItemsDict to ocidItemsArray's firstObject()
##キーの値をリストで取り
set ocidAllKeys to ocidItemsDict's allKeys()
set strOutPutText to ("") as text
repeat with itemAllKeys in ocidAllKeys
	set strAllKey to itemAllKeys as text
	set strValue to (ocidItemsDict's valueForKey:(itemAllKeys)) as text
	set strOutPutText to (strOutPutText & strAllKey & ": " & strValue & "\n") as text
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
set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as text
set aliasIconPath to POSIX file strIconPath as alias
###ダイアログ
set recordResult to (display dialog " 戻り値です\rコピーしてメールかメッセージを送ってください" with title "SPHardwareDataType" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 30 with icon aliasIconPath without hidden answer)
###クリップボードコピー
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
