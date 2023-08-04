#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

####################################
###ユーザーアプリケーションフォルダ
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
log className() of ocidURLArray as text
set ocidApplicationDirPathURL to ocidURLArray's firstObject()
set aliasDefaultLocation to (ocidApplicationDirPathURL's absoluteURL()) as alias
set ocidLocalizedPathURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:(".localized")
###フォルダなければ作る 488 = 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolDone to appFileManager's createDirectoryAtURL:(ocidApplicationDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###localizedの空ファイルも作る
set ocidLocalizedPath to ocidLocalizedPathURL's |path|()
set listBoolDone to appFileManager's createFileAtPath:(ocidLocalizedPath) |contents|:(missing value) attributes:(ocidAttrDict)
####################################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listUTI to {"com.apple.application-bundle"}
set strPromptText to "アプリケーションを選んでください" as text
set strPromptMes to "アプリケーションを選んでください" as text
set aliasFilePath to (choose file (strPromptMes) with prompt (strPromptText) default location (aliasDefaultLocation) of type (listUTI) with invisibles without multiple selections allowed and showing package contents) as alias
###追加するパス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePath to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePath's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true

################################
####Plist読み込み
################################
###URL
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLArray's firstObject()
set ocidPlistPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences/com.apple.dock.plist")
###読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
################################
####インサート位置
################################
set ocidPersistentArray to ocidPlistDict's objectForKey:"persistent-apps"
set numCntArray to ocidPersistentArray's |count|() as integer
################################
##作ったけど使わなかったDict
set ocidPersistentDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listInsertPosision to {} as list
repeat with numNo from 0 to (numCntArray - 1) by 1
	set coidItemDict to (ocidPersistentArray's objectAtIndex:(numNo))
	set strLabel to (coidItemDict's valueForKeyPath:"tile-data.file-label") as text
	set recordAddRec to (run script "return  {|" & numNo & "|:\"" & strLabel & "\"} ") as record
	(ocidPersistentDict's addEntriesFromDictionary:recordAddRec)
	##テキストにして
	set strAddList to ("" & numNo & ":" & strLabel & "") as text
	##リストに追加
	set end of listInsertPosision to strAddList
end repeat
####
log listInsertPosision as list
try
	set listResponse to (choose from list listInsertPosision with title "選んでください" with prompt "挿入位置\r選んだ項目の『後(右)』に挿入されます" default items (item 1 of listInsertPosision) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strInsertPosision to (item 1 of listResponse) as text
set AppleScript's text item delimiters to ":"
set listItemInsertPosision to every text item of strInsertPosision
set AppleScript's text item delimiters to ""
set numInsertPosision to (item 1 of listItemInsertPosision) as integer

################################
####persistent-appsデータ生成
################################
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###GUID実際はランダム番号だがNSFileSystemFileNumberを使う
set listPathAttar to appFileManager's attributesOfItemAtPath:(ocidFilePath) |error|:(reference)
set ocidAttar to item 1 of listPathAttar
set numGUID to ocidAttar's valueForKey:(refMe's NSFileSystemFileNumber)
set ocidIntValue to (refMe's NSNumber's numberWithInteger:(numGUID))
ocidAddDict's setValue:(numGUID) forKey:("GUID")
###
set ocidStringValue to (refMe's NSString's stringWithString:("file-tile"))
ocidAddDict's setValue:(ocidStringValue) forKey:("tile-type")
################################
set ocidAddTitleDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####dock-extra
set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
ocidAddTitleDataDict's setValue:(ocidBoolValue) forKey:("dock-extra")
####dock-extra
set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
ocidAddTitleDataDict's setValue:(ocidBoolValue) forKey:("is-beta")
####bundle-identifier
set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(ocidFilePathURL))
set ocidBunndleID to ocidAppBunndle's bundleIdentifier
set ocidStringValue to ocidBunndleID's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("bundle-identifier")
####file-label"
set listAttributesDict to ocidFilePathURL's resourceValuesForKeys:({refMe's NSURLLocalizedNameKey}) |error|:(reference)
set ocidAttributesDict to (item 1 of listAttributesDict)
set ocidLocalizedName to (ocidAttributesDict's objectForKey:(refMe's NSURLLocalizedNameKey))
set ocidFileLabel to (ocidLocalizedName's stringByDeletingPathExtension())
set ocidStringValue to ocidFileLabel's UTF8String()
ocidAddTitleDataDict's setValue:(ocidStringValue) forKey:("file-label")
####file-mod-date
set listAttributesDict to ocidFilePathURL's resourceValuesForKeys:({refMe's NSURLContentModificationDateKey}) |error|:(reference)
set ocidAttributesDict to (item 1 of listAttributesDict)
set ocidModificationDate to (ocidAttributesDict's objectForKey:(refMe's NSURLContentModificationDateKey))
set ocidModDate to ocidModificationDate's timeIntervalSince1970
set ocidIntValue to ocidModDate's intValue()
ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("file-mod-date")
####parent-mod-date
set ocidNow to refMe's NSDate's now
set ocidNowNo to ocidNow's timeIntervalSince1970
set ocidIntValue to ocidNowNo's intValue
ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("parent-mod-date")
####book
set listBookMarkData to (ocidFilePathURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidkDataValue to item 1 of listBookMarkData
(ocidAddTitleDataDict's setObject:(ocidkDataValue) forKey:("book"))
####file-type
#	169		Launchpad とMission Control
#	41			それ以外はまぁ４１で間違いなさそう
set ocidIntValue to (refMe's NSNumber's numberWithInteger:41)
(ocidAddTitleDataDict's setValue:(ocidIntValue) forKey:("file-type"))
################################
set ocidAddFileDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set coidAbsoluteStringPath to ocidFilePathURL's absoluteString()
(ocidAddFileDataDict's setValue:(coidAbsoluteStringPath) forKey:("_CFURLString"))
####
#		0	/File/Path
#		15 file:// のURL形式
set ocidIntValue to (refMe's NSNumber's numberWithInteger:15)
(ocidAddFileDataDict's setValue:(ocidIntValue) forKey:("_CFURLStringType"))
################################
(ocidAddTitleDataDict's setObject:(ocidAddFileDataDict) forKey:("file-data"))
ocidAddDict's setObject:(ocidAddTitleDataDict) forKey:("tile-data")
################################
####追加データを元のPLISTに戻す
################################
set numSetPosition to (numInsertPosision + 1) as integer
ocidPersistentArray's insertObject:(ocidAddDict) atIndex:(numSetPosition)

################################
####保存
################################
set boolDone to ocidPlistDict's writeToURL:(ocidPlistPathURL) atomically:true

################################
###CFPreferencesを再起動
################################
#####CFPreferencesを再起動させて変更後の値をロードさせる
try
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
on error
	set strPlistPath to "/System/Library/LaunchAgents/com.apple.cfprefsd.xpc.agent.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try (*
	set strPlistPath to "/System/Library/LaunchDaemons/com.apple.cfprefsd.xpc.daemon.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	*)
end try

set strCommandText to ("/usr/bin/killall Dock")
do shell script strCommandText

