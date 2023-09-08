#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias

set listUTI to {"public.tiff"}

set strMes to ("イメージファイルを選んでください") as text
set strPrompt to ("イメージファイルを選んでください") as text


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
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
##ファイル名
set ocidFileName to ocidFilePathURL's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
##コンテナディレクトリ
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
##保存先
set ocidSaveDirPathURL to ocidContainerDirURL's URLByAppendingPathComponent:(ocidBaseFileName)
###保存ディレクトリ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

set ocidReadData to refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set ocidReadImageRepArray to ocidReadData's representations()
set intPageCnt to (ocidReadImageRepArray's |count|()) as integer

if intPageCnt > 1 then
	log "マルチページです"
else if intPageCnt = 1 then
	return "処理する必要ありません"
end if

repeat with numNo from 1 to intPageCnt by 1
	##ページ毎の保存先パスURL
	set strZeroSup to "000" as text
	set strZeroSup to (strZeroSup & (numNo as text)) as text
	set strZeroSup to (text -3 through -1 of strZeroSup) as text
	set ocidSaveFileName to (ocidBaseFileName's stringByAppendingPathExtension:(strZeroSup))
	set ocidSaveFileName to (ocidSaveFileName's stringByAppendingPathExtension:("tiff"))
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName) isDirectory:false)
	##各ページのデータを取り出して
	set ocidPageData to (ocidReadImageRepArray's objectAtIndex:(numNo - 1))
	###データにするプロパティ
	set ocidPropertyDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidPropertyDict's setObject:(refMe's NSTIFFCompressionNone) forKey:(refMe's NSImageCompressionMethod))
	set ocidOption to refMe's NSDataReadingMappedAlways
	set ocidColorSyncData to (refMe's NSData's dataWithContentsOfFile:("/System/Library/ColorSync/Profiles/Display P3.icc") options:(ocidOption) |error|:(reference))
	(ocidPropertyDict's setObject:(ocidColorSyncData) forKey:(refMe's NSImageColorSyncProfileData))
	##データにして
	set ocidNSInlineData to (ocidPageData's representationUsingType:(refMe's NSBitmapImageFileTypeTIFF) |properties|:(ocidPropertyDict))
	##個別ファイルとして保存する
	set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference))
	
end repeat

##保存先を選択状態で開く
set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
ocidSharedWorkspace's selectFile:(ocidSaveDirPathURL's |path|()) inFileViewerRootedAtPath:"/"


