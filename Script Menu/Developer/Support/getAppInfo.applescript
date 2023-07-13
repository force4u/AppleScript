#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###設定項目
set strBundleID to "com.google.Chrome"


set appFileManager to refMe's NSFileManager's defaultManager()
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
			#####ダイアログを前面に
			tell current application
				set strName to name as text
			end tell
			####スクリプトメニューから実行したら
			if strName is "osascript" then
				tell application "Finder" to activate
			else
				tell current application to activate
			end if
			set strAlertMes to "アプリケーションが見つかりませんでした" as text
			set recordResponse to (display alert ("【連絡ください】\r" & strAlertMes) buttons {"OK"} default button "OK" cancel button "OK" as informational giving up after 10) as record
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
else
	set strAppPath to ocidAppPathURL's |path| as text
end if
#####################################
###
#####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's firstObject()
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/IOPlatformUUID"
############################
#####属性
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######　ioreg PLIST
#####################################
set ocidIoregFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"ioreg.plist"
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:(ocidIoregFilePathURL) resultingItemURL:(missing value) |error|:(reference))
#####################################
set strCommandText to "/usr/sbin/ioreg -c IOPlatformExpertDevice -a " as text
set strPlistData to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidPlistStrings to refMe's NSString's stringWithString:(strPlistData)
###NSDATAにして
set ocidPlisStringstData to ocidPlistStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidPlisStringstData's writeToURL:(ocidIoregFilePathURL) atomically:true

