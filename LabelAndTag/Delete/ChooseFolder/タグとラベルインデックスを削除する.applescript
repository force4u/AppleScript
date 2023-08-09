#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　選択したフォルダ内のすべての　フォルダとファイルで
#　フォルダ内最下層まで
#　ラベル　と　タグ　を削除します
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
	
	##ラベルとタグを除去する
	set listDone to (itemEmuPathURL's setResourceValue:(missing value) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
	set listDone to (itemEmuPathURL's setResourceValue:(0) forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
	
	
end repeat
