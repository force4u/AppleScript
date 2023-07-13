#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
#####################################
######ファイル保存先
#####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/IOPlatformUUID"
############################
#####属性
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######PLISTパス
#####################################
set ocidFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"ioreg.plist"
set strFilePath to (ocidFilePathURL's |path|()) as text
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:ocidFilePathURL resultingItemURL:(missing value) |error|:(reference))

#####################################
set strCommandText to "/usr/sbin/ioreg -c IOPlatformExpertDevice -a " as text
set strPlistData to (do shell script strCommandText) as text

###戻り値をストリングに
set ocidPlistStrings to refMe's NSString's stringWithString:strPlistData
###NSDATAにして
set ocidPlisStringstData to ocidPlistStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidPlisStringstData's writeToURL:ocidFilePathURL atomically:true
###PLIST初期化して
set listResults to refMe's NSPropertyListSerialization's propertyListWithData:ocidPlisStringstData options:0 format:(refMe's NSPropertyListXMLFormat_v1_0) |error|:(reference)
###各種値を取得する
set ocidPlistDataArray to item 1 of listResults
set ocidDeviceUUID to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IOPlatformUUID")
set ocidDeviceSerialNumber to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IOPlatformSerialNumber")
set ocidDeviceEntryName to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IORegistryEntryName")
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
###OSのバージョン
set ocidSystemPathArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidCoreServicePathURL to ocidSystemPathArray's firstObject()
set ocidPlistFilePathURL to ocidCoreServicePathURL's URLByAppendingPathComponent:"SystemVersion.plist"
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
set strOSversion to (ocidPlistDict's valueForKey:("ProductVersion")) as text

set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as text
set aliasIconPath to POSIX file strIconPath as alias

set strAns to ("デバイス型番：" & ocidDeviceEntryName & "\r") as text
set strAns to (strAns & "モデル番号：" & strModelStr & "\r") as text
set strAns to (strAns & "デバイスUUID：" & ocidDeviceUUID & "\r") as text
set strAns to (strAns & "シリアル番号：" & ocidDeviceSerialNumber & "\r") as text
set strAns to (strAns & "OSバージョン：" & strOSversion & "\r") as text

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
set recordResult to (display dialog "ioreg 戻り値です" with title "モデル番号" default answer strAns buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)
###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