###PLIST初期化して
set listResults to refMe's NSPropertyListSerialization's propertyListWithData:ocidPlisStringstData options:0 format:(refMe's NSPropertyListXMLFormat_v1_0) |error|:(reference)
###各種値を取得する NSSingleObjectArray に留意
set ocidPlistDataArray to item 1 of listResults
set ocidDeviceUUIDArray to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IOPlatformUUID")
set ocidDeviceUUID to ocidDeviceUUIDArray's firstObject()
set ocidDeviceSerialNumberArray to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IOPlatformSerialNumber")
set ocidDeviceSerialNumber to ocidDeviceSerialNumberArray's firstObject()
set ocidDeviceEntryNameArray to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IORegistryEntryName")
set ocidDeviceEntryName to ocidDeviceEntryNameArray's firstObject()
###モデル名はNSDATAなのでテキストに解凍する
set ocidModelArray to (ocidPlistDataArray's valueForKeyPath:("IORegistryEntryChildren.model"))
set ocidModel to ocidModelArray's firstObject()
###まぁエラーになるとは思えないが
if (className() of ocidModel as text) is "NSNull" then
	set strCommandText to ("/usr/sbin/sysctl -n hw.model") as text
	set strModelStr to (do shell script strCommandText) as text
else
	set ocidModelStr to refMe's NSString's alloc()'s initWithData:(ocidModel) encoding:(refMe's NSUTF8StringEncoding)
	set strModelStr to ocidModelStr as text
end if
#####################################
######サポート情報取得
#####################################
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
###基本情報を取得
set ocidInfoDict to ocidAppBundle's infoDictionary
###PLISTのURLを取得して
# set ocidPlistPathURL to ocidAppBundlePathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
###読み込む
#set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set ocidBundleName to ocidInfoDict's valueForKey:("CFBundleName")
set ocidBundleExecutable to ocidInfoDict's valueForKey:("CFBundleExecutable")
set ocidBundleDisplayName to ocidInfoDict's valueForKey:("CFBundleDisplayName")

set ocidBundleVersion to ocidInfoDict's valueForKey:("CFBundleVersion")
set ocidBuild to ocidInfoDict's valueForKey:("DTSDKBuild")
set ocidShortVersionString to ocidInfoDict's valueForKey:("CFBundleShortVersionString")
###クローム用
set ocidChannelID to ocidInfoDict's valueForKey:("KSChannelID")
###Acrobat用
set ocidTrackName to ocidInfoDict's valueForKey:("TrackName")

#####################################
######　diskutil PLIST
#####################################
set ocidDiskutilFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"diskutil.plist"
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:(ocidDiskutilFilePathURL) resultingItemURL:(missing value) |error|:(reference))
#####################################
set strCommandText to "/usr/sbin/diskutil info -plist /" as text
set strPlistData to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidPlistStrings to refMe's NSString's stringWithString:(strPlistData)
###NSDATAにして
set ocidPlisStringstData to ocidPlistStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidPlisStringstData's writeToURL:(ocidDiskutilFilePathURL) atomically:true
###PLIST初期化して
set listResults to refMe's NSPropertyListSerialization's propertyListWithData:ocidPlisStringstData options:0 format:(refMe's NSPropertyListXMLFormat_v1_0) |error|:(reference)
###各種値を取得する NSSingleObjectArray に留意
set ocidPlistDataArray to item 1 of listResults
###ボリューム名 他
set ocidVolumeName to (ocidPlistDataArray's valueForKey:"VolumeName")
set ocidDiskUUID to (ocidPlistDataArray's valueForKey:"DiskUUID")
set ocidVolumeUUID to (ocidPlistDataArray's valueForKey:"VolumeUUID")
set ocidFilesystemName to (ocidPlistDataArray's valueForKey:"FilesystemName")
set ocidFileVault to (ocidPlistDataArray's valueForKey:"FileVault")
set ocidEncryption to (ocidPlistDataArray's valueForKey:"Encryption")
###サイズ
set ocidTotalSize to (ocidPlistDataArray's valueForKey:"TotalSize")
set intGB to "1073741824" as integer
set ocidGB to (refMe's NSNumber's numberWithInteger:intGB)
set intTotalSize to ((ocidTotalSize's doubleValue as real) / (ocidGB's doubleValue as real)) as integer
###残
set ocidAPFSContainerFree to (ocidPlistDataArray's valueForKey:"APFSContainerFree")
set intGB to "1073741824" as integer
set ocidGB to (refMe's NSNumber's numberWithInteger:intGB)
set intContainerFree to ((ocidAPFSContainerFree's doubleValue as real) / (ocidGB's doubleValue as real)) as integer
########################
##メモリサイズを調べる
set ocidProcessInfo to refMe's NSProcessInfo's processInfo()
set realMemoryByte to ocidProcessInfo's physicalMemory() as real
set realGB to "1073741824" as real
set intPhysicalMemory to realMemoryByte / realGB as integer
##ユーザー情報
set ocidEnvDict to ocidProcessInfo's environment()
set strHOME to (ocidEnvDict's valueForKey:"HOME") as text
set strUSER to (ocidEnvDict's valueForKey:"USER") as text
set strLOGNAME to (ocidEnvDict's valueForKey:"LOGNAME") as text
set strTMPDIR to (ocidEnvDict's valueForKey:"TMPDIR") as text
########################
###OSのバージョン
set ocidSystemPathArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidCoreServicePathURL to ocidSystemPathArray's firstObject()
set ocidPlistFilePathURL to ocidCoreServicePathURL's URLByAppendingPathComponent:"SystemVersion.plist"
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
set strOSversion to (ocidPlistDict's valueForKey:("ProductVersion")) as text
########################
###configCodeにする（後ろから４文字）
set intTextlength to (ocidDeviceSerialNumber's |length|) as integer
set ocidRenge to refMe's NSMakeRange((intTextlength - 4), 4)
set strConfigCode to (ocidDeviceSerialNumber's substringWithRange:(ocidRenge)) as text
###モデル名を取得　configCode
set strURL to "https://support-sp.apple.com/sp/product"
set ocidURLStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLStr)
####コンポーネント
set ocidComponents to refMe's NSURLComponents's alloc()'s initWithURL:(ocidURL) resolvingAgainstBaseURL:false
set ocidComponentArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("cc") value:(strConfigCode)
ocidComponentArray's addObject:(ocidQueryItem)
###
set ocidLocale to refMe's NSLocale's currentLocale()
set ocidLocaleID to ocidLocale's localeIdentifier()
set ocidQueryItem to (refMe's NSURLQueryItem's alloc()'s initWithName:("lang") value:(ocidLocaleID))
(ocidComponentArray's addObject:(ocidQueryItem))
###検索クエリーとして追加
(ocidComponents's setQueryItems:(ocidComponentArray))
####コンポーネントをURLに展開
set ocidNewURL to ocidComponents's |URL|()
log ocidNewURL's absoluteString() as text

###XML読み込み
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidNewURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOTエレメント
set ocidRootElement to ocidReadXMLDoc's rootElement()
###configCodeからモデル名を取得
set ocidConfigCode to ocidRootElement's elementsForName:"configCode"
set strConfigCode to ocidConfigCode's stringValue as text
####CPUタイプ
set strCPU to CPU type of (system info) as text
log strConfigCode as text

########################
###ダイアログ
set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as text
set aliasIconPath to POSIX file strIconPath as alias


set strAns to ("モデル名：" & strConfigCode & "\r") as text
set strAns to (strAns & "OSバージョン：" & strOSversion & "\r") as text
set strAns to (strAns & "物理メモリ：" & intPhysicalMemory & " GB\r") as text
set strAns to (strAns & "CFBundleExecutable：" & ocidBundleExecutable & "\r") as text
set strAns to (strAns & "ShortVersion：" & ocidShortVersionString & "\r") as text
set strAns to (strAns & "Path：" & strAppPath & "\r") as text


#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

###ダイアログ
set recordResult to (display dialog "戻り値です\rコピーしてメールかメッセージを送ってください\r" with title "モデル番号" default answer strAns buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 30 with icon aliasIconPath without hidden answer)
###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
