#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#			サンプルは通知全部『切る』設定です
#			クロームベースの通知設定に対応版
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property objMe : a reference to current application
property objNSString : a reference to objMe's NSString

set aliasFile to (choose file with prompt "アプリケーションを選択してください" default location (path to applications folder from user domain) of type {"com.apple.application-bundle"} without invisibles, multiple selections allowed and showing package contents) as alias

tell application "Finder"
	set objInfo to info for aliasFile
	set strUTI to bundle identifier of objInfo
end tell

##バンドルIDを小文字にしておく（大文字小文字判別するので２重登録は出来る）
set objCapText to objNSString's stringWithString:strUTI
set strUTI to (objCapText's lowercaseString()) as string

######クロームベースの通知設定チェック
set strAlertNotificationServiceID to ("" & strUTI & ".framework.AlertNotificationService") as text
tell application "Finder"
	try
		set boolAlertApp to exists (get application file id strAlertNotificationServiceID)
	on error
		
		set boolAlertApp to false as boolean
	end try
end tell

######
tell application "Finder"
	######ライブラリフォルダに保存先フォルダを作っておく
	set boolFolderExists to exists of folder "Mobileconfig" of (path to library folder from user domain)
	if boolFolderExists is false then
		make new folder at (path to library folder from user domain) with properties {name:"Mobileconfig"}
	end if
	set aliasMobileconfigSaveDir to (folder "Mobileconfig" of (path to library folder from user domain)) as alias
	set strMobileconfigSaveDir to POSIX path of aliasMobileconfigSaveDir as text
	######通知設定フォルダがあるか？
	set boolFileSaveDir to exists of folder "通知設定" of folder aliasMobileconfigSaveDir
	if boolFileSaveDir is false then
		make new folder at (folder aliasMobileconfigSaveDir) with properties {name:"通知設定"}
	end if
	set aliasFileSaveDir to (folder "通知設定" of folder aliasMobileconfigSaveDir) as alias
	set strFileSaveDir to POSIX path of aliasFileSaveDir as text
	
	######書類フォルダにエイリアスを作っておく
	set boolAliasExists to exists of folder "Mobileconfig" of (path to documents folder from user domain)
	if boolFolderExists is false then
		make new alias to folder aliasFileSaveDir at (path to documents folder from user domain)
	end if
	
end tell

####設定用に必要な２つのでUUIDを生成
set strUUIDA to (do shell script "uuidgen") as text
set strUUIDB to (do shell script "uuidgen") as text

set strPlisContents to "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>ConsentText</key><dict><key>default</key><string>" & strUTI & "通知設定</string></dict><key>PayloadContent</key><array><dict><key>NotificationSettings</key><array><dict><key>BundleIdentifier</key><string>" & strUTI & "</string><key>AlertType</key><integer>0</integer><key>PreviewType</key><integer>1</integer><key>GroupingType</key><integer>1</integer><key>NotificationsEnabled</key><false/><key>ShowInCarPlay</key><false/><key>BadgesEnabled</key><false/><key>CriticalAlertEnabled</key><false/><key>ShowInLockScreen</key><false/><key>ShowInNotificationCenter</key><false/><key>SoundsEnabled</key><false/></dict></array><key>PayloadDescription</key><string>" & strUTI & "通知設定</string><key>PayloadDisplayName</key><string>" & strUTI & "通知設定</string><key>PayloadIdentifier</key><string>com.apple.notificationsettings." & strUTI & "</string><key>PayloadType</key><string>com.apple.notificationsettings</string><key>PayloadUUID</key><string>" & strUUIDA & "</string><key>PayloadVersion</key><integer>1</integer></dict></array><key>PayloadDescription</key><string>" & strUTI & "通知設定</string><key>PayloadDisplayName</key><string>" & strUTI & "通知設定</string><key>PayloadIdentifier</key><string>com.apple.notificationsettings." & strUTI & "</string><key>PayloadOrganization</key><string>" & strUTI & "</string><key>PayloadRemovalDisallowed</key><false/><key>PayloadScope</key><string>User</string><key>PayloadType</key><string>Configuration</string><key>PayloadUUID</key><string>" & strUUIDB & "</string><key>PayloadVersion</key><integer>1</integer></dict></plist>" as Unicode text

##重複ファイル用の日付時間を作っておく
set strDate to (do shell script "date '+%Y%m%d_%H%M%S'") as text


tell application "Finder"
	set strFileName to "" & strUTI & "通知設定.mobileconfig"
	
	set boolFileChk to exists of (file strFileName of folder aliasFileSaveDir)
	if boolFileChk is true then
		set strFileName to "" & strUTI & "通知設定." & strDate & ".mobileconfig"
	else
		set strFileName to "" & strUTI & "通知設定.mobileconfig"
	end if
	make new file at aliasFileSaveDir with properties {name:strFileName, file type:"TEXT", creator type:"ttxt", label index:3}
	
	set aliasPlistPath to file strFileName of aliasFileSaveDir as alias
	set strPlistPath to POSIX path of aliasPlistPath as text
	(*アスキーの内容のみならここで書き込みでもOK
	close access (open for access file aliasPlistPath)
	write strPlisContents to file aliasPlistPath
	*)
	
end tell
####日本語表記があるのでUTF-8で書き込み
set objPlisContents to objNSString's stringWithString:strPlisContents
set boolPlisContents to objPlisContents's writeToFile:strPlistPath atomically:false encoding:(current application's NSUTF8StringEncoding) |error|:(missing value)
#########################################
#####クロームベースの通知設定対応部
#########################################
if boolAlertApp is true then
	tell application "Finder"
		set aliasAlertAppPath to (get application file id strAlertNotificationServiceID) as alias
	end tell
	
	tell application "Finder"
		set objInfo to info for aliasAlertAppPath
		set strUTI to bundle identifier of objInfo
	end tell
	##バンドルIDを小文字にしておく（大文字小文字判別するので２重登録は出来る）
	set objCapText to objNSString's stringWithString:strUTI
	set strUTI to (objCapText's lowercaseString()) as string
	
	
	
	
	####設定用に必要な２つのでUUIDを生成
	set strUUIDA to (do shell script "uuidgen") as text
	set strUUIDB to (do shell script "uuidgen") as text
	
	set strPlisContents to "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>ConsentText</key><dict><key>default</key><string>" & strUTI & "通知設定</string></dict><key>PayloadContent</key><array><dict><key>NotificationSettings</key><array><dict><key>BundleIdentifier</key><string>" & strUTI & "</string><key>AlertType</key><integer>0</integer><key>PreviewType</key><integer>1</integer><key>GroupingType</key><integer>1</integer><key>NotificationsEnabled</key><false/><key>ShowInCarPlay</key><false/><key>BadgesEnabled</key><false/><key>CriticalAlertEnabled</key><false/><key>ShowInLockScreen</key><false/><key>ShowInNotificationCenter</key><false/><key>SoundsEnabled</key><false/></dict></array><key>PayloadDescription</key><string>" & strUTI & "通知設定</string><key>PayloadDisplayName</key><string>" & strUTI & "通知設定</string><key>PayloadIdentifier</key><string>com.apple.notificationsettings." & strUTI & "</string><key>PayloadType</key><string>com.apple.notificationsettings</string><key>PayloadUUID</key><string>" & strUUIDA & "</string><key>PayloadVersion</key><integer>1</integer></dict></array><key>PayloadDescription</key><string>" & strUTI & "通知設定</string><key>PayloadDisplayName</key><string>" & strUTI & "通知設定</string><key>PayloadIdentifier</key><string>com.apple.notificationsettings." & strUTI & "</string><key>PayloadOrganization</key><string>" & strUTI & "</string><key>PayloadRemovalDisallowed</key><false/><key>PayloadScope</key><string>User</string><key>PayloadType</key><string>Configuration</string><key>PayloadUUID</key><string>" & strUUIDB & "</string><key>PayloadVersion</key><integer>1</integer></dict></plist>" as Unicode text
	
	##重複ファイル用の日付時間を作っておく
	set strDate to (do shell script "date '+%Y%m%d_%H%M%S'") as text
	
	
	tell application "Finder"
		set strFileName to "" & strUTI & "通知設定.mobileconfig"
		
		set boolFileChk to exists of (file strFileName of folder aliasFileSaveDir)
		if boolFileChk is true then
			set strFileName to "" & strUTI & "通知設定." & strDate & ".mobileconfig"
		else
			set strFileName to "" & strUTI & "通知設定.mobileconfig"
		end if
		make new file at aliasFileSaveDir with properties {name:strFileName, file type:"TEXT", creator type:"ttxt", label index:3}
		
		set aliasPlistPath to file strFileName of aliasFileSaveDir as alias
		set strPlistPath to POSIX path of aliasPlistPath as text
		(*アスキーの内容のみならここで書き込みでもOK
	close access (open for access file aliasPlistPath)
	write strPlisContents to file aliasPlistPath
	*)
		
	end tell
	####日本語表記があるのでUTF-8で書き込み
	set objPlisContents to objNSString's stringWithString:strPlisContents
	set boolPlisContents to objPlisContents's writeToFile:strPlistPath atomically:false encoding:(current application's NSUTF8StringEncoding) |error|:(missing value)
	
