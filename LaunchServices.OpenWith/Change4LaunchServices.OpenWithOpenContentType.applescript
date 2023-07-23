#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ファイルを開く時のデフォルトのアプリケーションを書類毎に設定します
# ファイルの種類から　開くことが出来るアプリを関連付けます
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
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as list
set aliasFilePath to (item 1 of listAliasFilePath) as alias
set strAppendAttrFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strAppendAttrFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
####UTIの取得
set listResourceValue to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
set ocidContentType to (item 2 of listResourceValue)
set strUTI to (ocidContentType's identifier) as text
###missing value対策
if strUTI is "" then
	tell application "Finder"
		set objInfo to info for aliasFilePath
		set strUTI to type identifier of objInfo as text
	end tell
end if
################################
######パスを渡すことが可能なアプリのURL
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidURLArray to appShardWorkspace's URLsForApplicationsToOpenContentType:(ocidContentType)
###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidAppDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemURLArray in ocidURLArray
	###アプリケーションの名前
	set listResponse to (itemURLArray's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "名前は：" & strAppName & "です"
	copy strAppName to end of listAppName
	set listSerArray to {} as list
	####パス
	set aliasAppPath to itemURLArray's absoluteURL() as alias
	log "パスは：" & aliasAppPath & "です"
	####バンドルID取得
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemURLArray))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	set listSerArray to {itemURLArray, strBundleID} as list
	log "BunndleIDは：" & strBundleID & "です"
	(ocidAppDictionary's setObject:(listSerArray) forKey:(strAppName))
end repeat

###################################
#####ダイアログ
###################################a
###ダイアログを前面に
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
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "ファイルを開くアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text


################################
##URLを開く
################################
###アプリケーションのURLを取り出す
set listChooseApp to ocidAppDictionary's objectForKey:(strResponse)
set strOpenAppUTI to (item 2 of listChooseApp) as text
set ocidAppPathURL to (item 1 of listChooseApp)
set ocidAppPath to ocidAppPathURL's |path|()
###バンドルID取得
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
set ocidBundleID to ocidAppBundle's bundleIdentifier()

###################################
#####PLIST作成
###################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(ocidBundleID) forKey:("bundleidentifier")
ocidPlistDict's setValue:(ocidAppPath) forKey:("path")
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




