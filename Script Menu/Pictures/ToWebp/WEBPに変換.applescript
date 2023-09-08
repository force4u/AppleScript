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
set numCntFile to (count of listChooseFiles) as integer
set numCntDone to numCntFile
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

####
set strBinPath to ("~/bin/libwebp/bin/cwebp") as text
set ocidBinPathStr to (refMe's NSString's stringWithString:(strBinPath))
set strBinPath to (ocidBinPathStr's stringByStandardizingPath()) as text

repeat with itemChooseFiles in listChooseFiles
	###入力パス
	set strFilePath to POSIX path of itemChooseFiles
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set strExtensionName to (ocidFilePathURL's pathExtension()) as text
	###拡張子を取って
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
	set ocidSaveFileName to (ocidBaseFileName's stringByAppendingPathExtension:("webp"))
	###
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName))
	###
	set strInputFilePath to (ocidFilePathURL's |path|()) as text
	set strOutputFilePath to (ocidSaveFilePathURL's |path|()) as text
	if strExtensionName is "jpeg" then
		### lossless noalph
		set strCommandText to ("\"" & strBinPath & "\" −lossless  −noalpha \"" & strInputFilePath & "\" -o \"" & strOutputFilePath & "\"") as text
	else if strExtensionName is "jpg" then
		### lossless noalph
		set strCommandText to ("\"" & strBinPath & "\" −lossless  −noalpha \"" & strInputFilePath & "\" -o \"" & strOutputFilePath & "\"") as text
	else
		### lossless
		set strCommandText to ("\"" & strBinPath & "\" −lossless  \"" & strInputFilePath & "\" -o \"" & strOutputFilePath & "\"") as text
	end if
	
	try
		do shell script strCommandText
	on error strErrorMes
		log strErrorMes
		
	end try
	
end repeat
