#!/usr/bin/env osascript
#coding: utf-8
----+----1----+----2----+----3----+----4----+----5----+----6----+----7
(*
システム設定オープン用のスクリプト作成補助 


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
#ローカライズされたGENERAL名を取得
set ocidMsgDict to doGetGeneral(appLocale)
set strGeneral to (ocidMsgDict's objectForKey:("GENERAL")) as text

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
#ダイアログ用に正順レコードのLISTを作る
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

####################
#ローカライズメッセージ取得(Get Localize message)
to doGetGeneral(argLocale)
	set ocidLanguageCode to argLocale's objectForKey:(refMe's NSLocaleLanguageCode)
	set strLanguageCode to ocidLanguageCode as text
	set ocidLocaleID to argLocale's objectForKey:(refMe's NSLocaleIdentifier)
	set strLocaleID to ocidLocaleID as text
	log strLocaleID
	log strLanguageCode
	#LPROJフォルダ名(LPROJ folder name)
	set listLproj to {"ar", "ca", "cs", "da", "de", "el", "en_AU", "en_GB", "en", "es_419", "es", "fi", "fr_CA", "fr", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "pt_BR", "pt_PT", "ro", "ru", "sk", "sl", "sv", "th", "tr", "uk", "vi", "zh_CN", "zh_HK", "zh_TW"} as list
	#その中でラングエージコードになっている言語(使ってないけど)
	set listLangID to {"ar", "ca", "cs", "da", "de", "el", "en", "es", "fi", "fr", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "ro", "ru", "sk", "sl", "sv", "th", "tr", "uk", "vi"} as list
	#その中でロケールIDになっている言語(Among them, the language that is the locale ID)
	set listLocalID_Lproj to {"zh_CN", "zh_HK", "zh_TW", "pt_BR", "pt_PT", "en_AU", "en_GB", "fr_CA", "es_419"} as list
	########
	#FOR TEST
	#   set strLanguageCode to ("nn") as text
	#   set strLanguageCode to ("cy") as text
	#   set strLanguageCode to ("fr") as text
	#   set strLanguageCode to ("pt") as text
	#   set strLanguageCode to ("rm") as text
	#set strLanguageCode to ("zh") as text
	#set strLanguageCode to ("zh_TW") as text
	
	#言語判定　追加事項(Additional items for language judgment)
	if listLproj does not contain strLanguageCode then
		#ランゲージCodeがLPROJのフォルダ名に含まれていない場合
		#ランゲージCodeがLPROJのフォルダ名に含まれていない場合
		if strLanguageCode is "br" then
			set strSetUIlangID to ("fr") as text
		else if strLanguageCode is "gd" or strLanguageCode is "cy" then
			set strSetUIlangID to ("en_GB") as text
		else if strLanguageCode is "gl" or strLanguageCode is "eu" then
			set strSetUIlangID to ("en_GB") as text
		else if strLanguageCode is "nb" or strLanguageCode is "nn" then
			set strSetUIlangID to ("no") as text
		else if strLanguageCode is "rm" then
			set strSetUIlangID to ("de") as text
		else
			#ロケールIDがLPROJのフォルダ名の場合
			if listLocalID_Lproj contains strLocaleID then
				set strSetUIlangID to (strLocaleID) as text
			else
				#追加判定にない場合はen表示
				set strSetUIlangID to ("en") as text
			end if
		end if
	else
		if listLocalID_Lproj contains strLocaleID then
			set strSetUIlangID to (strLocaleID) as text
		else
			set strSetUIlangID to (strLanguageCode) as text
		end if
	end if
	
	#マージした辞書にする
	set ocidMergeDict to refMe's NSMutableDictionary's alloc()'s init()
	
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Applications/System Settings.app/Contents/Resources/MainMenu.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	if strSetUIlangID is "en" then
		set ocidMainMenuDict to ocidLocTableDict's objectForKey:("en_GB")
	else
		set ocidMainMenuDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	end if
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidMainMenuDict)
	
	
	#翻訳辞書を開く(Open the translation dictionary)
	#System Settingsの辞書を使用(Use the dictionary of System Settings.app)
	set strFilePath to ("/System/Applications/System Settings.app/Contents/Resources/Localizable.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	set ocidSystemSettingsDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidSystemSettingsDict)
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Library/ScriptingAdditions/StandardAdditions.osax/Contents/Resources/Localizable.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	set ocidStandardAdditionsDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidStandardAdditionsDict)
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Library/ScriptingAdditions/StandardAdditions.osax/Contents/Resources/ChooseFromList.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	if strSetUIlangID is "en" then
		set ocidChooseFromListDict to ocidLocTableDict's objectForKey:("en_GB")
	else
		set ocidChooseFromListDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	end if
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidChooseFromListDict)
	
	
	
	
	
	return ocidMergeDict
end doGetGeneral
