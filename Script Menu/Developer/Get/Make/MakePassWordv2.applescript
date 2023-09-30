#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
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

set strText to text returned of recordResult as text
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
###数字以外の値を取る
set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
set ocidCharSet to ocidDecSet's invertedSet()
set ocidCharArray to ocidTextM's componentsSeparatedByCharactersInSet:(ocidCharSet)
set numInteger to (ocidCharArray's componentsJoinedByString:"") as integer
###４文字以下はここで止める
if numInteger < 4 then
	return "４文字以下はパスワードとは言いません"
end if

set numSetA to (round of (numInteger / 4) rounding up) as integer
set numTmp3 to numInteger - numSetA as integer
set numSetB to (round of (numTmp3 / 3) rounding down) as integer
set numTmp2 to numTmp3 - numSetB as integer
set numSetC to (round of (numTmp2 / 2) rounding down) as integer
set numSetD to numTmp2 - numSetC as integer

###ボタンによる分岐
if button returned of recordResult is "記号なし" then
	
	#	set strCharSetA to "abcdefghijklmnopqrstuvwxyz"
	##loijを使わないパターン
	set strCharSetA to "abcdefghkmnpqrstuvwxyz"
	#	set strCharSetB to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	##Oとiを使わないパターン
	set strCharSetB to "ABCDEFGHJKLMNPQRSTUVWXYZ"
	set strCharSetC to "0123456789"
	set strCharSetD to "abcdefghkmnpqrstuvwxyzABCDEFGHKMNPQRSTUVWXYZ23456789"
	
else if button returned of recordResult is "記号あり" then
	set strText to text returned of recordResult as text
	
	#	set strCharSetA to "abcdefghijklmnopqrstuvwxyz"
	##loijを使わないパターン
	set strCharSetA to "abcdefghkmnpqrstuvwxyz"
	#	set strCharSetB to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	##Oとiを使わないパターン
	set strCharSetB to "ABCDEFGHJKLMNPQRSTUVWXYZ"
	set strCharSetC to "0123456789"
	set strCharSetD to "@#$%&!¥=+?_-"
	
else
	return "キャンセルしました"
end if


###出力用テキスト初期化
set strOutPutText to ("") as text
###パスワードは８コ生成する
repeat 8 times
	###パスワード用文字列の初期化
	set strLineTextA to ("") as text
	repeat numSetA times
		###文字数を数えて
		set numCntCharSet to (count of character of strCharSetA) as integer
		###文字数内のランダム番号
		set numRandomNo to (random number from 1 to numCntCharSet) as integer
		###ランダム番号の文字列を取り出して
		set strTmp to character numRandomNo of strCharSetA
		###繋げてパスワード用の文字列とする
		set strLineTextA to (strLineTextA & strTmp) as text
	end repeat
	
	set strLineTextB to ("") as text
	repeat numSetB times
		###文字数を数えて
		set numCntCharSet to (count of character of strCharSetB) as integer
		###文字数内のランダム番号
		set numRandomNo to (random number from 1 to numCntCharSet) as integer
		###ランダム番号の文字列を取り出して
		set strTmp to character numRandomNo of strCharSetB
		###繋げてパスワード用の文字列とする
		set strLineTextB to (strLineTextB & strTmp) as text
	end repeat
	
	set strLineTextC to ("") as text
	repeat numSetC times
		###文字数を数えて
		set numCntCharSet to (count of character of strCharSetC) as integer
		###文字数内のランダム番号
		set numRandomNo to (random number from 1 to numCntCharSet) as integer
		###ランダム番号の文字列を取り出して
		set strTmp to character numRandomNo of strCharSetC
		###繋げてパスワード用の文字列とする
		set strLineTextC to (strLineTextC & strTmp) as text
	end repeat
	
	set strLineTextD to ("") as text
	repeat numSetD times
		###文字数を数えて
		set numCntCharSet to (count of character of strCharSetD) as integer
		###文字数内のランダム番号
		set numRandomNo to (random number from 1 to numCntCharSet) as integer
		###ランダム番号の文字列を取り出して
		set strTmp to character numRandomNo of strCharSetD
		###繋げてパスワード用の文字列とする
		set strLineTextD to (strLineTextD & strTmp) as text
	end repeat
	set strLineText to (strLineTextA & strLineTextB & strLineTextC & strLineTextD) as text
	set listLineText to every character of strLineText as list
	set ocidLineTextArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidLineTextArrayM's addObjectsFromArray:(listLineText)
	
	###指定の文字数分くりかえし
	set strLineOutPutText to "" as text
	###文字数を数えて
	set numCntLineText to (count of character of strLineText) as integer
	repeat
		###ランダム番号から
		set numRandomNo to (random number from 1 to numCntLineText) as integer
		##対象の場所の文字を抜いて
		set ocidOutPutTmp to ocidLineTextArrayM's objectAtIndex:(numRandomNo - 1)
		##その場所の文字は削除する
		ocidLineTextArrayM's removeObjectAtIndex:(numRandomNo - 1)
		##取り出した文字はテキストに
		set strLineOutPutText to (strLineOutPutText & (ocidOutPutTmp as text)) as text
		##１文字減ったのでランダム番号も変わる
		set numCntLineText to numCntLineText - 1 as integer
		###指定文字数で終了
		if numCntLineText = 0 then
			exit repeat
		end if
	end repeat
	###パスワード用の文字列毎に改行を入れて
	set strLineText to (strLineOutPutText & "\n") as text
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
