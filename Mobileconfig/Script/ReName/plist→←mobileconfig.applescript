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


on run
	###ドロップレットWクリック時にはファイル選択ダイアログを出す
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else if strName is (name of me as text) then
		set strName to (name of me) as text
		tell application strName to activate
	else
		tell current application to activate
	end if
	###デフォルトロケーションはデスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
	set strMes to "選んでください"
	set listUTI to {"com.apple.property-list", "com.apple.mobileconfig", "public.xml"} as list
	set listAliasFilePath to (choose file strMes default location aliasDesktopDirPath with prompt strMes of type listUTI with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasFilePath
	
end run

on open listAliasFilePath
	repeat with itemAliasFilePath in listAliasFilePath
		##パスをURLに
		set aliasItemPath to itemAliasFilePath as alias
		set strItemPath to (POSIX path of aliasItemPath) as text
		set ocidItemPathStr to (refMe's NSString's stringWithString:(strItemPath))
		set ocidItemPath to ocidItemPathStr's stringByStandardizingPath()
		set ocidItemPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidItemPath))
		##ベースファイルパス
		set ocidBaseFilePathURL to ocidItemPathURL's URLByDeletingPathExtension()
		##拡張子
		set strExtensionName to (ocidItemPathURL's pathExtension()) as text
		###拡張子で分岐
		if strExtensionName is "plist" then
			set strNewExtension to ("mobileconfig") as text
		else if strExtensionName is "mobileconfig" then
			set strNewExtension to ("plist") as text
		else if strExtensionName is "xml" then
			set strNewExtension to ("mobileconfig") as text
		end if
		###
		set ocidNewFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:(strNewExtension))
		###リネーム
		set appFileManager to refMe's NSFileManager's defaultManager()
		set listDone to (appFileManager's moveItemAtURL:(ocidItemPathURL) toURL:(ocidNewFilePathURL) |error|:(reference))
		log item 1 of listDone
	end repeat
	
end open