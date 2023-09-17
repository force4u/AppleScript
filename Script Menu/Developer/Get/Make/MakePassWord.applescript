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
###ダイアログを前に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/LockedIcon.icns"
set strMes to ("桁数指定してください")
set numDeg to (13) as integer
set recordResult to (display dialog strMes with title "入力してください" default answer numDeg buttons {"キャンセル", "記号あり", "記号なし"} default button "記号あり" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
###ボタンによる分岐
if button returned of recordResult is "記号なし" then
	set strText to text returned of recordResult as text
	set strCharSet to "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789"
else if button returned of recordResult is "記号あり" then
	set strText to text returned of recordResult as text
	set strCharSet to "abcdefghijklmnopqrstuvwxyz0123456789@#$%&!¥=+?_-ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&!¥=+?_-"
else
	return "キャンセルしました"
end if
###不要な文字の除去
set ocidResponseText to (refMe's NSString's stringWithString:(strText))
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
set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
set ocidCharSet to ocidDecSet's invertedSet()
set ocidCharArray to ocidTextM's componentsSeparatedByCharactersInSet:(ocidCharSet)
set ocidInteger to ocidCharArray's componentsJoinedByString:""
###ボタンによる文字数の違いを数える
set numCntCharSet to (count of character of strCharSet) as integer
###出力用テキスト初期化
set strOutPutText to ("") as text
###パスワードは８コ生成する
repeat 8 times
	###パスワード用文字列の初期化
	set strLineText to ("") as text
	###指定の文字数分くりかえし
	repeat (ocidInteger as integer) times
		###ランダム番号から
		set numRandomNo to (random number from 1 to numCntCharSet) as integer
		###ランダム番号の文字列を取り出して
		set strTmp to character numRandomNo of strCharSet
		###繋げてパスワード用の文字列とする
		set strLineText to (strLineText & strTmp) as text
	end repeat
	###パスワード用の文字列毎に改行を入れて
	set strLineText to (strLineText & "\n") as text
	###出力用テキストにする
	set strOutPutText to (strOutPutText & strLineText) as text
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
###ダイアログ
set strIconPath to "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
set aliasIconPath to POSIX file strIconPath as alias
set recordResult to (display dialog "戻り値" with title "戻り値です" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
