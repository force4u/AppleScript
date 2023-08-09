#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNotFound : a reference to 9.22337203685477E+18 + 5807


##ライブラリDIR
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
##ファイルURL
set ocidPlistFilePathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.apple.finder.plist")
####PLIST
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
set ocidViewDict to ocidPlistDict's objectForKey:"ViewSettingsDictionary"
set ocidKeyArray to ocidViewDict's allKeys()
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
##############################
###ダイアログ
##############################

###ダイアログを前面に出す
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
	set listResponse to (choose from list listTagName with title "選んでください" with prompt "削除するタグの名前を円欄でください" default items (item 1 of listTagName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set strResponse to (item 1 of listResponse) as text
set ocidTagName to refMe's NSString's stringWithString:(strResponse)



##############################
###ダイアログ
##############################
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strMes to ("フォルダを選んでください") as text
	set strPrompt to ("タグとインデックスラベルを削除します" & strName & "タグを付与します") as text
	set aliasTargetDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
#####
set strTargetDirPath to (POSIX path of aliasTargetDirPath) as text
set ocidTargetDirPathStr to refMe's NSString's stringWithString:(strTargetDirPath)
set ocidTargetDirPath to ocidTargetDirPathStr's stringByStandardizingPath()
set ocidTargetDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTargetDirPath) isDirectory:true)
###################################
###EMUモードでファイル収集
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidPropertyKeys to {(refMe's NSURLNameKey), (refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey), (refMe's NSURLLabelNumberKey), (refMe's NSURLTagNamesKey)}
###非表示ファイルは除外
set ocidOption to (refMe's NSDirectoryEnumerationSkipsHiddenFiles)
###最下層まで収集
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidTargetDirPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) errorHandler:(reference))
###収集したURLをArrayにする
set ocidEmuFileURLArray to ocidEmuDict's allObjects()

###################################
###収集したURLの数だけ繰り返し
###################################
repeat with itemEmuPathURL in ocidEmuFileURLArray
	log itemEmuPathURL's |path|() as text
	set listResult to (itemEmuPathURL's getResourceValue:(reference) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
	set ocidTagArray to (item 2 of listResult)
	if ocidTagArray = (missing value) then
		log "タグは設定されていない"
	else if ocidTagArray ≠ (missing value) then
		##すでにあるか？確認
		set boolContain to (ocidTagArray's containsObject:(ocidTagName))
		if boolContain is true then
			(ocidTagArray's removeObject:(ocidTagName))
			set listDone to (itemEmuPathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		else if boolContain is false then
			##タグがない場合は何もしない
		end if
	end if
	
end repeat