end if



####ファイルの書き込みでｔｕｒｅが返ったら成功なのでインストール
if boolPlisContents is true then
	
	tell application "System Preferences" to launch
	
	--システム環境設定が開くのを待つ
	repeat
		set doLaunchApp to get running of application "System Preferences"
		if doLaunchApp is false then
			delay 0.5
		else
			exit repeat
		end if
	end repeat
	repeat
		try
			tell application "System Preferences"
				set current pane to pane "com.apple.preferences.configurationprofiles"
				set thePaneID to id of current pane
			end tell
		on error
			delay 0.5
			tell application "System Preferences"
				set thePaneID to id of current pane
			end tell
		end try
		if thePaneID is "com.apple.preferences.configurationprofiles" then
			exit repeat
		else
			delay 0.5
		end if
	end repeat
	tell application "System Preferences"
		tell current pane
			activate
		end tell
		activate
	end tell
	tell application "Finder"
		set theCmdCom to ("open \"" & strPlistPath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
		do shell script theCmdCom
	end tell
	delay 1
	tell application "System Preferences"
		activate
		tell application "System Events"
			tell process "System Preferences"
				activate
				try
					select row 1 of table 1 of scroll area 2 of window "プロファイル"
				end try
			end tell
		end tell
	end tell
end if



tell application "Finder"
	select aliasPlistPath
end tell