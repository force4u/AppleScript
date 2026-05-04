#!/usr/bin/env osascript
#coding: utf-8
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
SF Symbolsシンボル名チェッカー
SF Symbol name checker


SFSymbols.frameworkからシンボル名を収集取得して
シンボル名として、収集したシンボル名に含まれていれば
シンボル名として正しい　と簡易に判定します

Collect and obtain the symbol name from SFSymbols.framework 
and simply determine that 
if it is included in the collected symbol name as a symbol name
it is correct as a symbol name

CoreGlyphs.bundleとCoreGlyphsPrivate.bundle
両方を対象にしました targeted both

v1 初回作成
v1.1 macOS26動作確認



license
https://creativecommons.org/publicdomain/zero/1.0/legalcode.ja

com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions


set strChkSymbolName to ("apple.logo") as text
set boolChkOK to doChkSymbolName(strChkSymbolName)
if boolChkOK is true then
	log "Chk OK: " & strChkSymbolName & ""
end if

set strChkSymbolName to ("apple.xxxx") as text
set boolChkOK to doChkSymbolName(strChkSymbolName)
if boolChkOK is false then
	log "Chk NG: " & strChkSymbolName & ""
end if


##########################################
#SF Symbol name checker
to doChkSymbolName(argNameString)
	#チェック用のArray
	set ocidSymbolsArray to current application's NSMutableArray's alloc()'s init()
	#PLISTのパス
	set listPlistFilePath to {"/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources/name_availability.plist", "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphsPrivate.bundle/Contents/Resources/name_availability.plist"} as list
	repeat with itemPlistFilePath in listPlistFilePath
		#パス path
		set strPlistFilePath to (itemPlistFilePath) as text
		set ocidFilePathStr to (current application's NSString's stringWithString:(strPlistFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePath to ocidFilePath's stringByExpandingTildeInPath()
		set ocidFilePathURL to (current application's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false))
		#PLISTをDICTで読み込んで
		#Load PLIST with DICT
		set listResponse to (current application's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference))
		set ocidPlistDict to (first item of listResponse)
		set ocidItemSymbolsDict to (ocidPlistDict's objectForKey:("symbols"))
		set ocidAllKeys to ocidItemSymbolsDict's allKeys()
		#キーの値を格納する
		#Store the value of the key
		(ocidSymbolsArray's addObjectsFromArray:(ocidAllKeys))
	end repeat
	#チェック check
	#含まれていれば　シンボル名が正しいと判定します
	#If it is included, it is determined that the symbol name is correct.
	set boolContain to ocidSymbolsArray's containsObject:(argNameString)
	#戻し値はBOOL
	#The return value is BOOL
	if boolContain is false then
		return false as boolean
	else if boolContain is true then
		return true as boolean
	end if
	
end doChkSymbolName

