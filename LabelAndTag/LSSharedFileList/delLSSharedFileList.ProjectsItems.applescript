#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
サイドバーから項目を削除します
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
set appFileManager to refMe's NSFileManager's defaultManager()
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.ProjectsItems.sfl2" as text
###URLに
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
###NSDATAに読み込みます
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL))
###	解凍してDictに　Flozenなので値を変更するために　可変に変えます
set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
###	可変Dictにセット
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidArchveDictM's setDictionary:ocidArchveDict)

#######################################
###　items の処理
#######################################
###		items のArrayを取り出して　Flozenなので値を変更するために　可変に変えます
set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
###		項目入替用のArray　
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
(ocidItemsArrayM's setArray:ocidItemsArray)

#######################################
###　ダイアログ
#######################################
set listItemsName to {} as list
repeat with itemItemsDict in ocidItemsArray
	set strName to (itemItemsDict's objectForKey:("Name")) as text
	set end of listItemsName to strName
end repeat
log listItemsName

###ダイアログを前面に出す
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
	set listResponse to (choose from list listItemsName with title "選んでください" with prompt "サイドバー項目から削除します" default items (item 1 of listItemsName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set strResponse to (item 1 of listResponse) as text
#######################################
###　本処理
#######################################
set numCntArrayNO to 0 as integer
set numArrayIndex to (missing value)
repeat with itemItemsDict in ocidItemsArray
	set strName to (itemItemsDict's objectForKey:("Name")) as text
	if strName is strResponse then
		set numArrayIndex to numCntArrayNO
	end if
	
	set numCntArrayNO to numCntArrayNO + 1 as integer
end repeat
if numArrayIndex ≠ (missing value) then
	ocidItemsArrayM's removeObjectAtIndex:(numArrayIndex)
end if


### RootにItemsを追加
(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す
set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
set ocidSaveData to item 1 of listSaveData

#######################################
###　データを上書き保存する
#######################################
##保存
set boolDone to (ocidSaveData's writeToURL:(ocidSharedFileListURL) atomically:true)

#######################################
###　リロード
#######################################
try
	do shell script "/usr/bin/killall sharedfilelistd"
on error
	set strAgentPath to "/System/Library/LaunchAgents/com.apple.coreservices.sharedfilelistd.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
end try
delay 0.5
do shell script "/usr/bin/killall Finder"

return
