#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　使ってないと値が戻らないので　これは、あまり使い物にならない
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##ライブラリDIR
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
##ファイルURL
set ocidPlistFilePathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.apple.finder.plist")
####PLIST
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
set ocidViewDict to ocidPlistDict's objectForKey:"ViewSettingsDictionary"
if ocidViewDict = (missing value) then
	return "ビューセッティングがありません"
else
	set ocidKeyArray to ocidViewDict's allKeys()
end if

###リスト生成
set listTagName to {} as list
###キーの数だけ繰り返し
repeat with itemKeys in ocidKeyArray
	set strKeyName to itemKeys as text
	
	###文字列整形
	set ocidKeyName to (refMe's NSString's stringWithString:(strKeyName))
	set ocidKeyNameM to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
	(ocidKeyNameM's setString:(ocidKeyName))
	set ocidLength to ocidKeyNameM's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	(ocidKeyNameM's replaceOccurrencesOfString:("_Tag_ViewSettings") withString:("") options:(ocidOption) range:(ocidRange))
	set strKeyNameM to ocidKeyNameM as text
	###
	set end of listTagName to strKeyNameM
	
end repeat

log listTagName as list

return listTagName as list
