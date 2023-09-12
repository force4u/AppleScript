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
	set strMes to ("読める文字を％エンコードしますnテキストやURL等を入力してください") as text
	
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

##通常テキストの場合
set strText to strResponse as text
(* ###改行　タブの除去
set ocidText to refMe's NSString's stringWithString:(strText)
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidURLM's appendString:(ocidText)
##行末の改行
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("t") withString:("")
set strTextM to ocidTextM as text
*)

set strDecodedText to doUnicodeEscapeDecode(strText) as text

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
set strMes to ("戻り値ですr" & strDecodedText) as text

set recordResult to (display dialog strMes with title "%デコード" default answer strDecodedText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

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






####################################
######
####################################

on doUnicodeEscapeDecode(argInputText)
	set strInputText to argInputText as text
	set ocidInputStr to refMe's NSMutableString's stringWithString:(argInputText)
	### U30a4 形式の場合
	if strInputText contains "U" then
		set ocidDataStr to ocidInputStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set ocidDataStr to ocidDecodeStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set strDecodeText to ocidDecodeStr as text
		### U30a4 形式の場合
	else if strInputText contains "U" then
		set ocidDataStr to ocidInputStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
		set ocidDecodeStr to refMe's NSString's alloc()'s initWithData:(ocidDataStr) encoding:(refMe's NSNonLossyASCIIStringEncoding)
		set strDecodeText to ocidDecodeStr as text
	else
		log "何もしないで戻す"
		set strDecodeText to strInputText as text
	end if
	return strDecodeText
end doUnicodeEscapeDecode

