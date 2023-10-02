#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(* USE
acextract
https://github.com/bartoszj/acextract
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
##################
##設定項目
set strBinPath to ("~/bin/acextract/acextract") as text

###
set ocidBinPathStr to refMe's NSString's stringWithString:(strBinPath)
set ocidBinPath to ocidBinPathStr's stringByStandardizingPath()
set strBinPath to ocidBinPath as text

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
set ocidSaveContainerDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:("Assets.acextract")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveContainerDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

###内包フォルダ
set ocidSaveDirPathURL to ocidSaveContainerDirPathURL's URLByAppendingPathComponent:("Assets.car.images")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

set strSaveDirPath to ocidSaveDirPathURL's |path| as text

try
	set strCommandText to ("\"" & strBinPath & "\" -i  \"" & strFilePath & "\"  -o \"" & strSaveDirPath & "\"") as text
	do shell script strCommandText
end try

set aliasSaveDirPath to (ocidSaveDirPathURL's absoluteURL()) as alias
tell application "Finder"
	open folder aliasSaveDirPath
end tell
return






