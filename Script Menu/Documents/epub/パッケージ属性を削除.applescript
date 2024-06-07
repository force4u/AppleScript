#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ibookが付与する属性を削除して
# パッケージではなく　フォルダにします
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
############UTIリスト
set listUTI to {"com.apple.ibooks.epub", "com.apple.application-bundle", "public.folder","public.item"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	##	アプリケーション選択時
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles without multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
#削除するアトリビュートのリスト
set listAttr to {"com.apple.quarantine", "com.apple.lastuseddate#PS", "com.apple.iBooks.title#S", "com.apple.iBooks.isSupplementalContent#S", "com.apple.iBooks.generation#S", "com.apple.iBooks.author#S", "com.apple.iBooks.assetID#S", "com.apple.fileprovider.fpfs#P", "com.apple.quarantine", "com.apple.FinderInfo", "com.apple.macl"} as list
#ファイル順に
repeat with itemAliasFilePath in listAliasFilePath
	#パスにして
	set strFilePath to (POSIX path of itemAliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidDirPathURL to ocidFilePathURL's URLByDeletingPathExtension()
	#パスに対して全てのアトリビュートの削除を試みる
	repeat with itemAttr in listAttr
		set strCommandText to ("/usr/bin/xattr -d \"" & itemAttr & "\" \"" & strFilePath & "\"") as text
		try
			do shell script strCommandText
		end try
	end repeat
	
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listDone to (appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidDirPathURL) |error|:(reference))
	if (item 1 of listDone) is true then
		log "正常処理"
	else if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s code() as text
		log (item 2 of listDone)'s localizedDescription() as text
		log strFilePath & ":エラーしました"
	end if
	
	
	
end repeat
