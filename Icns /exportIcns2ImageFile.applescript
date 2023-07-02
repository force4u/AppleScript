#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*
ICONセットのサイズ
https://developer.apple.com/design/human-interface-guidelines/app-icons
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

############################
### Retinaチェック
set ocidScreenArray to refMe's NSScreen's screens()
set appMainScreen to refMe's NSScreen's mainScreen()
set ocidDescription to appMainScreen's deviceDescription()
set recordDeviceResolution to refMe's NSSizeFromCGSize(ocidDescription's valueForKey:(refMe's NSDeviceResolution))
set intDeviceResolution to width of recordDeviceResolution as integer
if intDeviceResolution ≥ 144 then
	set boolRetina to true as boolean
	log "Retinaディスプレイです"
else
	set boolRetina to false as boolean
end if
log "解像度：" & intDeviceResolution

###デフォルトロケーション
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidUserDocumentPathArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
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

####ダイアログを出す
set listUTI to {"com.apple.icns"} as list
set aliasFilePath to (choose file with prompt "アイコンファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
###パス関連
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFileName to ocidFilePath's lastPathComponent()
set ocidBaseDirPath to ocidFilePath's stringByDeletingLastPathComponent()
###ファイル名-拡張子ベースファイル名
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
set strBaseFileName to ocidBaseFileName as text
set ocidBaseFileName to ocidBaseFileName's stringByAppendingPathExtension:("iconset")

set ocidBaseFileNameStr to ocidBaseFileName's UTF8String()
set ocidSaveDirPath to ocidBaseDirPath's stringByAppendingPathComponent:(ocidBaseFileNameStr)
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)

###保存ディレクトリ
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

###読み込むイメージURL
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
##NSIMAGEに読み込む
set ocidReadImage to refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set ocidImageRepArray to ocidReadImage's representations()

repeat with itemImageRep in ocidImageRepArray
	##ピクセルサイズを取得
	set numPixelsWidth to itemImageRep's pixelsWide()
	set numPixelsHeight to itemImageRep's pixelsHigh()
	set ocidPixelsSize to refMe's NSMakeSize(numPixelsWidth, numPixelsHeight)
	###ファイル名
	set strFileName to ("icon_" & (numPixelsWidth) & "x" & (numPixelsHeight) & ".png") as text
	###保存パスURL
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
	
	####共通　保存オプション
	set ocidProperty to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	set ocidColorSpace to refMe's NSColorSpace's displayP3ColorSpace()
	set ocidColorSpaceData to ocidColorSpace's colorSyncProfile()
	(ocidProperty's setObject:(ocidColorSpaceData) forKey:(refMe's NSImageColorSyncProfileData))
	(ocidProperty's setObject:(refMe's NSNumber's numberWithBool:false) forKey:(refMe's NSImageInterlaced))
	(ocidProperty's setObject:(refMe's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(refMe's NSImageGamma))
	##保存
	set ocidNSInlineData to (itemImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(missing value))
	set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) atomically:true)
	
end repeat

##保存先を選択状態で開く
set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
ocidSharedWorkspace's selectFile:(ocidSaveDirPathURL's |path|()) inFileViewerRootedAtPath:"/"


###Finderを前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
