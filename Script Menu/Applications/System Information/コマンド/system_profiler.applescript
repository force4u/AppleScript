#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#		終了するまで2分から3分程度かかります
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#####################################
######ファイル保存先
#####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/system_profiler"
############################
#####属性
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######コマンド実行 データタイプ取得
#####################################
set strCommandText to "/usr/sbin/system_profiler  -listDataTypes"
set strComRespose to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidComRespose to refMe's NSString's stringWithString:(strComRespose)
set ocidChrSet to refMe's NSCharacterSet's characterSetWithCharactersInString:("\r")
set ocidDataTypesArray to ocidComRespose's componentsSeparatedByCharactersInSet:(ocidChrSet)
#####################################
######コマンド実行 データタイプの数だけ繰返
#####################################
repeat with itemIntNo from 1 to ((count of ocidDataTypesArray) - 1) by 1
	####データタイプ
	set strDataTypes to (ocidDataTypesArray's objectAtIndex:itemIntNo) as text
	#####################################
	######PLISTパス
	#####################################
	set strFileName to (strDataTypes & ".plist") as text
	set ocidFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName))
	set strFilePath to (ocidFilePathURL's |path|()) as text
	###古いファイルはゴミ箱に
	set boolResults to (appFileManager's trashItemAtURL:(ocidFilePathURL) resultingItemURL:(missing value) |error|:(reference))
	#####################################
	######コマンド実行
	#####################################
	set strCommandText to "/usr/sbin/system_profiler  " & strDataTypes & " -xml"
	set strResponse to (do shell script strCommandText) as text
	###戻り値をストリングに
	set ocidResponse to (refMe's NSString's stringWithString:(strResponse))
	###NSDATAにして
	set ocidResponseStringstData to (ocidResponse's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
	###ファイルに書き込み(使い回し用）-->不要な場合は削除して
	(ocidResponseStringstData's writeToURL:(ocidFilePathURL) atomically:true)
	#####################################
	######JSONパス
	#####################################
	set strFileName to (strDataTypes & ".json") as text
	set ocidFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName))
	set strFilePath to (ocidFilePathURL's |path|()) as text
	###古いファイルはゴミ箱に
	set boolResults to (appFileManager's trashItemAtURL:(ocidFilePathURL) resultingItemURL:(missing value) |error|:(reference))
	#####################################
	######コマンド実行
	#####################################
	set strCommandText to "/usr/sbin/system_profiler  " & strDataTypes & " -json"
	set strResponse to (do shell script strCommandText) as text
	###戻り値をストリングに
	set ocidResponse to (refMe's NSString's stringWithString:(strResponse))
	###NSDATAにして
	set ocidResponseStringstData to (ocidResponse's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
	###ファイルに書き込み(使い回し用）-->不要な場合は削除して
	(ocidResponseStringstData's writeToURL:(ocidFilePathURL) atomically:true)
end repeat



tell application "Finder"
	###書類フォルダ
	set aliasDocumentsPath to (path to documents folder from user domain) as alias
end tell
set strDocumentsPath to (POSIX path of aliasDocumentsPath) as text
set strSaveDirPath to (strDocumentsPath & "Apple/system_profiler/") as text
set aliasOpenDirPath to (POSIX file strSaveDirPath) as alias

####場所を表示
tell application "Finder"
	open folder aliasOpenDirPath
	
end tell


return "終了しました"
(*
/usr/sbin/system_profiler -listDataTypes

SPParallelATADataType
SPUniversalAccessDataType
SPSecureElementDataType
SPApplicationsDataType
SPAudioDataType
SPBluetoothDataType
SPCameraDataType
SPCardReaderDataType
SPiBridgeDataType
SPDeveloperToolsDataType
SPDiagnosticsDataType
SPDisabledSoftwareDataType
SPDiscBurningDataType
SPEthernetDataType
SPExtensionsDataType
SPFibreChannelDataType
SPFireWireDataType
SPFirewallDataType
SPFontsDataType
SPFrameworksDataType
SPDisplaysDataType
SPHardwareDataType
SPInstallHistoryDataType
SPInternationalDataType
SPLegacySoftwareDataType
SPNetworkLocationDataType
SPLogsDataType
SPManagedClientDataType
SPMemoryDataType
SPNVMeDataType
SPNetworkDataType
SPPCIDataType
SPParallelSCSIDataType
SPPowerDataType
SPPrefPaneDataType
SPPrintersSoftwareDataType
SPPrintersDataType
SPConfigurationProfileDataType
SPRawCameraDataType
SPSASDataType
SPSerialATADataType
SPSPIDataType
SPSmartCardsDataType
SPSoftwareDataType
SPStartupItemDataType
SPStorageDataType
SPSyncServicesDataType
SPThunderboltDataType
SPUSBDataType
SPNetworkVolumeDataType
SPWWANDataType
SPAirPortDataType
*)









