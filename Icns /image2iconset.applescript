#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#https://quicktimer.cocolog-nifty.com/icefloe/2023/07/post-1e40b1.html
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

###設定項目
set listSize to {16, 32, 40, 58, 60, 64, 76, 80, 87, 114, 120, 128, 136, 152, 167, 180, 192, 256, 512, 1024} as list
set list2xSize to {32, 40, 58, 64, 76, 80, 120, 136, 152, 256, 512, 1024} as list
set list2xSizeN to {167} as list
set list3xSize to {60, 87, 114, 120, 180, 192} as list

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
set appFileManager to refMe's NSFileManager's defaultManager()
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
set listUTI to {"public.image"} as list
set aliasFilePath to (choose file with prompt "イメージファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
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
set ocidImageRep to (ocidImageRepArray's objectAtIndex:0)
##ピクセルサイズを取得
set numpixelsWidth to ocidImageRep's pixelsWide()
set numpixelsHeight to ocidImageRep's pixelsHigh()
##まずは72ppiにする
set recordNewImageSize to {width:numpixelsWidth, height:numpixelsHeight} as record
(ocidImageRep's setSize:recordNewImageSize)
##ピクセルサイズ＝ポイントサイズに変換
set ocidPixelsSize to refMe's NSMakeSize(numpixelsWidth, numpixelsWidth)
set ocidAddImage to refMe's NSImage's alloc()'s initWithSize:(ocidPixelsSize)
ocidAddImage's addRepresentation:(ocidImageRep)
##ポイントサイズを取得
set ocidImageRepSize to ocidImageRep's |size|()
set numPointWidth to width of ocidImageRepSize
set numPointHeight to height of ocidImageRepSize

####共通　保存オプション
set ocidProperty to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidProperty's setObject:(refMe's NSNumber's numberWithBool:false) forKey:(refMe's NSImageInterlaced))
(ocidProperty's setObject:(refMe's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(refMe's NSImageGamma))


############################################
##サイズ
repeat with itemSize in listSize
	set itemSize to itemSize as integer
	
	if list2xSizeN contains itemSize then
		set int2xSize to (itemSize / 2) as number
		set str2xFileName to ("icon_" & (int2xSize) & "x" & (int2xSize) & "@2x.png") as text
		set ocid2xSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(str2xFileName) isDirectory:false)
		#####
		if boolRetina is true then
			##解像度
			set intNewWidth to (itemSize / 2) as number
			set intNewHeight to (itemSize / 2) as number
		else
			set intNewWidth to (itemSize) as number
			set intNewHeight to (itemSize) as number
		end if
		##サイズ
		set ocidNewImageSize to refMe's NSMakeSize(intNewWidth, intNewHeight)
		##画像生成
		set ocidNewImage to (refMe's NSImage's alloc()'s initWithSize:(ocidNewImageSize))
		##合成
		ocidNewImage's lockFocus()
		set ocidNewRect to refMe's NSMakeRect(0, 0, intNewWidth, intNewHeight)
		(ocidAddImage's drawInRect:(ocidNewRect) fromRect:(refMe's NSZeroRect) operation:(refMe's NSCompositeCopy) fraction:(1.0))
		ocidNewImage's unlockFocus()
		##imageRepに
		set ocidNewImageRep to ocidNewImage's TIFFRepresentation()
		set ocidSaveImageRep to (refMe's NSBitmapImageRep's imageRepWithData:(ocidNewImageRep))
		##解像度
		set ocidNewImageSize to refMe's NSMakeSize((itemSize / 2), (itemSize / 2))
		(ocidSaveImageRep's setSize:ocidNewImageSize)
		##保存
		set ocidNSInlineData to (ocidSaveImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(missing value))
		set boolDone to (ocidNSInlineData's writeToURL:(ocid2xSaveFilePathURL) atomically:true)
		
		
		
	else if list2xSize contains itemSize then
		set int2xSize to (itemSize / 2) as integer
		set str2xFileName to ("icon_" & (int2xSize) & "x" & (int2xSize) & "@2x.png") as text
		set ocid2xSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(str2xFileName) isDirectory:false)
		#####
		if boolRetina is true then
			##解像度
			set intNewWidth to (itemSize / 2) as integer
			set intNewHeight to (itemSize / 2) as integer
		else
			set intNewWidth to (itemSize) as integer
			set intNewHeight to (itemSize) as integer
		end if
		##サイズ
		set ocidNewImageSize to refMe's NSMakeSize(intNewWidth, intNewHeight)
		##画像生成
		set ocidNewImage to (refMe's NSImage's alloc()'s initWithSize:(ocidNewImageSize))
		##合成
		ocidNewImage's lockFocus()
		set ocidNewRect to refMe's NSMakeRect(0, 0, intNewWidth, intNewHeight)
		(ocidAddImage's drawInRect:(ocidNewRect) fromRect:(refMe's NSZeroRect) operation:(refMe's NSCompositeCopy) fraction:(1.0))
		ocidNewImage's unlockFocus()
		##imageRepに
		set ocidNewImageRep to ocidNewImage's TIFFRepresentation()
		set ocidSaveImageRep to (refMe's NSBitmapImageRep's imageRepWithData:(ocidNewImageRep))
		##解像度
		set ocidNewImageSize to refMe's NSMakeSize((itemSize / 2), (itemSize / 2))
		(ocidSaveImageRep's setSize:ocidNewImageSize)
		##保存
		set ocidNSInlineData to (ocidSaveImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(missing value))
		set boolDone to (ocidNSInlineData's writeToURL:(ocid2xSaveFilePathURL) atomically:true)
		
	else if list3xSize contains itemSize then
		set int3xSize to (itemSize / 3) as integer
		set str3xFileName to ("icon_" & (int3xSize) & "x" & (int3xSize) & "@3x.png") as text
		set ocid3xSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(str3xFileName) isDirectory:false)
		#####
		if boolRetina is true then
			##解像度
			#	set intNewWidth to (round of (itemSize / 2) rounding down) as integer
			#	set intNewHeight to (round of (itemSize / 2) rounding down) as integer
			set intNewWidth to (itemSize / 2) as number
			set intNewHeight to (itemSize / 2) as number
		else
			set intNewWidth to (itemSize) as integer
			set intNewHeight to (itemSize) as integer
		end if
		##サイズ
		set ocidNewImageSize to refMe's NSMakeSize(intNewWidth, intNewHeight)
		##画像生成
		set ocidNewImage to (refMe's NSImage's alloc()'s initWithSize:(ocidNewImageSize))
		##合成
		ocidNewImage's lockFocus()
		set ocidNewRect to refMe's NSMakeRect(0, 0, intNewWidth, intNewHeight)
		(ocidAddImage's drawInRect:(ocidNewRect) fromRect:(refMe's NSZeroRect) operation:(refMe's NSCompositeCopy) fraction:(1.0))
		ocidNewImage's unlockFocus()
		##imageRepに
		set ocidNewImageRep to ocidNewImage's TIFFRepresentation()
		set ocidSaveImageRep to (refMe's NSBitmapImageRep's imageRepWithData:(ocidNewImageRep))
		##解像度
		set ocidNewImageSize to refMe's NSMakeSize((itemSize / 3), (itemSize / 3))
		(ocidSaveImageRep's setSize:ocidNewImageSize)
		##保存
		set ocidNSInlineData to (ocidSaveImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(missing value))
		set boolDone to (ocidNSInlineData's writeToURL:(ocid3xSaveFilePathURL) atomically:true)
	else
		set strFileName to ("icon_" & itemSize & "x" & itemSize & ".png") as text
		set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
		#####
		if boolRetina is true then
			##解像度
			set intNewWidth to (itemSize / 2) as integer
			set intNewHeight to (itemSize / 2) as integer
		else
			set intNewWidth to (itemSize) as integer
			set intNewHeight to (itemSize) as integer
		end if
		##サイズ
		set ocidNewImageSize to refMe's NSMakeSize(intNewWidth, intNewHeight)
		##画像生成
		set ocidNewImage to (refMe's NSImage's alloc()'s initWithSize:(ocidNewImageSize))
		##合成
		ocidNewImage's lockFocus()
		set ocidNewRect to refMe's NSMakeRect(0, 0, intNewWidth, intNewHeight)
		(ocidAddImage's drawInRect:(ocidNewRect) fromRect:(refMe's NSZeroRect) operation:(refMe's NSCompositeCopy) fraction:(1.0))
		ocidNewImage's unlockFocus()
		##imageRepに
		set ocidNewImageRep to ocidNewImage's TIFFRepresentation()
		set ocidSaveImageRep to (refMe's NSBitmapImageRep's imageRepWithData:(ocidNewImageRep))
		##解像度
		set ocidNewImageSize to refMe's NSMakeSize(itemSize, itemSize)
		(ocidSaveImageRep's setSize:ocidNewImageSize)
		##保存
		set ocidNSInlineData to (ocidSaveImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(missing value))
		set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) atomically:true)
		
	end if
	
	
end repeat

delay 3
set strIconSetDirPath to ocidSaveDirPathURL's |path|() as text
set strIcnsFilePath to ((ocidBaseDirPath as text) & "/" & (strBaseFileName) & ".icns") as text
set strCommandText to ("/usr/bin/iconutil --convert icns  \"" & strIconSetDirPath & "/\" -o \"" & strIcnsFilePath & "\"") as text
do shell script strCommandText


##保存先を選択状態で開く
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's selectFile:(strIcnsFilePath) inFileViewerRootedAtPath:"/"

###Finderを前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
