#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#			OS14に対応
#			サンプルは通知全部『切る』設定です
#			クロームベースの通知設定に対応版
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###システム設定を終了させる
tell application id "com.apple.systempreferences" to quit


###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
##
set aliasFile to (choose file with prompt "アプリケーションを選択してください" default location (path to applications folder from local domain) of type {"com.apple.application-bundle"} without invisibles, multiple selections allowed and showing package contents) as alias

tell application "Finder"
	set recordInfo to info for aliasFile
	set strBundleID to (bundle identifier of recordInfo) as text
end tell

##バンドルIDを小文字にしておく（大文字小文字判別するので２重登録は出来る）
set ocidBundleID to refMe's NSString's stringWithString:(strBundleID)
set strBundleID to (ocidBundleID's lowercaseString()) as text

######
tell application "Finder"
	######ライブラリフォルダに保存先フォルダを作っておく
	set boolFolderExists to exists of folder "Mobileconfig" of (path to documents folder from user domain)
	if boolFolderExists is false then
		make new folder at (path to documents folder from user domain) with properties {name:"Mobileconfig"}
	end if
	set aliasMobileconfigSaveDir to (folder "Mobileconfig" of (path to documents folder from user domain)) as alias
	set strMobileconfigSaveDir to POSIX path of aliasMobileconfigSaveDir as text
	######通知設定フォルダがあるか？
	set boolFileSaveDir to exists of folder "通知設定" of folder aliasMobileconfigSaveDir
	if boolFileSaveDir is false then
		make new folder at (folder aliasMobileconfigSaveDir) with properties {name:"通知設定"}
	end if
	set aliasFileSaveDir to (folder "通知設定" of folder aliasMobileconfigSaveDir) as alias
	set strFileSaveDir to POSIX path of aliasFileSaveDir as text
end tell

###########################
###ファイル名
set strFileName to "" & strBundleID & "通知設定.mobileconfig"
###パス
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strFileSaveDir)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)
###
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName)

####設定用に必要な２つのでUUIDを生成
set strUUIDA to (doUUIDgen()) as text
set strUUIDB to (doUUIDgen()) as text

####boolean値を作っておきます
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)
#############################################
##【ROOT】
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【ROOT】
set ocidConsentTextDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidConsentTextDict's setValue:"通知をOFFにします(d)" forKey:"default"
ocidConsentTextDict's setValue:"Disable  notificationsettings(en)" forKey:"en"
ocidConsentTextDict's setValue:"通知をOFFにします(ja)" forKey:"ja"
ocidPlistDict's setObject:(ocidConsentTextDict) forKey:"ConsentText"
###【ROOT】
set strPayloadName to ("通知設定." & strBundleID & ".com.apple.notificationsettings") as text
ocidPlistDict's setValue:(strPayloadName) forKey:"PayloadDescription"
###【ROOT】
ocidPlistDict's setValue:(strPayloadName) forKey:"PayloadDisplayName"
###【ROOT】
set strPayloadIdentifier to ("com.apple.notificationsettings." & strBundleID & "." & strUUIDA) as text
ocidPlistDict's setValue:(strPayloadIdentifier) forKey:"PayloadIdentifier"
###【ROOT】
ocidPlistDict's setValue:(strBundleID) forKey:"PayloadOrganization"
###【ROOT】
ocidPlistDict's setObject:(ocidFalse) forKey:"PayloadRemovalDisallowed"
###【ROOT】
ocidPlistDict's setValue:("User") forKey:"PayloadScope"
###【ROOT】
ocidPlistDict's setValue:("Configuration") forKey:"PayloadType"
###【ROOT】
ocidPlistDict's setValue:(strUUIDA) forKey:"PayloadUUID"
###【ROOT】
set numDateno to doGetDateNo("yyyyMMdd") as integer
ocidPlistDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(numDateno)) forKey:"PayloadVersion"
###【ROOT】
ocidPlistDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(0)) forKey:"TargetDeviceType"

