#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argFilePathAndNo)
	if (argFilePathAndNo as text) is "" then
		log doPrintHelp()
		return 0
	else if (argFilePathAndNo as text) is "-h" then
		log doPrintHelp()
		return 0
	else if (count of argFilePathAndNo) = 1 then
		set argFilePath to argFilePathAndNo as text
		set ocidFilePathStr to current application's NSString's stringWithString:(argFilePath)
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
		set listResult to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLLabelNumberKey) |error|:(reference)
		if (item 1 of listResult) is true then
			return (item 2 of listResult as text)
		else if (item 1 of listResult) is false then
			set strErrorNO to (item 2 of listDone)'s code() as text
			set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
			current application's NSLog("■：" & strErrorNO & " : " & strErrorMes)
			return ("■：" & strErrorNO & " : " & strErrorMes)
		end if
		
	else if (count of argFilePathAndNo) = 2 then
		#ARGをリストに分割
		set {argFilePath, argNo} to argFilePathAndNo
		set strNo to argNo as text
		set ocidNoString to current application's NSString's stringWithString:(strNo)
		set ocidDemSet to current application's NSCharacterSet's characterSetWithCharactersInString:("01234567")
		set ocidCharSet to ocidDemSet's invertedSet()
		set ocidOption to (current application's NSLiteralSearch)
		set ocidRange to ocidNoString's rangeOfCharacterFromSet:(ocidCharSet) options:(ocidOption)
		set ocidLocation to ocidRange's location() as text
		if ocidLocation ≠ "9.223372036855E+18" then
			return "設定値以外の値があったの中止"
		else
			set numNo to strNo as integer
		end if
		set ocidFilePathStr to current application's NSString's stringWithString:(argFilePath)
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
		#
		set ocidLabelNo to current application's NSNumber's numberWithInteger:(numNo)
		set listResult to (ocidFilePathURL's setResourceValue:(ocidLabelNo) forKey:(current application's NSURLLabelNumberKey) |error|:(reference))
		if (item 1 of listResult) is true then
			return 0
		else if (item 1 of listResult) is false then
			set strErrorNO to (item 2 of listDone)'s code() as text
			set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
			current application's NSLog("■：" & strErrorNO & " : " & strErrorMes)
			return ("■：" & strErrorNO & " : " & strErrorMes)
		end if
	end if
	return 0
end run
on doPrintHelp()
	set strHelpText to ("
指定したファイルパスにラベルを設定します
使用方法:
setlabel.applescript /パス/ファイル　またはフォルダ　で現在の設定値
setlabel.applescript /パス/ファイル ラベル番号　で指定の番号でラベル設定
例:
setlabel.applescript　/some/dir/some/file
setlabel.applescript　/some/dir/some/file 7

ラベル番号（objcなので逆順です）
0:ラベル無し
1:グレー
2:グリーン
3:パープル
4:ブルー
5:イエロー
6:レッド
7:オレンジ

") as text
	return strHelpText
end doPrintHelp