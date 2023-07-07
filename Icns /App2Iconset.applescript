#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidAppDirPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidAppDirPathURL's absoluteURL()) as alias
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
set listUTI to {"com.apple.application-bundle"}
set strMes to ("アプリケーションを選んでください") as text
set strPrompt to ("アプリケーションを選んでください") as text
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI without invisibles, showing package contents and multiple selections allowed) as alias
###
set strAppPath to POSIX path of aliasFilePath as text
###URL
set ocidAppPathStr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()
set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:true)
###保存ディレクトリ名iconsetを生成
set ocidBaseDirPath to ocidAppPath's stringByDeletingPathExtension()
set ocidDirName to ocidBaseDirPath's lastPathComponent()
set ocidSaveDirName to ocidDirName's stringByAppendingPathExtension:("iconset")
###保存先
set ocidURLDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLDirPathArray's firstObject()
set ocidSaveDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(ocidSaveDirName)
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
set strSaveDirPath to ocidSaveDirPathURL's |path| as text


###アイコン=ICNSがあるか？確認する
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
set ocidInfoDict to ocidAppBundle's infoDictionary
###バンドるからICONファイル名を取り出して
set strIconFileName to (ocidInfoDict's valueForKey:("CFBundleIconFile")) as text
set strComponent to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strComponent) isDirectory:false
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
###拡張子無しならつける
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
###パス
set ocidIconFilePath to ocidIconFilePathURL's |path|
###ICONファイルが実際にあるか？チェック
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePath)
if boolExists is false then
	###Assets.carの有無チェック
	set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Resources/Assets.car") isDirectory:false
	set strFilePath to ocidFilePathURL's |path|() as text
	set boolExists to appFileManager's fileExistsAtPath:(ocidFilePathURL's |path|())
	if boolExists is false then
		###iOSアプリの場合
		set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("WrappedBundle/Assets.car") isDirectory:false
		set strFilePath to ocidFilePathURL's |path|() as text
		set boolExists to appFileManager's fileExistsAtPath:(ocidFilePathURL's |path|())
		if boolExists is true then
			try
				###AppIcon以外が指定されている場合は取れないけどね
				set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" AppIcon -o \"" & strSaveDirPath & "\"") as text
				do shell script strCommandText
			end try
		else
			return "アイコンデータが見つかりませんでした"
			return "Assets.carデータが見つかりませんでした"
		end if
	end if
	try
		###AppIcon指定時
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" AppIcon -o \"" & strSaveDirPath & "\"") as text
		do shell script strCommandText
	on error
		###システム設定の指定例
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" PrefApp -o \"" & strSaveDirPath & "\"") as text
		do shell script strCommandText
	end try
else
	###ICNSからの書き出し
	set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & (ocidIconFilePath as text) & "\" -o \"" & (strSaveDirPath as text) & "\"") as text
	do shell script strCommandText
end if

##念の為Assets.carがある場合は書き出しトライしてみる
set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Resources/Assets.car") isDirectory:false
set strFilePath to ocidFilePathURL's |path|() as text
set boolExists to appFileManager's fileExistsAtPath:(ocidFilePathURL's |path|())
if boolExists is true then
	try
		###AppIcon指定時
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" AppIcon -o \"" & strSaveDirPath & "\"") as text
		do shell script strCommandText
	end try
else
	###iOSアプリの場合
	set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("WrappedBundle/Assets.car") isDirectory:false
	set strFilePath to ocidFilePathURL's |path|() as text
	set boolExists to appFileManager's fileExistsAtPath:(ocidFilePathURL's |path|())
	if boolExists is true then
		try
			set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" AppIcon -o \"" & strSaveDirPath & "\"") as text
			do shell script strCommandText
		end try
	end if
end if

return






