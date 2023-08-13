#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
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


tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell


##############################
###　フォルダ選択
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
try
	set strMes to "フォルダを選んでください" as text
	set strPrompt to "フォルダを選択してください" as text
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
set strDirPath to (POSIX path of aliasResponse) as text
####ドキュメントのパスをNSString
set ocidDirPath to refMe's NSString's stringWithString:(strDirPath)
####ドキュメントのパスをNSURLに
set ocidDirPathURL to refMe's NSURL's fileURLWithPath:(ocidDirPath)


##############################
###　アインコンデータ選択
set listUTI to {"public.image"}
set strMes to ("イメージファイルを選んでください") as text
set strPrompt to ("イメージファイルを選んでください") as text
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to (POSIX path of aliasFilePath) as text
####ドキュメントのパスをNSString
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
####ドキュメントのパスをNSURLに
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)

##############################
###アイコンデータ読み込み
set ocidIconData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL))
##############################
###フォルダにアイコン付与
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidDirPathURL's |path|) options:(refMe's NSExclude10_4ElementsIconCreationOption)





