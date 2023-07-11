#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#	留意事項　検索条件は次回起動時に削除されます
#	前面ウィンドウのパスで拡張子検索
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##########################################
####【１】設定項目　拡張子リスト
set listExList to {"pptx", "docx", "xlsx", "pdf", "jpg", "jpeg", "png", "gif", "mp4", "mov", "mp3", "m4a", "txt", "html", "css", "js", "zip", "ai", "psd", "indd", "svg", "applescript", "scpt"} as list

##########################################
####【２】前面のFinderウィンドウのパスを取得
tell application "Finder"
	tell front Finder window
		set fileTargetPath to target
	end tell
	set aliasTargetPath to fileTargetPath as alias
end tell
set strFXScopePath to (POSIX path of aliasTargetPath) as text

##########################################
####【３】ダイアログ
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
	set listResponse to (choose from list listExList with title "選んでください" with prompt "選んでください" default items (item 1 of listExList) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strExName to (item 1 of listResponse) as text
##########################################
####【4】保存先
set ocidFilePathStr to refMe's NSString's stringWithString:(strFXScopePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set listURLvalue to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLFileContentIdentifierKey) |error|:(reference))
set intScopeNo to (item 2 of listURLvalue)
set ocidFilePath to ocidFilePathURL's |path|()
###PLIST(savedSearch)保存先 ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダを作る
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###Plist(savedSearch)保存パス
set strFileName to (strExName & ".savedSearch") as text

##########################################
####【５】PLIST=DICT= savedSearch新規作成
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
########ROOT
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set intValue to 1 as integer
ocidPlistDict's setValue:(intValue) forKey:"CompatibleVersion"
####JPEGとJPGを同一検索
if strExName starts with "jp" then
	set strValue to "(_kMDItemFileName = \"*.jp*\"c)" as text
else
	set strValue to "(_kMDItemFileName = \"*." & strExName & "\"c)" as text
end if
ocidPlistDict's setValue:(strValue) forKey:"RawQuery"
########RawQueryDict
set ocidRawQueryDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set booleValue to true as boolean
ocidRawQueryDict's setValue:(booleValue) forKey:"FinderFilesOnly"
set booleValue to false as boolean
ocidRawQueryDict's setValue:(booleValue) forKey:"UserFilesOnly"
####JPEGとJPGを同一検索
if strExName starts with "jp" then
	set strValue to "(_kMDItemFileName = \"*.jp*\"c)" as text
else
	set strValue to "(_kMDItemFileName = \"*." & strExName & "\"c)" as text
end if
ocidRawQueryDict's setValue:(strValue) forKey:"RawQuery"
set setObject to {ocidFilePath} as list
set arrayObject to {setObject} as list
ocidRawQueryDict's setObject:(arrayObject) forKey:"SearchScopes"
#
ocidPlistDict's setObject:(ocidRawQueryDict) forKey:"RawQueryDict"
########SearchCriteria
set ocidSearchCriteriaDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidSearchCriteriaDict's setValue:(intScopeNo) forKey:"FXScope"
set listValue to {ocidFilePath, "kMDQueryScopeNetworkIndexed"} as list
ocidSearchCriteriaDict's setObject:(listValue) forKey:"FXScopeArrayOfPaths"
set listValue to {ocidFilePath} as list
ocidSearchCriteriaDict's setObject:(listValue) forKey:"CurrentFolderPath"
set ocidFXCriteriaSlicesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listValue to {"com_apple_FileExtensionAttribute", 1900, 1901} as list
ocidFXCriteriaSlicesDict's setObject:(listValue) forKey:"criteria"
####JPEGとJPGを同一検索
if strExName starts with "jp" then
	set listValue to {"File Extension", "contains", "jp"} as list
else
	set listValue to {"File Extension", "is", strExName} as list
end if
ocidFXCriteriaSlicesDict's setObject:(listValue) forKey:"displayValues"
set intValue to 0 as integer
ocidFXCriteriaSlicesDict's setValue:(intValue) forKey:"rowType"
set listValue to {} as list
ocidFXCriteriaSlicesDict's setObject:(listValue) forKey:"subrows"
set listValue to {ocidFXCriteriaSlicesDict} as list
ocidSearchCriteriaDict's setObject:(listValue) forKey:"FXCriteriaSlices"
#
ocidPlistDict's setObject:(ocidSearchCriteriaDict) forKey:"SearchCriteria"
########SuggestedAttributes
set listValue to {} as list
ocidPlistDict's setObject:(listValue) forKey:"SuggestedAttributes"
########ViewSettings
set ocidViewSettingsDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set booleValue to true as boolean
ocidViewSettingsDict's setValue:(booleValue) forKey:"ContainerShowSidebar"
set booleValue to true as boolean
ocidViewSettingsDict's setValue:(booleValue) forKey:"ShowSidebar"
set booleValue to true as boolean
ocidViewSettingsDict's setValue:(booleValue) forKey:"ShowStatusBar"
set booleValue to true as boolean
ocidViewSettingsDict's setValue:(booleValue) forKey:"ShowTabView"
set booleValue to true as boolean
ocidViewSettingsDict's setValue:(booleValue) forKey:"ShowToolbar"
set recordValue to {WindowState:ocidViewSettingsDict} as record
ocidPlistDict's setObject:(recordValue) forKey:"ViewSettings"


##########################################
####【6】PLISTに変換 (optionは　0-2 Immutable /MutableContainers /MutableContainersAndLeaves)
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray

##########################################
####【7】保存
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)

##########################################
####【8】場所を示す savedSearchファイルをFinderで開く
set ocidSharedWorkSpace to refMe's NSWorkspace's sharedWorkspace()

set strUTI to "com.apple.finder"
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strUTI)
###FinderのURL
if ocidAppBundle is not (missing value) then
	set ocidAppBundlePathURL to ocidAppBundle's bundleURL()
	set strFilePath to ocidAppBundlePathURL's |path|() as text
else
	set ocidAppBundlePathURL to appNSWorkspace's URLForApplicationWithBundleIdentifier:(strUTI)
	set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppBundlePathURL)
	set strFilePath to ocidAppBundlePathURL's |path|() as text
end if
set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue
set ocidConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidConfig's setHides:ocidFalse
ocidConfig's setRequiresUniversalLinks:ocidFalse
ocidConfig's setActivates:ocidTrue
##開く
ocidSharedWorkSpace's openURLs:{ocidSaveFilePathURL} withApplicationAtURL:(ocidAppBundlePathURL) configuration:(ocidConfig) completionHandler:(missing value)

return "終了"
