#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##############################
###ダイアログを前面に
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###アイコン
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias
###デフォルト値
set strDefaultAnswer to "755" as text
###メッセージ
set strText to "777-->511n775-->509n770-->504n755-->493n750-->488n700-->448n555-->365n333-->219"
###ダイアログ
try
	set recordResponse to (display dialog strText with title "３桁８進数を入力" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if

###テキストに
set ocidResponseText to (refMe's NSString's stringWithString:(strResponse))
####戻り値を半角にする
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidResponseHalfwidth to (ocidResponseText's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
###数字以外の値を取る
set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
set ocidCharSet to ocidDecSet's invertedSet()
set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
set ocidInteger to ocidCharArray's componentsJoinedByString:""
set intResponse to ocidInteger as integer

###本処理
set strDem to doOct2Dem(intResponse)

##############################
###ダイアログを前面に
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログに戻す
set strMes to "計算結果ですrr(current application)'s NSNumber's numberWithInteger:(" & strDem & ") n"
try
	set recordResult to (display dialog strMes with title strMes default answer strDem buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "エラーしました"
	return
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
###################################
#####パーミッション　８進→１０進
###################################

to doOct2Dem(argOctNo)
	set strOctalText to argOctNo as text
	set num3Line to first item of strOctalText as number
	set num2Line to 2nd item of strOctalText as number
	set num1Line to last item of strOctalText as number
	set numDecimal to (num3Line * 64) + (num2Line * 8) + (num1Line * 1)
	return numDecimal
end doOct2Dem

