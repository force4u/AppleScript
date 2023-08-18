#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	要管理者権限
# 	com.apple.xpc.launchdのdisabledから不要な項目を削除します
#	
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
####################################
###パス
####################################
##UID取得
set recordSystemInfo to (system info) as record
set stUID to (user ID of recordSystemInfo) as text
set strUNAME to (short user name of recordSystemInfo) as text
##ファイル名　loginitems
set strPlistFileName to ("disabled." & stUID & ".plist") as text
##パス
set strXpcDirPath to ("/private/var/db/com.apple.xpc.launchd/") as text
set strFilePath to ("" & strXpcDirPath & strPlistFileName & "") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
####################################
###PLIST
####################################
### 読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
###AllKey
set ocidAllKyesArray to ocidPlistDict's allKeys()
set listAllKyesArray to ocidAllKyesArray as list
####################################
###ダイアログ
####################################
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
	set listResponse to (choose from list listAllKyesArray with title "選んでください" with prompt "削除する項目を選んでください" default items (item 1 of listAllKyesArray) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	log "キャンセルしました"
	return "キャンセルしました"
end if

####################################
### 本処理項目削除
####################################
repeat with itemResponse in listResponse
	set strItemKey to itemResponse as text
	(ocidPlistDict's removeObjectForKey:(strItemKey))
	
end repeat

####################################
###アクセス権変更
####################################
set strCommandText to ("/usr/bin/sudo /usr/sbin/chown -Rf " & strUNAME & " \"" & strXpcDirPath & "\"") as text
do shell script strCommandText with administrator privileges


####################################
### 保存
####################################
set listDone to ocidPlistDict's writeToURL:(ocidFilePathURL) |error|:(reference)

####################################
###アクセス権 を戻す
####################################
set strCommandText to ("/usr/bin/sudo /usr/sbin/chown -Rf root  \"" & strXpcDirPath & "\"") as text
do shell script strCommandText with administrator privileges
