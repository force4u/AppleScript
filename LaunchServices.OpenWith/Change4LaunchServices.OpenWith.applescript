#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ファイルを開く時のデフォルトのアプリケーションを書類毎に設定します
# アプリケーションを選択
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()


###################################
#####入力ダイアログ
###################################
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
set listUTI to {"public.data"} as list
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
set strPromptText to "ファイルを選んでください" as text
set strMesText to "ファイルを選んでください" as text
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTI with invisibles and multiple selections allowed without showing package contents) as list

###################################
#####ダイアログ
###################################a
###デフォルトロケーション(ユーザーアプリケーション)
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppDirPathURL to ocidForDirArray's firstObject()
set ocidAppDirPath to ocidAppDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidAppDirPath) isDirectory:(true)
##なければ作る
if boolDirExists = false then
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidAppDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
end if

set aliasDefaultLocation to (ocidAppDirPathURL's absoluteURL()) as alias

set listChooseFileUTI to {"com.apple.application-bundle", "com.apple.bundle"}

set strPromptText to "関連付けるアプリケーションを選んでください" as text
set strMesText to "関連付けるアプリケーションを選んでください" as text

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
set aliasAppPath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles without multiple selections allowed and showing package contents) as alias

###################################
#####パス処理
###################################
set strAppPath to POSIX path of aliasAppPath as text
set ocidAppPathstr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathstr's stringByStandardizingPath()
set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:(true)
###バンドルID取得
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
set ocidBundleID to ocidAppBundle's bundleIdentifier()

###################################
#####PLIST作成
###################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(ocidBundleID) forKey:("bundleidentifier")
ocidPlistDict's setValue:(ocidAppPathstr) forKey:("path")
set ocidVersionNo to (refMe's NSNumber's numberWithInteger:0)
ocidPlistDict's setValue:(ocidVersionNo) forKey:("version")
###書き込み用にバイナリーデータに変換
set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
set listPlistEditData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidNSbplist) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditData
###PLIST保存先
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
end tell
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:(false)
set ocidContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
##PLISTを保管するためのディレクトリ
set ocidPlistSaveDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("Plist")
set ocidPlistSaveDirPath to ocidPlistSaveDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistSaveDirPath) isDirectory:(true)
##なければ作る
if boolDirExists = false then
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidPlistSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
end if
###保存するファイル名
set strFileName to ((ocidBundleID as text) & ".plist") as text
###PLISTのパス
set ocidPlistFilePathURL to ocidPlistSaveDirPathURL's URLByAppendingPathComponent:(strFileName)
set strPlistFilePath to (ocidPlistFilePathURL's |path|()) as text
###PLIST 保存
set ocidOption to (refMe's NSDataWritingAtomic)
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
log item 1 of boolWritetoUrlArray

###################################
#####PLISTのHEXバイナリーを取得する
###################################
set strCommandText to ("/usr/bin/xxd -p -c 0  \"" & strPlistFilePath & "\"") as text
set strHexPlistData to (do shell script strCommandText)

###################################
#####ファイルの数だけ繰り返す
###################################
repeat with itemFilePath in listAliasFilePath
	set aliasFilePath to itemFilePath as alias
	set strAppendAttrFilePath to (POSIX path of aliasFilePath) as text
		try
		set strCommandText to ("/usr/bin/touch -a  \"" & strAppendAttrFilePath & "\"") as text
		do shell script strCommandText
		delay 0.2
		set strCommandText to ("/usr/bin/xattr -d com.apple.LaunchServices.OpenWith \"" & strAppendAttrFilePath & "\"") as text
		do shell script strCommandText
		delay 0.2
	on error
		try
			set strCommandText to ("/usr/bin/touch -a  \"" & strAppendAttrFilePath & "\"") as text
			do shell script strCommandText
			delay 0.2
			set strCommandText to ("/usr/bin/xattr -c com.apple.LaunchServices.OpenWith \"" & strAppendAttrFilePath & "\"") as text
			do shell script strCommandText
			delay 0.2
			set strCommandText to ("/usr/bin/xattr -w -x com.apple.LaunchServices.OpenWith nil \"" & strAppendAttrFilePath & "\"") as text
			do shell script strCommandText
			delay 0.2
		end try
	end try
	####
	set strCommandText to ("/usr/bin/xattr  -w -x  com.apple.LaunchServices.OpenWith \"" & strHexPlistData & "\" \"" & strAppendAttrFilePath & "\"") as text
	do shell script strCommandText
	delay 0.2
	set strCommandText to ("/usr/bin/touch -a  \"" & strAppendAttrFilePath & "\"") as text
	do shell script strCommandText
	delay 0.2
	set strCommandText to ("/usr/bin/xattr  -w -x com.apple.quarantine nil \"" & strAppendAttrFilePath & "\"") as text
	do shell script strCommandText
	delay 0.2
end repeat




