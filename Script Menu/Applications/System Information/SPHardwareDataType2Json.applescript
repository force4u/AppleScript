#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
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
######PLISTパス
#####################################
set ocidFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"SPHardwareDataType.json"
set strFilePath to (ocidFilePathURL's |path|()) as text
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:ocidFilePathURL resultingItemURL:(missing value) |error|:(reference))
#####################################
######コマンド実行
#####################################
set strCommandText to "/usr/sbin/system_profiler  SPHardwareDataType -json"
set strPlistData to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidPlistStrings to refMe's NSString's stringWithString:strPlistData
###NSDATAにして
set ocidPlisStringstData to ocidPlistStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidPlisStringstData's writeToURL:ocidFilePathURL atomically:true

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
