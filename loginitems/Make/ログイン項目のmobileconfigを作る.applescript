#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

####################################
####【設定項目】
####################################

###DeviceType
set numTargetDeviceType to 5 as number
(*
0 = Any/unspecified
1 = iPhone/iPad/iPod Touch
2 = Apple Watch
3 = HomePod
4 = Apple TV
5 = Mac
*)
###システム設定のプロファイルの表示名（わかりやすい名称がいいね）
set strPayloadDisplayName to "com.apple.loginitems.managed(Font Book)設定" as text
###ドメイン　自社のを指定してね
set strPayloadOrganization to "com.cocolog-nifty.quicktimer" as text
###インストールする時の説明欄に表示されます
set strPayloadDescription to "com.apple.loginitems.managed関連の設定です" as text
###インストールダイアログに表示されます
set strConsentTextDefault to "com.apple.loginitems.managed設定のみ行います\r【削除可】削除してもかまいません\r【非適応化】インストールしなくてもかまいません\r【内容】ログイン項目に対象のアプリをインストールします\r（起動時・ログイン時に自動で起動します）"


####################################
####【設定項目】追加するアプリケーションパス
####################################
set strAppPath to ("/System/Applications/Font Book.app/") as text
set ocidAppPathStr to refMe's NSString's stringWithString:(strAppPath)
set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()

####################################
#### ファイルパス関連　保存先
####################################

###
set strPlistFileName to ("com.apple.loginitems.mobileconfig")
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDesktopPathURL's URLByAppendingPathComponent:("Mobileconfig")
###フォルダ作っておく
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strPlistFileName)

####################################
#### NSMutableDictionary可変ディレクトリ
####################################
###変更不可（ログイン項目を意味します）
set strDomain to "com.apple.loginitems.managed"
###ROOT
set ocidPlistData to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###boolean 項目の 設定
-->false
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
-->true
set ocidTrue to (refMe's NSNumber's numberWithBool:true)

####################################
#### PayloadContent項目
####################################
set ocidPayloadContentArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
set ocidPayloadContentDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
##
set ocidPayloadSettingDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPayloadSettingDict's setObject:(ocidAppPath) forKey:("Path")
ocidPayloadSettingDict's setObject:(ocidFalse) forKey:("AuthenticateAsLoginUserShortName")
ocidPayloadSettingDict's setObject:(ocidTrue) forKey:("Hide")
##
set ocidPayloadSettingArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidPayloadSettingArray's addObject:(ocidPayloadSettingDict)
##
ocidPayloadContentDict's setObject:(ocidPayloadSettingArray) forKey:("AutoLaunchedApplicationDictionary-managed")


###PayloadIdentifier
set ocidConcreteUUID to refMe's NSUUID's UUID()
set ocidUUIDString to ocidConcreteUUID's UUIDString()
set strUUIDString to strDomain & "." & ocidUUIDString as string
ocidPayloadContentDict's setObject:(strUUIDString) forKey:"PayloadIdentifier"
ocidPayloadContentDict's setObject:(ocidUUIDString) forKey:"PayloadUUID"

ocidPayloadContentDict's setObject:(strDomain) forKey:"PayloadType"

###PayloadVersion
set strDateno to doGetDateNo("yyyyMMdd")
set numDateno to strDateno as integer
ocidPayloadContentDict's setObject:(numDateno as integer) forKey:"PayloadVersion"

ocidPayloadContentArray's addObject:ocidPayloadContentDict

####################################
#### ROOT項目
####################################
####PayloadContent
ocidPlistData's setObject:(ocidPayloadContentArray) forKey:"PayloadContent"

##################string
###PayloadUUID
set ocidConcreteUUID to refMe's NSUUID's UUID()
set ocidUUIDString to ocidConcreteUUID's UUIDString()
set strUUIDString to ocidUUIDString as string
ocidPlistData's setObject:(strUUIDString) forKey:"PayloadUUID"
###↑同じUUIDを使うのでセットで
###PayloadIdentifier
set strUUIDString to strDomain & "." & ocidUUIDString as string
ocidPlistData's setObject:(strUUIDString) forKey:"PayloadIdentifier"

###PayloadType これは固定
ocidPlistData's setObject:("Configuration" as string) forKey:"PayloadType"

###PayloadScope User or System
ocidPlistData's setObject:("User" as string) forKey:"PayloadScope"

###PayloadDisplayName
ocidPlistData's setObject:(strPayloadDisplayName as string) forKey:"PayloadDisplayName"

###PayloadDescription
ocidPlistData's setObject:(strPayloadDescription as string) forKey:"PayloadDescription"

###PayloadDescription
ocidPlistData's setObject:(strPayloadOrganization as string) forKey:"PayloadOrganization"

##################Record
###ConsentText
####set recorConsentText to {default:strConsentTextDefault} as record
ocidPlistData's setObject:{default:strConsentTextDefault} forKey:"ConsentText"

##################BOOL
###削除可非
ocidPlistData's setObject:(ocidTrue) forKey:"PayloadRemovalDisallowed"

###パスワード指定
ocidPlistData's setObject:(ocidFalse) forKey:"HasRemovalPasscode"
##ocidPlistData's setObject:(ocidFalse) forKey:"IsEncrypted"

##################integer
###PayloadVersion
set strDateno to doGetDateNo("yyyyMMdd")
set numDateno to strDateno as integer
ocidPlistData's setObject:(numDateno as integer) forKey:"PayloadVersion"

###TargetDeviceType　デバイスタイプ
ocidPlistData's setObject:(numTargetDeviceType as number) forKey:"TargetDeviceType"


####################################
#### PLIST形式に変換
####################################
####XMLフォーマット
set ocidPlistFotmat to refMe's NSPropertyListXMLFormat_v1_0
####PLIST形式に変換
set lisrResponse to refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistData format:ocidPlistFotmat options:0 |error|:(reference)
####取り出し
set ocidPlistOutPutData to (item 1 of lisrResponse)
####################################
#### 保存
####################################
#####書き込み
set listDone to (ocidPlistOutPutData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference))
set boolSaveFile to (item 1 of listDone) as boolean

if boolSaveFile is true then
	set strSaveFilePathURL to (ocidSaveFilePathURL's |path|()) as text
	
	
	tell application "System Settings" to launch
	
	--システム環境設定が開くのを待つ
	repeat
		set doLaunchApp to get running of application "System Settings"
		if doLaunchApp is false then
			delay 0.5
		else
			exit repeat
		end if
	end repeat
	try
		set strCommandText to "open -b com.apple.systempreferences \"/System/Library/PreferencePanes/Profiles.prefPane\"" as text
		do shell script strCommandText
	on error
		tell application id "com.apple.systempreferences"
			activate
			reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
		end tell
	end try
	repeat 10 times
		tell application id "com.apple.systempreferences"
			activate
			reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
			tell current pane
				set strPaneID to id as text
				properties
			end tell
		end tell
		if strPaneID is "com.apple.settings.PrivacySecurity.extension" then
			exit repeat
		else
			delay 0.5
		end if
	end repeat
	
	tell application "Finder"
		
		set theCmdCom to ("open  \"" & strSaveFilePathURL & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
		do shell script theCmdCom
	end tell
	
end if

####################################
#### 
####################################

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
