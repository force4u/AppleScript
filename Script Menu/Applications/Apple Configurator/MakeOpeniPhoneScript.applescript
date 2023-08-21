#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# "実行後しばらく時間がかかります３０秒"
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set strBundleID to "com.apple.configurator.ui" as text

set strFilePath to ("/Applications/Apple Configurator.app/Contents/MacOS/cfgutil") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
##ファイルの有無
set appFileManager to refMe's NSFileManager's defaultManager()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidFilePath) isDirectory:(false)

if boolDirExists = true then
	log boolDirExists & "インストール済みなので処理へ進む"
else if boolDirExists = false then
	log boolDirExists & "未インストールなのでインストール画面へ"
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	
	set strAlertMes to "Apple Configurator.appを\rインストールしてください" as text
	set recordResponse to (display alert ("【インストールが必要です】\r" & strAlertMes) buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10) as record
	set strBottonName to (button returned of recordResponse) as text
	if "OK" is equal to (strBottonName) then
		set strURL to ("https://apps.apple.com//jp/app/apple-store/id1037126344?mt=12&ls=0") as text
		tell application "Finder"
			open location strURL
		end tell
	else
		return "キャンセルしました。処理を中止します。インストールが必要な場合は再度実行してください"
	end if
end if


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirURL to ocidURLsArray's firstObject()
###PLIST保存先　ディレクトリ
set strDirName to ("Apple/Apple Configurator/") as text
set ocidSaveDirPathURL to ocidDocumentDirURL's URLByAppendingPathComponent:(strDirName)
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###PLIST保存　ファイル
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("CNFGdeviceECIDs.plist")
###
set strFilePath to (ocidSaveFilePathURL's |path|()) as text
set boolFileExists to appFileManager's fileExistsAtPath:(ocidSaveFilePathURL's |path|()) isDirectory:(false)


log "実行後しばらく時間がかかります３０秒"

set strCommandText to "'/Applications/Apple Configurator.app/Contents/MacOS/cfgutil' --format plist -f get name ECID installedApps > \"" & strFilePath & "\"" as text
try
	set strResponse to (do shell script strCommandText) as text
on error number 1
	display alert "【エラー】デバイスを有線接続してから実行してください"
	return "デバイス未接続"
end try
delay 2

##########################################
## WEBLOC 保存先


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Scripts/Finder/Open")
###
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)


##########################################
###【１】ドキュメントのパスをNSString
set ocidPlistFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidPlistFilePath to ocidPlistFilePathStr's stringByStandardizingPath()
set ocidPlistFilePathURL to refMe's NSURL's fileURLWithPath:(ocidPlistFilePath)

##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)

##########################################
### 【３】処理はここで
set ocidDevicesArray to (ocidPlistDict's valueForKey:("Devices"))
repeat with itemDevicesArray in ocidDevicesArray
	set ocidDevicesID to itemDevicesArray
	set ocidDevicesStringM to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
	(ocidDevicesStringM's setString:(ocidDevicesID))
	set ocidLength to ocidDevicesStringM's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	(ocidDevicesStringM's replaceOccurrencesOfString:("0x") withString:("00008101-00") options:(ocidOption) range:(ocidRange))
	set strDevicesStringM to ocidDevicesStringM as text
	set strSaveFileName to ("Open-iPhone.applescript") as text
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName))
	###コンポーネント初期化
	set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
	###スキーム を追加
	(ocidURLComponents's setScheme:("x-finder-iTunes"))
	###パスを追加（setHostじゃないよ）
	(ocidURLComponents's setPath:(ocidDevicesStringM))
	set ocidiTunesURL to ocidURLComponents's |URL|
	set strURL to ocidiTunesURL's absoluteString() as text
	
	
	#################################
	###スクリプト生成
	#################################
	set strDateNO to doGetDateNo("yyyyMMdd")
	set strScript to "#!/usr/bin/env osascript\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\r#com.cocolog-nifty.quicktimer.icefloe\r#" & strDateNO & "作成\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\ruse AppleScript version \"2.8\"\ruse framework \"Foundation\"\ruse scripting additions\rset strURL to \"" & strURL & "\"\rtell application \"Finder\"\r\topen location strURL\rend tell"
	set ocidScript to (refMe's NSString's stringWithString:(strScript))
	set listDone to (ocidScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF16LittleEndianStringEncoding) |error|:(reference))
end repeat

###AppKit
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:({ocidSaveFilePathURL})


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
