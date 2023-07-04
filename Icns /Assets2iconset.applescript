#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidAppDirPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidAppDirPathURL's absoluteURL()) as alias
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
set listUTI to {"com.apple.assetcatalog"}
set strMes to ("Assets.carファイルを選んでください") as text
set strPrompt to ("Assets.carファイルを選んでください") as text
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
###
set strFilePath to POSIX path of aliasFilePath as text
###URL
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()


###保存先 デスクトップ
set ocidURLDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLDirPathArray's firstObject()
set ocidSaveContainerDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:("Assets.iconset")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveContainerDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

###内包フォルダ
set ocidSaveDirPathURL to ocidSaveContainerDirPathURL's URLByAppendingPathComponent:("Assets.iconset")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

set strSaveDirPath to ocidSaveDirPathURL's |path| as text

###一覧をJSONで取得
set strCommandText to ("/usr/bin/assetutil  -I  \"" & strFilePath & "\"") as text
set strJsonStrings to (do shell script strCommandText) as text
###JSONデータをArrayにして格納
set ocidJsonStrings to refMe's NSString's stringWithString:(strJsonStrings)
set ocidJsonData to ocidJsonStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
set listJSONS to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:(refMe's NSJSONReadingJSON5Allowed) |error|:(reference))
set ocidJSONS to item 1 of listJSONS
set ocidJsonArray to refMe's NSArray's alloc()'s initWithArray:(ocidJSONS)
###アセットのNAMEを収集
set ocidAssetTypeAllArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
set ocidNameAllArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###Arrayの数だけ繰り返し
repeat with itemJsonArray in ocidJsonArray
	set ocidAsstType to (itemJsonArray's valueForKey:"AssetType")
	if ocidAsstType ≠ (missing value) then
		(ocidAssetTypeAllArray's addObject:(ocidAsstType))
	end if
	set ocidName to (itemJsonArray's valueForKey:"Name")
	if ocidName ≠ (missing value) then
		(ocidNameAllArray's addObject:(ocidName))
	end if
end repeat
###アセットのNAME
set ocidAsstTypeSet to refMe's NSSet's setWithArray:(ocidAssetTypeAllArray)
set ocidNameSet to refMe's NSSet's setWithArray:(ocidNameAllArray)

set ocidAssetTypeArray to ocidAsstTypeSet's allObjects()
set ocidNameArray to ocidNameSet's allObjects()

###アセットのNAMEの数だけ繰り返し
set intCntNo to 0 as integer
repeat with itemName in ocidNameArray
	####ICONデータの取り出しを試す
	set strName to itemName as text
	try
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strFilePath & "\" " & strName & " -o \"" & strSaveDirPath & "\"") as text
		do shell script strCommandText
		set strNewDirPath to (strSaveDirPath & "." & intCntNo) as text
		set ocidNewDirPathStr to (refMe's NSString's stringWithString:(strNewDirPath))
		set ocidNewDirPath to ocidNewDirPathStr's stringByStandardizingPath()
		(appFileManager's moveItemAtPath:(strSaveDirPath) toPath:(ocidNewDirPathStr) |error|:(reference))
		
		set ocidSaveDirPathURL to (ocidSaveContainerDirPathURL's URLByAppendingPathComponent:("Assets.iconset"))
		set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		(ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions))
		(appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference))
		set strSaveDirPath to ocidSaveDirPathURL's |path| as text
		set intCntNo to intCntNo + 1 as integer
	end try
end repeat



return






