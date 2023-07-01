#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# https://quicktimer.cocolog-nifty.com/icefloe/2023/07/post-ee8fbf.html
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###設定項目
set listSize to {16, 128} as list
set list2xSize to {32, 40, 58, 64, 76, 80, 136, 152, 256, 512, 1024} as list
set list2xSizeN to {167} as list
set list3xSize to {60, 87, 114, 120, 180, 192} as list

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
###デスクトップ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidDesktopPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidDesktopPathArray's firstObject()
set alisDesktopPath to (ocidDesktopPathURL's absoluteURL()) as alias
###ダイアログ
set listUTI to {"public.image", "public.png"}
set listUTI to {"public.png"}
set listAliasFilePath to (choose file with prompt "ファイルを選んでください" default location alisDesktopPath of type listUTI with invisibles and multiple selections allowed without showing package contents) as list

############################
### 本処理
############################

repeat with itemFilePath in listAliasFilePath
	###パス
	set aliasFilePath to itemFilePath as alias
	set strFilePath to POSIX path of aliasFilePath as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set strExtensionName to (ocidFilePath's pathExtension()) as text
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	##イメージデータ取得 NSImage's
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL))
	##NSBitmapImageRep's
	##ピクセルサイズを取得
	set ocidImageRepArray to ocidImageData's representations()
	set ocidImageRep to (ocidImageRepArray's objectAtIndex:0)
	set ocidImageSize to ocidImageRep's |size|()
	set numWidth to ocidImageSize's width as number
	set numHeight to ocidImageSize's height as number
	set intPixelsWidth to ocidImageRep's pixelsWide() as integer
	set intPixelsHeight to ocidImageRep's pixelsHigh() as integer
	
	if listSize contains intPixelsWidth then
		set strNewFileName to ("icon_" & intPixelsWidth & "x" & intPixelsHeight & "." & strExtensionName & "") as text
	else if list2xSizeN contains intPixelsWidth then
		set int2xSizeW to (intPixelsWidth / 2) as number
		set int2xSizeH to (intPixelsWidth / 2) as number
		set strNewFileName to ("icon_" & int2xSizeW & "x" & int2xSizeH & "@2x." & strExtensionName & "") as text
	else if list2xSize contains intPixelsWidth then
		set int2xSizeW to (intPixelsWidth / 2) as integer
		set int2xSizeH to (intPixelsWidth / 2) as integer
		set strNewFileName to ("icon_" & int2xSizeW & "x" & int2xSizeH & "@2x." & strExtensionName & "") as text
	else if list3xSize contains intPixelsWidth then
		set int3xSizeW to (intPixelsWidth / 3) as integer
		set int3xSizeH to (intPixelsWidth / 3) as integer
		set strNewFileName to ("icon_" & int3xSizeW & "x" & int3xSizeH & "@3x." & strExtensionName & "") as text
	else
		set strNewFileName to ("icon_" & intPixelsWidth & "x" & intPixelsHeight & "." & strExtensionName & "") as text
	end if
	
	###ファイル名削除して
	set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	###新しいファイル名を付与
	set ocidNewFilePathURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strNewFileName) isDirectory:false)
	###リネーム（移動）
	set listDone to (appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidNewFilePathURL) |error|:(reference))
	if (item 1 of listDone) is false then
		log "リネームに失敗しました"
	end if
	
end repeat



##保存先を選択状態で開く
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's selectFile:(ocidContainerDirURL's |path|()) inFileViewerRootedAtPath:"/"

###Finderを前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
