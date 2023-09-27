#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
githubからテンプレートになるmobileconfigをダウンロードして
値を入れてインストール画面まで
選んだプリンタでlpadminも実行します
macos14 20230927
システム設定の起動をlaunch→activateに変更
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##########################################
###PLISTからプリンター情報を取得する
##URL
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidLibraryURL to ocidURLsArray's firstObject()
set ocidPlistPathURL to ocidLibraryURL's URLByAppendingPathComponent:("Preferences/org.cups.printers.plist") isDirectory:false

###PLIST読み込み
set ocidPlistArray to refMe's NSMutableArray's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
###値を格納するためのレコード
set ocidPrinterDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidDeviceNameDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###PLISTの項目の数だけ繰り返し
repeat with itemArrayDic in ocidPlistArray
	###printer-info名を取得する
	set ocidPrinterName to (itemArrayDic's valueForKey:("printer-info"))
	###エラーよけ
	if (ocidPrinterName as text) is "" then
		set ocidPrinterName to (itemArrayDic's valueForKey:("printer-make-and-model"))
	end if
	###URIを格納
	set ocidDeviceUri to (itemArrayDic's valueForKey:("device-uri"))
	(ocidPrinterDict's setValue:(ocidDeviceUri) forKey:(ocidPrinterName))
	###デバイス名の取得
	set ocidDeviceName to (itemArrayDic's valueForKey:("printer-name"))
	(ocidDeviceNameDict's setValue:(ocidDeviceName) forKey:(ocidPrinterName))
end repeat
###ダイアログ用のALLkey
set ocidKeyList to ocidPrinterDict's allKeys()
set listKeyList to ocidKeyList as list
##########################################
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
	set listResponse to (choose from list listKeyList with title "選んでください" with prompt "デフォルトプリンタは？" default items (item 1 of listKeyList) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
###ダイアログ戻り値
set strNameKey to (item 1 of listResponse) as text
###ダイアログの戻り値からURIを取得
set ocidDeviceUri to ocidPrinterDict's valueForKey:(strNameKey)
###ダイアログの戻り値からデバイス名を取得
set ocidDeviceName to ocidDeviceNameDict's valueForKey:(strNameKey)

#################################
###【１】URLからテンプレートをダウンロード
set strFileURL to "https://raw.githubusercontent.com/force4u/AppleScript/main/Script%20Menu/Printers/DefaultPrinter/Mobileconfig/com.apple.mcxprinting.mobileconfig" as text

set ocidFileURLStr to refMe's NSString's stringWithString:(strFileURL)
set ocidFileURL to refMe's NSURL's URLWithString:(ocidFileURLStr)
#保存用にファイル名取っておく
set ocidFileName to ocidFileURL's lastPathComponent()
#%エンコードされたファイル名は戻しておく
set ocidSaveFileName to ocidFileName's stringByRemovingPercentEncoding
log "【1】Done " & ocidSaveFileName
###【２】URL読み込み
#【２-1】NSdataに読み込む（エラー制御したいため-->いきなりNSMutableDictionaryでもOK）
set ocidOption to refMe's NSDataReadingMappedIfSafe
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFileURL) options:(ocidOption) |error|:(reference)
log "【２-1】エラー" & (item 2 of listReadData)
set ocidPlistData to (item 1 of listReadData)
#【２-２】NSdataをNSPropertyListSerializationしてNSMutableDictionaryに格納する
set ocidXmlPlist to refMe's NSPropertyListXMLFormat_v1_0
set ocidPlistSerial to refMe's NSPropertyListSerialization
set ocidOption to refMe's NSPropertyListMutableContainers
set listPlistSerial to ocidPlistSerial's propertyListWithData:(ocidPlistData) options:(ocidOption) format:(ocidXmlPlist) |error|:(reference)
log "【２-2】エラー" & (item 2 of listPlistSerial)
set ocidPlistSerial to (item 1 of listPlistSerial)
##
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setDictionary:ocidPlistSerial

###【３】値を変更したい場合はここで
#バージョンに日付を入れる
set strDateno to doGetDateNo("yyyyMMdd")
set intDateno to strDateno as integer
ocidPlistDict's setValue:(intDateno) forKey:("PayloadVersion")

set ocidPayloadContentArrray to ocidPlistDict's objectForKey:("PayloadContent")
set ocidPayloadContentDict to ocidPayloadContentArrray's firstObject()
set ocidDefaultPrinter to ocidPayloadContentDict's objectForKey:("DefaultPrinter")
set strDeviceURI to ocidDeviceUri as text
ocidDefaultPrinter's setValue:(strDeviceURI) forKey:("DeviceURI")
ocidDefaultPrinter's setValue:(strNameKey) forKey:("DisplayName")


###【４】ファイルの保存先（書類フォルダ）
###保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentPathURL to ocidUserDocumentPathArray's firstObject()
#保存先ディレクトリを作る 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set ocidSaveDirPathURL to ocidDocumentPathURL's URLByAppendingPathComponent:("Mobileconfig/Printers") isDirectory:false
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
log "【４】" & (item 1 of listBoolMakeDir)
##保存ファイルのパス
set strFileName to "DefaultPrinter.mobileconfig" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName)

###【５】保存
set boolDone to ocidPlistDict's writeToURL:(ocidSaveFilePathURL) atomically:true
log "【５】" & boolDone

###【６】登録実行
tell application id "com.apple.systempreferences" to activate
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
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
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

###【９】最後にlpadminを打ってCUPSに通知する
set strDeviceName to ocidDeviceName as text
set strCommandText to ("/usr/sbin/lpadmin  -d \"" & strDeviceName & "\"") as text
try
	do shell script strCommandText
end try
log "【９】処理終了"

####日付情報の取得
to doGetDateNo(strDateFormat)
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
