#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSCharacterSet : a reference to refMe's NSCharacterSet
property refNSMutableString : a reference to refMe's NSMutableString
property refNSArray : a reference to refMe's NSArray
property refNSMutableArray : a reference to refMe's NSMutableArray

########################
########設定項目
########################
####行番号と本文を区切る文字を指定
set strLineNoSeparator to "\t" as text
(* 例
set strLineNoSeparator to ":" as text
set strLineNoSeparator to "," as text
*)

########################
########テキスト取得
########################
####前面ドキュメントのテキストを取得
tell application "Jedit Ω"
	tell front document
		set strText to text of it
	end tell
end tell
########################
########本処理
########################
###String
set ocidText to refNSString's stringWithString:strText
###改行コードで区切り
set ocidChrSet to refNSCharacterSet's newlineCharacterSet()
####入力テキスト用のリスト
set ocidTextArray to refNSMutableArray's alloc()'s initWithCapacity:0
####出力用テキスト用のリスト
set ocidOutPutTextArray to refNSMutableArray's alloc()'s initWithCapacity:0
####改行区切りでリスト化
set ocidTextArray to ocidText's componentsSeparatedByCharactersInSet:ocidChrSet
####リストの数
set numCntArray to (count of ocidTextArray) as integer
####行カウント
set numCntLineNO to 1
####行データ分繰り返し
repeat with itemTextArray in ocidTextArray
	####テキスト確定
	set strLineText to itemTextArray as text
	####行番号をゼロサプレスで生成
	set strLineNo to zeroPadding(numCntLineNO, numCntArray) as text
	####戻すテキストを整形
	set strNewLineText to (strLineNo & strLineNoSeparator & strLineText) as text
	####出力用リストに戻す
	(ocidOutPutTextArray's addObject:strNewLineText)
	####カウントUP
	set numCntLineNO to numCntLineNO + 1 as integer
end repeat
####出力用のリストを項目毎に改行入れてテキストに
set ocidOutPutText to ocidOutPutTextArray's componentsJoinedByString:"\n"
####出力用のテキストで確定
set strOutPutText to ocidOutPutText as text
########################
########テキストを戻す
########################
####新規ドキュメントを作ってテキストを戻す
tell application "Jedit Ω"
	make new document with properties {encoding:"Unicode (UTF-8)", line endings:LF}
	tell front document
		set selected text to strOutPutText
	end tell
end tell
########################
########ゼロサプレス
########################
on zeroPadding(argNo, argMaxNum)
	set numString to (argNo as integer) as string
	set numMaxDigit to length of (argMaxNum as string)
	set numDigit to length of numString
	repeat while numDigit < numMaxDigit
		set numString to "0" & numString
		set numDigit to numDigit + 1
	end repeat
	return numString
end zeroPadding
