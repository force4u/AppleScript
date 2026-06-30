#!/usr/bin/env osascript
#coding: utf-8
----+----1----+----2----+----3----+----4----+----5----+----6----+----7
(*
システム設定オープン用のスクリプト作成補助 
システム設定のURL作成用のアンカー名の収集を行います
マルチリンガル対応版
一般＝GENERALの各国語の取得を簡素化した


【注意】【注意】【注意】【注意】
パネルIDにAppleID名といった個人情報が含まれます
出力物の配布時には対象レコードを削除する等配慮が必要です


Script creation assistance for opening system settings. 
Collect anchor names for creating URLs for system settings. 
Multilingual compatible version. 

[Attention][Attention][Attention][Attention]
Personal information such as Apple ID name is included in the panel ID. 
Considerations such as deleting the target record are required when distributing outputs.


https://www.macscripter.net/t/system-settings-shortcuts/78007

com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
set strBundleID to ("com.apple.systempreferences") as text

############################
#【１】JSON保存先
set aliasPathToMe to (path to me) as alias
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:(false)
set ocidContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
#
set ocidJsonFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("systempreferences.json") isDirectory:(false)
set ocidAllKeysFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("allKes.json") isDirectory:(false)
set ocidAllKeysTextFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("allKes.txt") isDirectory:(false)
############################
#【１】システム設定の起動を確定させる
set ocidRunAppArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
if (count of ocidRunAppArray) ≠ 0 then
	log "起動中です"
	tell application id strBundleID to activate
else
	####ゾンビ対策終了させてから処理させる
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	if numCntWindow = 0 then
		tell application id strBundleID to quit
	else
		tell application id strBundleID
			close (every window)
		end tell
		delay 0.5
		tell application id strBundleID to quit
	end if
	#半ゾンビ化対策	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	#システム設定を起動させる
	try
		tell application id strBundleID to activate
	on error
		tell application "System Settings" to activate
	end try
	#起動待ち
	tell application id strBundleID
		#起動確認　最大１０秒
		repeat 20 times
			activate
			set boolFrontMost to frontmost as boolean
			log boolFrontMost
			if boolFrontMost is true then
				#魔法の１秒
				delay 0.5
				exit repeat
			else
				delay 0.5
			end if
		end repeat
	end tell
end if
####################
#地域と言語(Region and language)
set appLocale to refMe's NSLocale's currentLocale()
set ocidLocaleID to appLocale's objectForKey:(refMe's NSLocaleIdentifier)
set strLocaleID to ocidLocaleID as text
#ローカライズされたGENERALの名称の取得『簡易版』
tell application "System Settings"
	set strGeneral to (localized string ("GENERAL") from table ("Localizable")) as text
end tell


############################
#全てのパネルのIDを取得
tell application id "com.apple.systempreferences"
	set listPanelID to (id of every pane) as list
end tell
log listPanelID as list
############################
###【A】正順レコード
set ocidPaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###【B】逆順レコード
set ocidReversePaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###【３】１で取得したリストの数だけ繰り返し
repeat with itemPanelID in listPanelID
	set strPanelID to itemPanelID as text
	tell application "System Settings"
		if strPanelID is "com.apple.systempreferences.GeneralSettings" then
			set strPanelName to (strGeneral) as text
		else
			set strPanelName to (name of pane id strPanelID) as text
		end if
	end tell
	###【A】正順レコード
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelName) forKey:(strPanelID))
	(ocidPaneDict's addEntriesFromDictionary:(ocidItemDict))
	###【B】逆順レコード
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelID) forKey:(strPanelName))
	(ocidReversePaneDict's addEntriesFromDictionary:(ocidItemDict))
end repeat

############################
#正順レコードのLISTを作る
set ocidAllValueArray to ocidPaneDict's allValues()
##ソートしておく
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s init()
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedKey to (ocidAllValueArray's sortedArrayUsingDescriptors:(ocidDescriptorArray))
set listAllValueArray to ocidSortedKey as list

set ocidURLDict to refMe's NSMutableDictionary's alloc()'s init()
repeat with itemValue in listAllValueArray
	set strValue to itemValue as text
	#パネルIDを取得
	set ocidPaneID to (ocidReversePaneDict's valueForKey:(strValue))
	set strPaneID to ocidPaneID as text
	
	#アンカーの値の取得
	tell application "System Settings"
		set listPaneAnchor to (name of (every anchor of pane strValue)) as list
		log listPaneAnchor
	end tell
	
	if strValue is strGeneral then
		set strID to ("" & strPaneID & "?Main")
		(ocidURLDict's setObject:(strID) forKey:(strGeneral))
	else if listPaneAnchor is {} then
		set strID to strPaneID as text
		(ocidURLDict's setObject:(strID) forKey:(strValue))
	else
		tell application "System Settings"
			repeat with itemAnchor in listPaneAnchor
				
				set strAnchor to itemAnchor as text
				set strID to ("" & strPaneID & "?" & strAnchor & "") as text
				set strSetKey to ("" & strValue & "?" & strAnchor & "") as text
				(ocidURLDict's setObject:(strID) forKey:(strSetKey))
			end repeat
		end tell
	end if
	
end repeat
set ocidAllKeys to ocidURLDict's allKeys()
set ocidSortedArray to ocidAllKeys's sortedArrayUsingSelector:("localizedStandardCompare:")
#NSJSONSerialization
set ocidOption to (refMe's NSJSONWritingSortedKeys)
set listResponse to (refMe's NSJSONSerialization's dataWithJSONObject:(ocidSortedArray) options:(ocidOption) |error|:(reference))
set ocidArrayData to (first item of listResponse)
##NSDATA
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidArrayData's writeToURL:(ocidAllKeysFilePathURL) options:(ocidOption) |error|:(reference)
#STRING
set ocidJoinText to ocidSortedArray's componentsJoinedByString:(linefeed)
set listDone to ocidJoinText's writeToURL:(ocidAllKeysTextFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

#NSJSONSerialization
set ocidOption to (refMe's NSJSONWritingSortedKeys)
set listResponse to (refMe's NSJSONSerialization's dataWithJSONObject:(ocidURLDict) options:(ocidOption) |error|:(reference))
set ocidSaveData to (first item of listResponse)
##NSDATA
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidJsonFilePathURL) options:(ocidOption) |error|:(reference)

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidOpenURLsArray to refMe's NSMutableArray's alloc()'s init()
(ocidOpenURLsArray's addObject:(ocidJsonFilePathURL))
(ocidOpenURLsArray's addObject:(ocidAllKeysFilePathURL))
(ocidOpenURLsArray's addObject:(ocidAllKeysTextFilePathURL))
appSharedWorkspace's activateFileViewerSelectingURLs:(ocidOpenURLsArray)

return
