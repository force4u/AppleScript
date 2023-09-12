#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

################################
##デフォルトクリップボードからテキスト取得
################################
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidTypeArray to appPasteboard's types()
set boolContain to ocidTypeArray's containsObject:("public.utf8-plain-text")
if boolContain = true then
	try
		set ocidPasteboardArray to appPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set ocidPasteboardStrings to ocidPasteboardArray's firstObject()
	on error
		set ocidStringData to appPasteboard's stringForType:("public.utf8-plain-text")
		set ocidPasteboardStrings to (refMe's NSString's stringWithString:(ocidStringData))
	end try
else
	set ocidPasteboardStrings to (refMe's NSString's stringWithString:(""))
end if
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
	set strMes to ("通常のHTMLをHTML Entity形式に変換します") as text
	
	set recordResponse to (display dialog strMes with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "キャンセルしました"
	return "キャンセルしました"
end if

################################
######本処理
################################

###置換レコード
##	set recordEntityMap to {|&|:"&amp;", |<|:"&lt;", |>|:"&gt;", |"|:"&quot;", |'|:"&apos;", |=|:"&#x3D;", |+|:"&#x2B;"} as record
set recordEntityMap to {|<|:"&lt;", |>|:"&gt;", |"|:"&quot;", |'|:"&apos;", |=|:"&#x3D;", |+|:"&#x2B;", |©|:"&copy;", |®|:"&reg;", |™|:"&trade;", |€|:"&euro;", |£|:"&pound;", |￥|:"&yen;", |...|:"&hellip;"} as record
###ディクショナリにして
set ocidEntityMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordEntityMap)
###キーの一覧を取り出します
set ocidAllKeys to ocidEntityMap's allKeys()
log ocidAllKeys as list
##通常テキストの場合
set strText to strResponse as text
###選択中テキスト
set ocidText to refMe's NSString's stringWithString:(strText)
###可変テキストにして
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidTextM's setString:(ocidText)
###&だけ先に処理しておく
set ocidTextM to (ocidTextM's stringByReplacingOccurrencesOfString:("&") withString:("&amp;"))

###取り出したキー一覧を順番に処理
repeat with itemAllKey in ocidAllKeys
	set strItemKey to itemAllKey as text
	##キーの値を取り出して
	set strValue to (ocidEntityMap's valueForKey:(itemAllKey)) as text
	##置換
	set ocidTextM to (ocidTextM's stringByReplacingOccurrencesOfString:(strItemKey) withString:(strValue))
	##次の変換に備える
	set ocidTextM to ocidTextM
end repeat

set strEncodedText to ocidTextM as text

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
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
set strMes to ("戻り値です\r" & strEncodedText) as text

set recordResult to (display dialog strMes with title "HTML Entity形式" default answer strEncodedText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

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
			set the clipboard to strText as text
		end tell
	end try
end if
