#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set strMes to ("mm数を半角数字で入力") as text



########################
## クリップボードの中身取り出し
########################
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "1" as text
	end if
end if
##############################
#####ダイアログ
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
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
on error
	log "エラーしました"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else
	return "キャンセル"
end if
##############################
#####戻り値整形
##############################
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###タブと改行を除去しておく
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
####戻り値を半角にする
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
##カンマ置換
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:(",") withString:(".")
###数字以外の値を取る
#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
#set ocidCharSet to ocidDecSet's invertedSet()
#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
#set ocidInteger to ocidCharArray's componentsJoinedByString:""
###テキストにしてから
set strTextM to ocidTextM as text
###数値に
set strResponse to strTextM as number

##############################
#####計算部
##############################
set strResponse to (strResponse / 10) as number
set numVar to 2.54 as number

###そのまま
set numRaw to (strResponse / (numVar / 144)) as number
set strMes to ("計算結果です:" & strResponse & "mm →" & numRaw & "px　　\r") as text
log numRaw
###整数切り捨て
set intDown to (round of (numRaw) rounding down) as integer
log intDown
set strMes to (strMes & "整数切捨:" & intDown & "\r") as text
###整数切り上げ
set intUP to (round of (numRaw) rounding up) as integer
log intUP
set strMes to (strMes & "整数切上:" & intUP & "\r") as text
###切り捨て　小数点２
set num2Dec to ((round of ((numRaw) * 100) rounding down) / 100) as number
log num2Dec
set strMes to (strMes & "小数点２位:" & num2Dec & "\r") as text
###切り捨て　小数点3
set num3Dec to ((round of ((numRaw) * 1000) rounding down) / 1000) as number
log num3Dec
set strMes to (strMes & "小数点3位:" & num3Dec & "\r") as text
###切り捨て　小数点4
set num4Dec to ((round of ((numRaw) * 10000) rounding down) / 10000) as number
log num4Dec
set strMes to (strMes & "小数点4位:" & num4Dec & "\r") as text
####
set strMes to (strMes & "小数点以下計算は切り捨て\r【留意】ピクセル指定時には『整数』が必要です") as text


##############################
#####ダイアログ
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
try
	set recordResult to (display dialog strMes with title strMes default answer numRaw buttons {"クリップボードにコピー", "キャンセル", "再実行"} default button "再実行" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "エラーしました"
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
###自分自身を再実行
if button returned of recordResult is "再実行" then
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe
end if
##############################
#####値のコピー
##############################
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
