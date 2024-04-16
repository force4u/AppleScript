#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
デスクトップ上にあるファイルやフォルダの
アイコンを表示するか？切り替えます
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


#####設定項目
set strPlistFileName to "com.apple.finder.plist" as text

##############################################
## ファイルパス関連
##############################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
####ファイル名を付与したURL
set ocidPrefDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences") isDirectory:(true)
set ocidPlistFilePathURL to ocidPrefDirPathURL's URLByAppendingPathComponent:(strPlistFileName) isDirectory:(false)
##############################################
## 本処理
##############################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0

####ファイル読み込み
set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
set ocidNSErrorData to item 2 of listReadPlistData
if ocidNSErrorData is not (missing value) then
	doGetErrorData(ocidNSErrorData)
end if


##############################################
## Plistの種類を調べる
##############################################

##set boolDone to (refMe's NSPropertyListSerialization's propertyList:ocidPlistDict isValidForFormat:(refMe's NSPropertyListBinaryFormat_v1_0))
##set boolDone to (refMe's NSPropertyListSerialization's propertyList:ocidPlistDict isValidForFormat:(refMe's NSPropertyListXMLFormat_v1_0))
set boolDone to (refMe's NSPropertyListSerialization's propertyList:(ocidPlistDict) isValidForFormat:(refMe's NSPropertyListOpenStepFormat))

if boolDone is true then
	return "読み込んだデータのフォーマットが不正です-->OPEN STEP形式です"
end if

set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0

##############################################
##現在の値を取得する
##############################################
-->false
set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
-->true
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue

set boolNumber to ocidPlistDict's valueForKey:"CreateDesktop"

if boolNumber = ocidTrue then
	log "現在の値はTRUE=1です"
else if boolNumber = ocidFalse then
	log "現在の値はFALSE=0です"
else if boolNumber = (missing value) then
	set boolNumber to ocidTrue
	log "値を取得できませんでした"
end if
##############################################
## 今の設定内容と逆のことを実行する
##############################################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias

if boolNumber = ocidTrue then
	display dialog "デスクトップのアイコンを隠します" with icon aliasIconPath
	
else if boolNumber = ocidFalse then
	display dialog "デスクトップのアイコンを表示します" with icon aliasIconPath
	
end if
##############################################
##現在の値の逆の値をセットする
##############################################
if boolNumber = ocidTrue then
	log "現在の値はTRUE=1です-->FALSE=0をセットします"
	ocidPlistDict's setObject:ocidFalse forKey:"CreateDesktop"
else if boolNumber = ocidFalse then
	log "現在の値はFALSE=0です-->TRUE=1をセットします"
	ocidPlistDict's setObject:ocidTrue forKey:"CreateDesktop"
else
	log "値を取得できませんでした-->Key を作ってTRUE=1をセットします"
	ocidPlistDict's setObject:ocidTrue forKey:"CreateDesktop"
end if
####変更後の値
log (ocidPlistDict's valueForKey:"CreateDesktop") as boolean

##############################################
## ファイルを書き込みます
##############################################

###書き込み用にバイナリーデータに変換
set ocidPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistDict format:ocidNSbplist options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray

set ocidNSErrorData to item 2 of ocidPlistEditDataArray
if ocidNSErrorData is not (missing value) then
	doGetErrorData(ocidNSErrorData)
end if

####書き込み
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidPlistFilePathURL) options:0 |error|:(reference)
log item 2 of boolWritetoUrlArray

set ocidNSErrorData to item 2 of boolWritetoUrlArray
if ocidNSErrorData is not (missing value) then
	doGetErrorData(ocidNSErrorData)
end if

##############################################
## Finder再起動
##############################################
set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
	###２秒まって
	delay 2
	###起動させる
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
else if (count of ocidAppList) = 0 then
	###Finderが無いなら起動
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
end if
#############起動確認　１０回１０秒間
repeat 10 times
	set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
	if (count of ocidAppList) = 0 then
		###Finderが無いなら起動
		set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
		ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
	else
		###あるなら起動確認終了
		exit repeat
	end if
	delay 1
end repeat



##############################################
## エラー発生時のログ用
##############################################


to doGetErrorData(ocidNSErrorData)
	#####個別のエラー情報
	log "エラーコード：" & ocidNSErrorData's code() as text
	log "エラードメイン：" & ocidNSErrorData's domain() as text
	log "Description:" & ocidNSErrorData's localizedDescription() as text
	log "FailureReason:" & ocidNSErrorData's localizedFailureReason() as text
	log ocidNSErrorData's localizedRecoverySuggestion() as text
	log ocidNSErrorData's localizedRecoveryOptions() as text
	log ocidNSErrorData's recoveryAttempter() as text
	log ocidNSErrorData's helpAnchor() as text
	set ocidNSErrorUserInfo to ocidNSErrorData's userInfo()
	set ocidAllValues to ocidNSErrorUserInfo's allValues() as list
	set ocidAllKeys to ocidNSErrorUserInfo's allKeys() as list
	repeat with ocidKeys in ocidAllKeys
		if (ocidKeys as text) is "NSUnderlyingError" then
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedDescription() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedFailureReason() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoverySuggestion() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoveryOptions() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s recoveryAttempter() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s helpAnchor() as text
		else
			####それ以外の値はそのままテキストで読める
			log (ocidKeys as text) & ": " & (ocidNSErrorUserInfo's valueForKey:ocidKeys) as text
		end if
	end repeat
	
end doGetErrorData