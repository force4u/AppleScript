#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application

##############################
# 入力　ダイアログ
##############################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
#####ダイアログを前面に
set strName to (name of current application) as text
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listChooseFiles to (choose file with prompt "ファイルを選んでください" default location aliasDefaultLocation of type {"public.image"} with invisibles and multiple selections allowed without showing package contents) as list
##############################
#出力先ディレクトリ　ダイアログ
##############################
#####ダイアログを前面に
set strName to (name of current application) as text
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set aliasChooseFile to (item 1 of listChooseFiles) as alias
set strSaveDirPath to (POSIX path of aliasChooseFile) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)
set ocidContainerDirPathURL to ocidSaveDirPathURL's URLByDeletingLastPathComponent()
set ocidContainerDirPathURL to ocidContainerDirPathURL's URLByDeletingLastPathComponent()
set aliasDefaultLocation to (ocidContainerDirPathURL's absoluteURL()) as alias
###
set strMes to "フォルダを選んでください" as text
set strPrompt to "フォルダを選択してください" as text
try
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###
set strSaveDirPath to (POSIX path of aliasResponse) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)

repeat with itemChooseFiles in listChooseFiles
	###入力パス
	set strFilePath to POSIX path of itemChooseFiles
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	#####拡張子を取って
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
	set ocidSaveFileName to (ocidBaseFileName's stringByAppendingPathExtension:("jpeg"))
	######
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName))
	####################################
	###イメージデータ展開
	####################################
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listReadData to (refMe's NSData's dataWithContentsOfURL:(ocidFilePathURL) options:(ocidOption) |error|:(reference))
	set ocidReadData to (item 1 of listReadData)
	set ocidReadImageRep to (refMe's NSBitmapImageRep's alloc()'s initWithData:(ocidReadData))
	############################
	set ocidProperties to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	####NSImageColorSyncProfileData
	set ocidGetValue to (ocidReadImageRep's valueForProperty:(refMe's NSImageColorSyncProfileData))
	(ocidProperties's setValue:(ocidGetValue) forKey:(refMe's NSImageColorSyncProfileData))
	####NSImageEXIFData
	set ocidGetValue to (ocidReadImageRep's valueForProperty:(refMe's NSImageEXIFData))
	(ocidProperties's setValue:(ocidGetValue) forKey:(refMe's NSImageEXIFData))
	####NSImageCompressionFactor
	(ocidProperties's setValue:(1) forKey:(refMe's NSImageCompressionFactor))
	####NSImageFallbackBackgroundColor
	set ocidGetValue to (refMe's NSColor's colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0)
	(ocidProperties's setValue:(ocidGetValue) forKey:(refMe's NSImageFallbackBackgroundColor))
	####NSImageGamma
	set ocidGetValue to (ocidReadImageRep's valueForProperty:(refMe's NSImageGamma))
	(ocidProperties's setValue:(ocidGetValue) forKey:(refMe's NSImageGamma))
	####NSImageProgressive
	(ocidProperties's setValue:(0.0) forKey:(refMe's NSImageProgressive))
	#####JPEGデータに変換
	set ocidSaveData to (ocidReadImageRep's representationUsingType:(refMe's NSBitmapImageFileTypeJPEG) |properties|:(ocidProperties))
	###保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set ocidWroteToFileDone to (ocidSaveData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	##開放
	set ocidSaveData to ""
	set ocidReadImageRep to ""
end repeat
