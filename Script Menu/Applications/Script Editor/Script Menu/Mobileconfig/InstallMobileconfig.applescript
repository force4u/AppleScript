#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###【１】URL
set strFileURL to "https://raw.githubusercontent.com/force4u/AppleScript/main/Script%20Menu/Applications/Script%20Editor/Script%20Menu/Mobileconfig/Mobileconfig/com.apple.scriptmenu.mobileconfig" as text

set ocidFileURLStr to refMe's NSString's stringWithString:(strFileURL)
set ocidFileURL to refMe's NSURL's URLWithString:(ocidFileURLStr)
#保存用にファイル名取っておく
set ocidFileName to ocidFileURL's lastPathComponent()
#%エンコードされたファイル名は戻しておく
set ocidSaveFileName to ocidFileName's stringByRemovingPercentEncoding

###【２】URL読み込み
#【２-1】NSdataに読み込む（エラー制御したいため-->いきなりNSMutableDictionaryでもOK）
set ocidOption to refMe's NSDataReadingMappedIfSafe
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFileURL) options:(ocidOption) |error|:(reference)
log "【２-1】" & (item 2 of listReadData)
set ocidPlistData to (item 1 of listReadData)
#【２-２】NSdataをNSPropertyListSerializationしてNSMutableDictionaryに格納する
set ocidXmlPlist to refMe's NSPropertyListXMLFormat_v1_0
set ocidPlistSerial to refMe's NSPropertyListSerialization
set ocidOption to refMe's NSPropertyListMutableContainers
set listPlistSerial to ocidPlistSerial's propertyListWithData:(ocidPlistData) options:(ocidOption) format:(ocidXmlPlist) |error|:(reference)
log "【２-2】" & (item 2 of listPlistSerial)
set ocidPlistSerial to (item 1 of listPlistSerial)
##
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setDictionary:ocidPlistSerial

###【３】値を変更したい場合はここで
set ocidPayloadArray to ocidPlistDict's objectForKey:("PayloadContent")





###【４】ファイルの保存先（書類フォルダ）
###保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentPathURL to ocidUserDocumentPathArray's firstObject()
#保存先ディレクトリを作る 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set ocidSaveDirPathURL to ocidDocumentPathURL's URLByAppendingPathComponent:("Mobileconfig") isDirectory:false
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
log "【４】" & (item 1 of listBoolMakeDir)
##保存ファイルのパス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName)

###【５】保存
set boolDone to ocidPlistDict's writeToURL:(ocidSaveFilePathURL) atomically:true
log "【５】" & boolDone

###【６】登録実行
tell application id "com.apple.systempreferences" to launch
tell application id "com.apple.systempreferences"
	activate
	reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
end tell

###FinderのURL
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set strBundleID to "com.apple.finder" as text
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
###パネルのURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("x-apple.systempreferences")
ocidURLComponents's setPath:("com.apple.preferences.configurationprofiles")
set ocidOpenAppURL to ocidURLComponents's |URL|
set strOpenAppURL to ocidOpenAppURL's absoluteString() as text
###ファイルURLとパネルのURLをArrayにしておく
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenUrlArray's insertObject:(ocidSaveFilePathURL) atIndex:0
ocidOpenUrlArray's insertObject:(ocidOpenAppURL) atIndex:1
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	set theCmdCom to ("open \"" & strFilePath & "\" | open \"" & strOpenAppURL & "\"") as text
	do shell script theCmdCom
else
	###FinderでファイルとURLを同時に開く
	set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
	ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
	appShardWorkspace's openURLs:(ocidOpenUrlArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
end if
log "【６】Done"

###【７】保存ファイル表示
#選択状態で開く
set boolDone to appShardWorkspace's selectFile:(ocidSaveFilePathURL's |path|) inFileViewerRootedAtPath:(ocidDocumentPathURL's |path|)
log "【７】" & boolDone

###【８】システム設定を前面に
###システム設定を前面に
set ocidRunningApp to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApp's runningApplicationsWithBundleIdentifier:("com.apple.systempreferences"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
set boolDone to ocidApp's active
log "【８】" & boolDone
