#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#ファイルの表示を切り替えます
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appFileManager to refMe's NSFileManager's defaultManager()

#####設定項目
set strPlistFileName to "com.apple.finder.plist" as text

##############################################
## Boolean属性の事前定義
##############################################
-->false = 0
set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
-->true = 1
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue

################
##  ファイルパス関連
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidPreferencesURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences")
set ocidPlistFilePathURL to ocidPreferencesURL's URLByAppendingPathComponent:(strPlistFileName)
################
##  NSDATAに読み込む
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
if (item 2 of listReadData) = (missing value) then
	set coidReadData to (item 1 of listReadData)
	log "正常終了: NSDATA"
else
	log (item 2 of listReadData)'s localizedDescription() as text
	return " ファイルの読み込みに失敗しました"
end if

################
##  ファイル読み込み
##可変DICTに変換
#バイナリーモード
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
#可変DICTにする
set ocidOption to (refMe's NSPropertyListMutableContainers)
#シリアライゼーション
set listReadPlistDict to refMe's NSPropertyListSerialization's propertyListWithData:(coidReadData) options:(ocidOption) format:(ocidFormat) |error|:(reference)
if (item 2 of listReadPlistDict) = (missing value) then
	log "正常終了: NSPropertyListSerialization"
	set ocidReadPlistDict to (item 1 of listReadPlistDict)
else
	log (item 2 of listReadPlistDict)'s localizedDescription() as text
	return "Plist変換に失敗しました"
end if
set numCntAllKey to ocidReadPlistDict's allKeys()
if (count of numCntAllKey) < 1 then
	return "Plistの内容が不正です"
end if
##set boolDone to (refMe's NSPropertyListSerialization's propertyList:ocidPlistDict isValidForFormat:(refMe's NSPropertyListBinaryFormat_v1_0))
##set boolDone to (refMe's NSPropertyListSerialization's propertyList:ocidPlistDict isValidForFormat:(refMe's NSPropertyListXMLFormat_v1_0))
set boolDone to (refMe's NSPropertyListSerialization's propertyList:(ocidReadPlistDict) isValidForFormat:(refMe's NSPropertyListOpenStepFormat))

if boolDone is true then
	return "読み込んだデータのフォーマットが不正です-->OPEN STEP形式です"
end if

################
##  現在の値は？
set ocidAppleShowAllFilesValue to ocidReadPlistDict's valueForKey:"AppleShowAllFiles"
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias
if ocidAppleShowAllFilesValue = (missing value) then
	log "現在の設定は未設定=FALSE"
	display dialog "不可視ファイルを表示します" buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath
	set boolSetValue to ocidTrue
else if ocidAppleShowAllFilesValue is ocidTrue then
	log "現在の設定はTRUE"
	display dialog "不可視ファイルを隠します" buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath
	set boolSetValue to ocidFalse
else if ocidAppleShowAllFilesValue is ocidFalse then
	log "現在の設定はFALSE"
	display dialog "不可視ファイルを表示します" buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath
	set boolSetValue to ocidTrue
end if
################
## 値の変更
ocidReadPlistDict's setValue:(boolSetValue) forKey:("AppleShowAllFiles")

################
##書き込み
set listDone to ocidReadPlistDict's writeToURL:(ocidPlistFilePathURL) |error|:(reference)
if (item 2 of listDone) = (missing value) then
	log "ファイルの保存終了: writeToURL"
	
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "ファイルの保存に失敗しました"
end if

if (item 1 of listDone) is true then
	log "正常終了"
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "失敗しました"
end if

################
## Finderを再起動
set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder")
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
	delay 2
	set ocidAppListArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder")
	set ocidAppPathURL to doGetBundleID2AppURL("com.apple.finder")
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id "com.apple.finder") as alias
				set strAppPath to (POSIX path of aliasAppApth) as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	#
	set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
	(ocidOpenConfig's setActivates:(ocidTrue))
	##
	(activate (appWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)))
end if
tell application id "com.apple.finder" to activate

return "処理終了"

###################################
### バンドルIDからアプリケーションURL
###################################
to doGetBundleID2AppURL(argBundleID)
	set strBundleID to argBundleID as text
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのURLを取得
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
				set strAppPath to (POSIX path of aliasAppApth) as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetBundleID2AppURL