#############################################
###【１】Array
set ocidPayloadContentArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###【２】Dict
set ocidPayloadContentDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【３】Array
set ocidNotificationSettingsArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###【４】Dicrt
set ocidNotificationSettingsDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【４】
ocidNotificationSettingsDict's setValue:(strBundleID) forKey:"BundleIdentifier"
###【４】
ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(0)) forKey:"AlertType"
###【４】
ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(1)) forKey:"PreviewType"
###【４】
ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(1)) forKey:"GroupingType"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"NotificationsEnabled"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInCarPlay"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"BadgesEnabled"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"CriticalAlertEnabled"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInLockScreen"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInNotificationCenter"
###【４】
ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"SoundsEnabled"
###【３】
ocidNotificationSettingsArray's addObject:(ocidNotificationSettingsDict)
###【２】
ocidPayloadContentDict's setObject:(ocidNotificationSettingsArray) forKey:"NotificationSettings"
###【２】
set strPayloadDescription to (strBundleID & ".com.apple.notificationsettings") as text
ocidPayloadContentDict's setValue:(strPayloadDescription) forKey:"PayloadDescription"
###【２】
set strPayloadName to (strBundleID & ".com.apple.notificationsettings") as text
ocidPayloadContentDict's setValue:(strPayloadName) forKey:"PayloadDisplayName"
###【２】
set strPayloadIdentifier to ("com.apple.notificationsettings." & strBundleID & "." & strUUIDB) as text
ocidPayloadContentDict's setValue:(strPayloadIdentifier) forKey:"PayloadIdentifier"
###【２】
ocidPayloadContentDict's setValue:("com.apple.notificationsettings") forKey:"PayloadType"
###【２】
ocidPayloadContentDict's setValue:(strUUIDB) forKey:"PayloadUUID"
###【２】
ocidPayloadContentDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(numDateno)) forKey:"PayloadVersion"
###【１】
ocidPayloadContentArray's addObject:(ocidPayloadContentDict)
###【ROOT】
ocidPlistDict's setObject:(ocidPayloadContentArray) forKey:"PayloadContent"
#############################################
set ocidFormat to (refMe's NSPropertyListXMLFormat_v1_0)
set listPlistData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistData
###
set listBoolDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
set boolDone to (item 1 of listBoolDone) as boolean
set strPlistFilePath to ocidSaveFilePathURL's |path| as text
set aliasPlistPath to (ocidSaveFilePathURL's absoluteURL()) as alias


#############################################
###【Chrome】クロームベースの通知設定
#############################################
set strAlertNotificationServiceID to ("" & strBundleID & ".framework.AlertNotificationService") as text
tell application "Finder"
	try
		set boolAlertApp to exists (get application file id strAlertNotificationServiceID)
	on error
		set boolAlertApp to false as boolean
	end try
end tell
if boolAlertApp is true then
	tell application "Finder"
		set aliasAlertAppPath to (get application file id strAlertNotificationServiceID) as alias
	end tell
	tell application "Finder"
		set recordInfo to info for aliasAlertAppPath
		set strBundleIDFramework to (bundle identifier of recordInfo) as text
	end tell
	###ファイル名
	set strFileName to "" & strBundleIDFramework & "通知設定.mobileconfig"
	###
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName)
	
	####設定用に必要な２つのでUUIDを生成
	set strUUIDA to (doUUIDgen()) as text
	set strUUIDB to (doUUIDgen()) as text
	
	####boolean値を作っておきます
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)
	set ocidTrue to (refMe's NSNumber's numberWithBool:true)
	#############################################
	##【ROOT】
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	###【ROOT】
	set ocidConsentTextDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidConsentTextDict's setValue:"通知をOFFにします(d)" forKey:"default"
	ocidConsentTextDict's setValue:"Disable  notificationsettings(en)" forKey:"en"
	ocidConsentTextDict's setValue:"通知をOFFにします(ja)" forKey:"ja"
	ocidPlistDict's setObject:(ocidConsentTextDict) forKey:"ConsentText"
	###【ROOT】
	set strPayloadName to ("通知設定." & strBundleIDFramework) as text
	ocidPlistDict's setValue:(strPayloadName) forKey:"PayloadDescription"
	###【ROOT】
	ocidPlistDict's setValue:(strPayloadName) forKey:"PayloadDisplayName"
	###【ROOT】
	set strPayloadIdentifier to (strBundleIDFramework & "." & strUUIDA) as text
	ocidPlistDict's setValue:(strPayloadIdentifier) forKey:"PayloadIdentifier"
	###【ROOT】
	ocidPlistDict's setValue:(strBundleIDFramework) forKey:"PayloadOrganization"
	###【ROOT】
	ocidPlistDict's setObject:(ocidFalse) forKey:"PayloadRemovalDisallowed"
	###【ROOT】
	ocidPlistDict's setValue:("User") forKey:"PayloadScope"
	###【ROOT】
	ocidPlistDict's setValue:("Configuration") forKey:"PayloadType"
	###【ROOT】
	ocidPlistDict's setValue:(strUUIDA) forKey:"PayloadUUID"
	###【ROOT】
	set numDateno to doGetDateNo("yyyyMMdd") as integer
	ocidPlistDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(numDateno)) forKey:"PayloadVersion"
	###【ROOT】
	ocidPlistDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(0)) forKey:"TargetDeviceType"
	
	#############################################
	###【１】Array
	set ocidPayloadContentArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	###【２】Dict
	set ocidPayloadContentDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	###【３】Array
	set ocidNotificationSettingsArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	###【４】Dicrt
	set ocidNotificationSettingsDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	###【４】
	ocidNotificationSettingsDict's setValue:(strBundleIDFramework) forKey:"BundleIdentifier"
	###【４】
	ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(0)) forKey:"AlertType"
	###【４】
	ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(1)) forKey:"PreviewType"
	###【４】
	ocidNotificationSettingsDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(1)) forKey:"GroupingType"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"NotificationsEnabled"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInCarPlay"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"BadgesEnabled"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"CriticalAlertEnabled"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInLockScreen"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"ShowInNotificationCenter"
	###【４】
	ocidNotificationSettingsDict's setObject:(ocidFalse) forKey:"SoundsEnabled"
	###【３】
	ocidNotificationSettingsArray's addObject:(ocidNotificationSettingsDict)
	###【２】
	ocidPayloadContentDict's setObject:(ocidNotificationSettingsArray) forKey:"NotificationSettings"
	###【２】
	set strPayloadDescription to (strBundleID) as text
	ocidPayloadContentDict's setValue:(strPayloadDescription) forKey:"PayloadDescription"
	###【２】
	set strPayloadName to (strBundleID) as text
	ocidPayloadContentDict's setValue:(strPayloadName) forKey:"PayloadDisplayName"
	###【２】
	set strPayloadIdentifier to (strBundleID & "." & strUUIDB) as text
	ocidPayloadContentDict's setValue:(strPayloadIdentifier) forKey:"PayloadIdentifier"
	###【２】
	ocidPayloadContentDict's setValue:("com.apple.notificationsettings") forKey:"PayloadType"
	###【２】
	ocidPayloadContentDict's setValue:(strUUIDB) forKey:"PayloadUUID"
	###【２】
	ocidPayloadContentDict's setValue:(refMe's NSNumber's alloc()'s initWithInteger:(numDateno)) forKey:"PayloadVersion"
	###【１】
	ocidPayloadContentArray's addObject:(ocidPayloadContentDict)
	###【ROOT】
	ocidPlistDict's setObject:(ocidPayloadContentArray) forKey:"PayloadContent"
	#############################################
	set ocidFormat to (refMe's NSPropertyListXMLFormat_v1_0)
	set listPlistData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
	set ocidPlistData to item 1 of listPlistData
	###
	set listBoolDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
	set boolDone to (item 1 of listBoolDone) as boolean
	set strPlistFilePath to ocidSaveFilePathURL's |path| as text
	set aliasPlistPath to (ocidSaveFilePathURL's absoluteURL()) as alias
	
end if

###########################
####ファイルの書き込みでｔｕｒｅが返ったら成功なのでインストール
if boolDone is true then
	
	###起動待ち
	tell application id "com.apple.systempreferences" to activate
	###起動確認　最大１０秒
	tell application id "com.apple.systempreferences"
		repeat 10 times
			activate
			set boolFrontMost to frontmost as boolean
			if boolFrontMost is true then
				exit repeat
			else
				delay 1
			end if
		end repeat
	end tell
	set strPaneId to "com.apple.Profiles-Settings.extension" as text
	set strAnchorName to "Main" as text
	###アンカーで開く
	tell application id "com.apple.systempreferences"
		activate
		reveal anchor strAnchorName of pane id strPaneId
	end tell
	###アンカーで開くの待ち　最大１０秒
	repeat 10 times
		tell application id "com.apple.systempreferences"
			tell pane id strPaneId
				set listAnchorName to name of anchors
			end tell
			if listAnchorName is missing value then
				delay 1
			else if listAnchorName is {"Main"} then
				exit repeat
			end if
		end tell
	end repeat
end if
(* たぶん仕様上２こ同時に登録できない　
repeat with itemFilePath in listOpenFilePath
	set strFilePath to itemFilePath as text
	set strCmdCom to ("open  \"" & strFilePath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
	do shell script strCmdCom
end repeat
*)
set strCmdCom to ("open  \"" & strPlistFilePath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
do shell script strCmdCom


tell application "Finder"
	select aliasPlistPath
end tell

return

to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


to doUUIDgen()
	set ocidConcreteUUID to refMe's NSUUID's UUID()
	set ocidUUIDString to ocidConcreteUUID's UUIDString()
	set strUUIDString to ocidUUIDString as text
	return strUUIDString
end doUUIDgen
