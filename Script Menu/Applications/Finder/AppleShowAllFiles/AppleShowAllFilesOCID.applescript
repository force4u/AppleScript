#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　
(*
ファイルの表示を切り替えます
*)
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSURL : a reference to refMe's NSURL

property refNSMutableDictionary : a reference to refMe's NSMutableDictionary
property refNSPropertyListSerialization : a reference to refMe's NSPropertyListSerialization

set objFileManager to refMe's NSFileManager's defaultManager()

#####設定項目
set strPlistFileName to "com.apple.finder.plist" as text


##############################################
## Boolean属性の事前定義
##############################################
-->false = 0
set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
-->true = 1
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue

##############################################
## ファイルパス関連
##############################################
####初期設定フォルダ
set ocidUserLibraryPath to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidUserLibraryPath's objectAtIndex:0
set ocidPreferencesURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"Preferences"
####ファイル名
set ocidPlistFileName to refNSString's stringWithString:strPlistFileName
#####ファイル名を付与
set ocidPlistFilePathURL to ocidPreferencesURL's URLByAppendingPathComponent:strPlistFileName

##############################################
## 本処理
##############################################
set ocidPlistDict to refNSMutableDictionary's alloc()'s initWithCapacity:0
####ファイル読み込み
set ocidReadPlistData to refNSMutableDictionary's dictionaryWithContentsOfURL:ocidPlistFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of ocidReadPlistData
--> ocidPlistDict にPLISTの内容が全部入り
##############################################
## 現在の値は？
##############################################
set ocidAppleShowAllFilesValue to ocidPlistDict's valueForKey:"AppleShowAllFiles"
log ocidAppleShowAllFilesValue's integerValue()
log ocidAppleShowAllFilesValue's boolValue()

if ocidAppleShowAllFilesValue is ocidTrue then
	log "現在の設定はTRUE"
else if ocidAppleShowAllFilesValue is ocidFalse then
	log "現在の設定はFALSE"
end if
##############################################
## 現在の設定と逆の設定をSETする
##############################################
####変更後の値の入ったDictを作っておく
set ocidValueForDict to refNSMutableDictionary's alloc()'s initWithCapacity:0
ocidValueForDict's setDictionary:ocidPlistDict
(*
ocidPlistDictには元の値が入っているのでバックアップを作りたい場合は
ocidPlistDictの内容を別名保存するといい
*)
if ocidAppleShowAllFilesValue is ocidTrue then
	log "現在の設定はTRUE"
	set strMes to "全ファイル表示を停止しました"
	####FALSEをセットして　変更が入った値用のDICTに戻す
	ocidValueForDict's setObject:ocidFalse forKey:"AppleShowAllFiles"
else if ocidAppleShowAllFilesValue is ocidFalse then
	log "現在の設定はFALSE"
	set strMes to "全ファイル表示に設定変更しました"
	####TRUEをセットする　変更が入った値用のDICTに戻す
	ocidValueForDict's setObject:ocidTrue forKey:"AppleShowAllFiles"
end if

##############################################
## 変更後の値を保存する
##############################################
###バイナリー形式
set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
###書き込み用にバイナリーデータに変換
set ocidPlistEditDataArray to refNSPropertyListSerialization's dataWithPropertyList:ocidValueForDict format:ocidNSbplist options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray
####書き込み
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:ocidPlistFilePathURL options:0 |error|:(reference)


##############################################
## Finderを再起動
##############################################

set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
	delay 3
	###起動させる
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
else if (count of ocidAppList) = 0 then
	###Finderが無いなら起動
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
end if


return "処理終了" & strMes