#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###アプリケーションのバンドルID
set strBundleID to "com.skype.skype"



################################
### 保存先
################################
set appFileManager to refMe's NSFileManager's defaultManager()
###ライブラリ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Scripts/Applications/Skype/Open")
##フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set aliasSaveDirPathURL to (ocidSaveDirPathURL's absoluteURL()) as alias
################################
### バンドルIDからアプリケーションURL
################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if
################################
### アプリケーションのアイコンパス
################################
###アイコン名をPLISTから取得
set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
###ICONのURLにして
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
###拡張子の有無チェック
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
###ICONファイルが実際にあるか？チェック
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
###ICONがみつかない時用にデフォルトを用意する
if boolExists is false then
	set strIconFilePath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericURLIcon.icns" as text
	set ocidIconFilePathStr to refMe's NSString's stringWithString:(strIconFilePath)
	set ocidIconFilePath to ocidIconFilePathStr's stringByStandardizingPath()
	set ocidIconFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconFilePath) isDirectory:false)
	set aliasIconFilePath to ocidIconFilePathURL's absoluteURL() as alias
else
	set aliasIconFilePath to ocidIconFilePathURL's absoluteURL() as alias
end if
################################
### アイコンデータ取得
################################
set ocidIconData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconFilePathURL))
################################
### webloc作成
################################
##設定項目
set strFileName to ("Skypeステータス") as text
set strURL to ("https://support.skype.com/en/status/") as text
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
ocidPlistDict's setValue:(strFileName) forKey:("title")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")

#########################
####weblocファイルを作る
set strWeblocFileName to (strFileName & ".webloc") as text
set ocidWeblocFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strWeblocFileName)
set ocidWeblocFilePath to ocidWeblocFilePathURL's |path|()
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidWeblocFilePathURL) options:0 |error|:(reference)
#########################
####アイコン付与
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidWeblocFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption)
################################
### webloc作成
################################
##設定項目
set strFileName to ("SkypeWeb") as text
set strURL to ("https://web.skype.com") as text
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
ocidPlistDict's setValue:(strFileName) forKey:("title")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")

#########################
####weblocファイルを作る
set strWeblocFileName to (strFileName & ".webloc") as text
set ocidWeblocFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strWeblocFileName)
set ocidWeblocFilePath to ocidWeblocFilePathURL's |path|()
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidWeblocFilePathURL) options:0 |error|:(reference)
#########################
####アイコン付与
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidWeblocFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption)
################################
### webloc作成
################################
##設定項目
set strFileName to ("Skypeアカウント") as text
set strURL to ("https://go.skype.com/myaccount") as text
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
ocidPlistDict's setValue:(strFileName) forKey:("title")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")

#########################
####weblocファイルを作る
set strWeblocFileName to (strFileName & ".webloc") as text
set ocidWeblocFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strWeblocFileName)
set ocidWeblocFilePath to ocidWeblocFilePathURL's |path|()
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidWeblocFilePathURL) options:0 |error|:(reference)
#########################
####アイコン付与
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidWeblocFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption)
################################
### webloc作成
################################
##設定項目
set strFileName to ("Skype会議") as text
set strURL to ("https://go.skype.com/meetnow.accessurl") as text
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
ocidPlistDict's setValue:(strFileName) forKey:("title")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")

#########################
####weblocファイルを作る
set strWeblocFileName to (strFileName & ".webloc") as text
set ocidWeblocFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strWeblocFileName)
set ocidWeblocFilePath to ocidWeblocFilePathURL's |path|()
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidWeblocFilePathURL) options:0 |error|:(reference)
#########################
####アイコン付与
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidWeblocFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption)




#########################
####保存先を開く
tell application "Finder"
	set aliasSaveFile to (file strWeblocFileName of folder aliasSaveDirPathURL) as alias
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPathURL
	set selection to aliasSaveFile
end tell

#########################
####バージョンで使う日付
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
