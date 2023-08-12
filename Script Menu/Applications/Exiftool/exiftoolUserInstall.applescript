#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 留意事項  インストール先が ~/bin/exiftool になっています
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set strVerURL to ("https://exiftool.org/ver.txt") as text
set strInstrallDirPath to ("~/bin/exiftool") as text


###インストール先
set ocidInstrallDirPathStr to refMe's NSString's stringWithString:(strInstrallDirPath)
set ocidInstrallDirPath to ocidInstrallDirPathStr's stringByStandardizingPath()
set ocidInstrallDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidInstrallDirPath) isDirectory:true)
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidInstrallDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set strInstrallDirPath to (ocidInstrallDirPathURL's |path|()) as text

###バージョンテキストURL
set ocidVerURLStr to refMe's NSString's stringWithString:(strVerURL)
set ocidVerURL to refMe's NSURL's alloc()'s initWithString:(ocidVerURLStr)
set ocidVerText to refMe's NSString's stringWithContentsOfURL:(ocidVerURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set strVer to (item 1 of ocidVerText) as text
###URLとファイル名の整形
set strDmgName to ("ExifTool-" & strVer & ".dmg") as text
set strPkgName to ("ExifTool-" & strVer & ".pkg") as text
set strVoluemPath to ("/Volumes/ExifTool-" & strVer & "") as text
set strPkgPath to ("" & strVoluemPath & "/" & strPkgName & "/Contents/Archive.pax.gz") as text
set strURL to ("https://exiftool.org/" & strDmgName & "") as text
set ocidURLStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLStr)

###ダウンロードディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダを作る
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存URL
set ocidSaveDmgFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strDmgName)
set strSaveDmgFilePathURL to (ocidSaveDmgFilePathURL's |path|()) as text
###ダウンロード
set ocidOption to refMe's NSDataReadingMappedAlways
set listDone to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidDmgData to (item 1 of listDone)
###保存
set ocidOption to refMe's NSDataWritingAtomic
set listDone to ocidDmgData's writeToURL:(ocidSaveDmgFilePathURL) options:(ocidOption) |error|:(reference)
log item 1 of listDone
####
strSaveDmgFilePathURL
set strCommandText to ("/usr/bin/hdiutil attach \"" & strSaveDmgFilePathURL & "\" -noverify -nobrowse -noautoopen") as text
do shell script strCommandText
####
set ocidExpandPkgDirPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("Expand")
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidExpandPkgDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set strExpandPkgDirPathURL to (ocidExpandPkgDirPathURL's |path|()) as text
####
set strCoommandText to "/usr/bin/bsdtar  -xzf  \"" & strPkgPath & "\" -C \"" & strExpandPkgDirPathURL & "\"" as text
do shell script strCoommandText
###
set strCoommandText to "/usr/bin/hdiutil detach  \"" & strVoluemPath & "\"  -force" as text
do shell script strCoommandText
###
set ocidDittoDirPathURL to ocidExpandPkgDirPathURL's URLByAppendingPathComponent:("usr/local/bin")
set strDittoDirPathURL to (ocidDittoDirPathURL's |path|()) as text
set strCoommandText to "/usr/bin/ditto  \"" & strDittoDirPathURL & "\"  \"" & strInstrallDirPath & "\"" as text
do shell script strCoommandText


