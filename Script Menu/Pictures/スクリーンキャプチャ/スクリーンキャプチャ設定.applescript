#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
(*
自分用設定なので、あくまでも参考用に
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appFileManager to refMe's NSFileManager's defaultManager()

set strIconURL to "https://github.com/msikma/osx-folder-icons/raw/master/icns/green.icns"
set ocidIconURL to refMe's NSURL's URLWithString:(strIconURL)
set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconURL))

####フォルダを作って　ラベル番号グリーンを指定　グリーンのアイコンを付与する
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture") isDirectory:true
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set boolDone to ocidMakeDirPathURL's setResourceValue:2 forKey:(refMe's NSURLLabelNumberKey) |error|:(missing value)
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidMakeDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

####フォルダを作って　ラベル番号グリーンを指定　グリーンのアイコンを付与する
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture/ScreenCapture") isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set boolDone to ocidMakeDirPathURL's setResourceValue:2 forKey:(refMe's NSURLLabelNumberKey) |error|:(missing value)
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidMakeDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

####フォルダを作って　ラベル番号グリーンを指定　グリーンのアイコンを付与する
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture/TemporaryItems") isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set boolDone to ocidMakeDirPathURL's setResourceValue:2 forKey:(refMe's NSURLLabelNumberKey) |error|:(missing value)
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidMakeDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

####フォルダを作って　ラベル番号グリーンを指定　グリーンのアイコンを付与する
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture/PostImage") isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set boolDone to ocidMakeDirPathURL's setResourceValue:2 forKey:(refMe's NSURLLabelNumberKey) |error|:(missing value)
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidMakeDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

###上位のフォルダをロックして　
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture") isDirectory:true
set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
set recordAttrDict to {NSFileImmutable:true} as record
set boolDone to appFileManager's setAttributes:(recordAttrDict) ofItemAtPath:(ocidMakeDirPath) |error|:(missing value)
###デフォルト用にエイリアスにしておく
set ocidMakeDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("ScreenCapture/ScreenCapture") isDirectory:true
set strDirPath to (ocidMakeDirPathURL's |path|()) as text
set aliasFilePath to (ocidMakeDirPathURL's absoluteURL()) as alias

##
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidPlistPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Preferences/com.apple.screencapture.plist") isDirectory:false
set strPlistPath to ocidPlistPathURL's |path| as text


try
	set objResponse to (choose folder "保存先指定" with prompt "フォルダを選択してください" default location (aliasFilePath) without multiple selections allowed, invisibles and showing package contents)
on error
	log "エラーしました"
	return
end try

set aliasDirPath to objResponse as alias
set strDirPath to POSIX path of aliasDirPath as text

set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" target -string  \"file\"" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" video -boolean  false" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" show-thumbnail -boolean  false" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" style -string  \"selection\"" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" name -string  \"screen\"" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" location-last  \"" & strDirPath & "\"" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" location  \"" & strDirPath & "\"" as text
do shell script strCommandText

set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" showsClicks -boolean  true" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" showsCursor -boolean  true" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" disable-shadow -boolean  true" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" last-selection-display -integer  0" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\" show-thumbnail -integer  0" as text
do shell script strCommandText

set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\"  last-selection -dict  X -integer  0" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\"  last-selection -dict-add  Height -integer  720" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\"  last-selection -dict-add  Y -integer  0" as text
do shell script strCommandText
set strCommandText to "/usr/bin/defaults write \"" & strPlistPath & "\"  last-selection -dict-add  Width -integer  1280" as text
do shell script strCommandText
