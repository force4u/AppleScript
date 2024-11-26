#!/usr/bin/env osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions



on run (argFilePathAndImageFilePath)
	if (argFilePathAndImageFilePath as text) is "" then
		log doPrintHelp()
		return 0
	else if (count of argFilePathAndImageFilePath) < 2 then
		log "引数が足りません"
		log doPrintHelp()
		return 0
	end if
	set {argSetIconFilePath, argFilePaht} to argFilePathAndImageFilePath
	
	set strSetIconFilePath to argSetIconFilePath as text
	set strFilePath to argFilePaht as text
	
	set appShardWorkspace to current application's NSWorkspace's sharedWorkspace()
	set appFileManager to current application's NSFileManager's defaultManager()
	#設定項目作成するアイコンサイズ
	set listPxSize to {32, 40, 58, 60, 64, 76, 80, 87, 114, 120, 128, 136, 152, 167, 180, 192, 256, 512, 1024, 2048} as list
	
	
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePathStr to (ocidFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
	set ocidSaveDirName to ocidBaseFileName's stringByAppendingPathExtension:("iconset")
	set ocidSaveIcnsFileName to ocidBaseFileName's stringByAppendingPathExtension:("icns")
	#保存先
	set ocidURLsArray to (appFileManager's URLsForDirectory:(current application's NSPicturesDirectory) inDomains:(current application's NSUserDomainMask))
	set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
	set ocidIconDirPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:("Icons/MakeIcon") isDirectory:(true)
	#iconsetディレクトリ
	set ocidSaveDirPathURL to ocidIconDirPathURL's URLByAppendingPathComponent:(ocidSaveDirName) isDirectory:(true)
	set strSaveDirPath to ocidSaveDirPathURL's |path| as text
	#icnsファイルパス
	set ocidSaveIcnsFilePathURL to ocidIconDirPathURL's URLByAppendingPathComponent:(ocidSaveIcnsFileName) isDirectory:(false)
	set ocidSaveIcnsFilePath to ocidSaveIcnsFilePathURL's |path|()
	set strSaveIcnsFilePath to ocidSaveIcnsFilePath as text
	#iconsetのフォルダを作っておく
	set ocidAttrDict to current application's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(448) forKey:(current application's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	
	#カラー
	set strIccFilePath to ("/System/Library/ColorSync/Profiles/sRGB Profile.icc") as text
	set ocidIccFilePathStr to current application's NSString's stringWithString:(strIccFilePath)
	set ocidIccFilePath to ocidIccFilePathStr's stringByStandardizingPath
	set ocidIccFilePathURL to current application's NSURL's alloc()'s initFileURLWithPath:(ocidIccFilePath) isDirectory:(false)
	set ocidProfileData to current application's NSData's alloc()'s initWithContentsOfURL:(ocidIccFilePathURL)
	
	#NSADATA
	set ocidOption to (current application's NSDataReadingMappedIfSafe)
	set listResponse to current application's NSData's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(ocidOption) |error|:(reference)
	set ocidReadData to (item 1 of listResponse)
	
	#NSIMAGE
	set ocidReadImage to current application's NSImage's alloc()'s initWithData:(ocidReadData)
	set ocidReadImgRep to (ocidReadImage's representations)'s firstObject()
	set numpixelsWidth to ocidReadImgRep's pixelsWide()
	set numpixelsHeight to ocidReadImgRep's pixelsHigh()
	set ocidSetSize to current application's NSSize's NSMakeSize(numpixelsWidth, numpixelsHeight)
	ocidReadImgRep's setSize:(ocidSetSize)
	set ocidFromCopyRect to current application's NSRect's NSMakeRect(0, 0, numpixelsWidth, numpixelsHeight)
	
	#元になる2048pxの画像作成
	set ocidFullImageRep to (current application's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(2048) pixelsHigh:(2048) bitsPerSample:8 samplesPerPixel:4 hasAlpha:(true) isPlanar:(false) colorSpaceName:(current application's NSCalibratedRGBColorSpace) bitmapFormat:(current application's NSBitmapFormatAlphaFirst) bytesPerRow:0 bitsPerPixel:32)
	ocidFullImageRep's setProperty:(current application's NSImageColorSyncProfileData) withValue:(ocidProfileData)
	#編集開始
	current application's NSGraphicsContext's saveGraphicsState()
	set ocidSetImageContext to (current application's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidFullImageRep))
	ocidSetImageContext's setImageInterpolation:(current application's NSImageInterpolationHigh)
	ocidSetImageContext's setColorRenderingIntent:(current application's NSColorRenderingIntentSaturation)
	ocidSetImageContext's setCompositingOperation:(current application's NSCompositingOperationMultiply)
	ocidSetImageContext's setShouldAntialias:(true)
	current application's NSGraphicsContext's setCurrentContext:(ocidSetImageContext)
	set ocidDrawPasteRect to current application's NSRect's NSMakeRect(0, 0, 2048, 2048)
	(ocidReadImgRep's drawInRect:(ocidDrawPasteRect) fromRect:(ocidFromCopyRect) operation:(current application's NSCompositingOperationSourceOver) fraction:(1.0) respectFlipped:(false) hints:(missing value))
	#編集終了
	current application's NSGraphicsContext's restoreGraphicsState()
	#編集後の元画像の矩形
	set ocidFromCopyRect to current application's NSRect's NSMakeRect(0, 0, 2048, 2048)
	
	####################
	#iconset作成開始
	####################
	#16サイズだけ個別で作成
	set itemPxSize to 16 as integer
	
	set ocidIconImageRep to (current application's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(itemPxSize) pixelsHigh:(itemPxSize) bitsPerSample:8 samplesPerPixel:4 hasAlpha:(true) isPlanar:(false) colorSpaceName:(current application's NSCalibratedRGBColorSpace) bitmapFormat:(current application's NSBitmapFormatAlphaFirst) bytesPerRow:0 bitsPerPixel:32)
	ocidIconImageRep's setProperty:(current application's NSImageColorSyncProfileData) withValue:(ocidProfileData)
	#ペースト位置計算
	if numpixelsWidth = numpixelsHeight then
		set ocidDrawPasteRect to current application's NSRect's NSMakeRect(0, 0, itemPxSize, itemPxSize)
	else if numpixelsWidth > numpixelsHeight then
		set numRatio to (numpixelsHeight / numpixelsWidth) as number
		set numSetH to (itemPxSize * numRatio) as integer
		set numSetY to ((itemPxSize - numSetH) / 2) as integer
		set ocidDrawPasteRect to current application's NSRect's NSMakeRect(0, numSetY, itemPxSize, numSetH)
	else if numpixelsWidth < numpixelsHeight then
		set numRatio to (numpixelsWidth / numpixelsHeight) as number
		set numSetW to (itemPxSize * numRatio) as integer
		set numSetX to ((itemPxSize - numSetW) / 2) as integer
		set ocidDrawPasteRect to current application's NSRect's NSMakeRect(numSetX, 0, numSetW, itemPxSize)
	end if
	#編集開始
	current application's NSGraphicsContext's saveGraphicsState()
	set ocidSetImageContext to (current application's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidIconImageRep))
	ocidSetImageContext's setImageInterpolation:(current application's NSImageInterpolationHigh)
	ocidSetImageContext's setColorRenderingIntent:(current application's NSColorRenderingIntentSaturation)
	ocidSetImageContext's setCompositingOperation:(current application's NSCompositingOperationMultiply)
	ocidSetImageContext's setShouldAntialias:(true)
	current application's NSGraphicsContext's setCurrentContext:(ocidSetImageContext)
	(ocidFullImageRep's drawInRect:(ocidDrawPasteRect) fromRect:(ocidFromCopyRect) operation:(current application's NSCompositingOperationSourceOver) fraction:(1.0) respectFlipped:(false) hints:(missing value))
	#編集終了
	current application's NSGraphicsContext's restoreGraphicsState()
	#解像度設定72ppi
	set ocidSetSize to current application's NSSize's NSMakeSize(itemPxSize, itemPxSize)
	ocidIconImageRep's setSize:(ocidSetSize)
	#PNG保存オプション
	set ocidProperty to (current application's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidProperty's setObject:(current application's NSNumber's numberWithBool:false) forKey:(current application's NSImageInterlaced))
	(ocidProperty's setObject:(current application's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(current application's NSImageGamma))
	#保存
	set ocidNSInlineData to (ocidIconImageRep's representationUsingType:(current application's NSBitmapImageFileTypePNG) |properties|:(ocidProperty))
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("icon_16x16.png") isDirectory:(false)
	set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(current application's NSDataWritingAtomic) |error|:(reference))
	#保存画像を一旦クリア
	set ocidIconImageRep to ""
	
	#設定項目のサイズに従って順番に処理
	repeat with itemPxSize in listPxSize
		#72ppito144ppiでファイル名を設定
		set numPxSize to itemPxSize as integer
		set numHighResPtSize to (numPxSize / 2) as integer
		set strFileName to ("icon_" & numPxSize & "x" & numPxSize & ".png") as text
		set strHighResFileName to ("icon_" & numHighResPtSize & "x" & numHighResPtSize & "@2x.png") as text
		#設定サイズで画像を作成
		set ocidIconImageRep to (current application's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numPxSize) pixelsHigh:(numPxSize) bitsPerSample:8 samplesPerPixel:4 hasAlpha:(true) isPlanar:(false) colorSpaceName:(current application's NSCalibratedRGBColorSpace) bitmapFormat:(current application's NSBitmapFormatAlphaFirst) bytesPerRow:0 bitsPerPixel:32)
		(ocidIconImageRep's setProperty:(current application's NSImageColorSyncProfileData) withValue:(ocidProfileData))
		#ペースト位置計算
		if numpixelsWidth = numpixelsHeight then
			set ocidDrawPasteRect to current application's NSRect's NSMakeRect(0, 0, numPxSize, numPxSize)
		else if numpixelsWidth > numpixelsHeight then
			set numRatio to (numpixelsHeight / numpixelsWidth) as number
			set numSetH to (numPxSize * numRatio) as integer
			set numSetY to ((numPxSize - numSetH) / 2) as integer
			set ocidDrawPasteRect to current application's NSRect's NSMakeRect(0, numSetY, numPxSize, numSetH)
		else if numpixelsWidth < numpixelsHeight then
			set numRatio to (numpixelsWidth / numpixelsHeight) as number
			set numSetW to (numPxSize * numRatio) as integer
			set numSetX to ((numPxSize - numSetW) / 2) as integer
			set ocidDrawPasteRect to current application's NSRect's NSMakeRect(numSetX, 0, numSetW, numPxSize)
		end if
		
		#編集開始
		current application's NSGraphicsContext's saveGraphicsState()
		set ocidSetImageContext to (current application's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidIconImageRep))
		(ocidSetImageContext's setImageInterpolation:(current application's NSImageInterpolationHigh))
		(ocidSetImageContext's setColorRenderingIntent:(current application's NSColorRenderingIntentSaturation))
		(ocidSetImageContext's setCompositingOperation:(current application's NSCompositingOperationMultiply))
		(ocidSetImageContext's setShouldAntialias:(true))
		(current application's NSGraphicsContext's setCurrentContext:(ocidSetImageContext))
		(ocidFullImageRep's drawInRect:(ocidDrawPasteRect) fromRect:(ocidFromCopyRect) operation:(current application's NSCompositingOperationSourceOver) fraction:(1.0) respectFlipped:(false) hints:(missing value))
		#編集終了
		current application's NSGraphicsContext's restoreGraphicsState()
		#72ppi ptサイズ設定
		set ocidSetSize to current application's NSSize's NSMakeSize(numPxSize, numPxSize)
		(ocidIconImageRep's setSize:(ocidSetSize))
		#72ppiで保存
		set ocidNSInlineData to (ocidIconImageRep's representationUsingType:(current application's NSBitmapImageFileTypePNG) |properties|:(ocidProperty))
		set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false))
		set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(current application's NSDataWritingAtomic) |error|:(reference))
		#144ppiでptサイズ設定
		set ocidSetSize to current application's NSSize's NSMakeSize(numHighResPtSize, numHighResPtSize)
		(ocidIconImageRep's setSize:(ocidSetSize))
		#144ppiで保存
		set ocidNSInlineData to (ocidIconImageRep's representationUsingType:(current application's NSBitmapImageFileTypePNG) |properties|:(ocidProperty))
		set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strHighResFileName) isDirectory:(false))
		set boolDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(current application's NSDataWritingAtomic) |error|:(reference))
		#生成した画像をクリア
		set ocidIconImageRep to ""
	end repeat
	set ocidFullImageRep to ""
	
	##################　
	#ICNSファイル生成
	set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strSaveDirPath & "\" -o \"" & strSaveIcnsFilePath & "\"")
	set ocidComString to current application's NSString's stringWithString:(strCommandText)
	set ocidTermTask to current application's NSTask's alloc()'s init()
	ocidTermTask's setLaunchPath:("/bin/zsh")
	set ocidArgumentsArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidArgumentsArray's addObject:("-c")
	ocidArgumentsArray's addObject:(ocidComString)
	ocidTermTask's setArguments:(ocidArgumentsArray)
	set ocidOutPut to current application's NSPipe's pipe()
	set ocidError to current application's NSPipe's pipe()
	ocidTermTask's setStandardOutput:(ocidOutPut)
	ocidTermTask's setStandardError:(ocidError)
	ocidTermTask's setCurrentDirectoryURL:(ocidIconDirPathURL)
	set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
	if (item 1 of listDoneReturn) is (false) then
		log "エラーコード：" & (item 2 of listDoneReturn)'s code() as text
		log "エラードメイン：" & (item 2 of listDoneReturn)'s domain() as text
		log "Description:" & (item 2 of listDoneReturn)'s localizedDescription() as text
		log "FailureReason:" & (item 2 of listDoneReturn)'s localizedFailureReason() as text
	end if
	#終了待ち
	ocidTermTask's waitUntilExit()
	
	#アイコンセット
	#NSADATA
	set listResponse to current application's NSData's alloc()'s initWithContentsOfURL:(ocidSaveIcnsFilePathURL) options:(ocidOption) |error|:(reference)
	set ocidReadIconImageData to (item 1 of listResponse)
	
	#NSIMAGE
	set ocidReadIconImage to current application's NSImage's alloc()'s initWithData:(ocidReadIconImageData)
	
	#アイコン画像をセットするパス
	
	set ocidSetIconFilePathStr to current application's NSString's stringWithString:(strSetIconFilePath)
	set ocidSetIconFilePathStr to (ocidSetIconFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
	set ocidSetIconFilePath to ocidSetIconFilePathStr's stringByStandardizingPath()
	
	#アイコンセット
	set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's setIcon:(ocidReadIconImage) forFile:(ocidSetIconFilePath) options:(current application's NSExclude10_4ElementsIconCreationOption)
	

set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveIcnsFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidIconDirPathURL's |path|())
	
	return 0
end run


on doPrintHelp()
	set strHelpText to ("このツールは、指定されたファイルに指定された画像からアイコンを生成して付与します。

使用方法:
  seticon.applescript /パス/ファイル /パス/画像ファイル

引数:
  /パス/ファイル       アイコンを付与したい対象のファイルのパスを指定します。
  /パス/画像ファイル   アイコンデータを生成する元となる画像ファイルのパスを指定します。

例:
  seticon.applescript /Users/example/document.txt /Users/example/icon.png

注意:
  作成したアイコンデータicnsとiconsetは
  /Users/あなたのUID/Pictures/Icons/MakeIconに保存されます
  編集して改変する場合文字コードをUTF8で保存する必要があります") as text
	return strHelpText
end doPrintHelp
