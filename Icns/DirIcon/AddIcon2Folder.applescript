#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# V1 Aug 13, 2023
# V2 2024 06 21 HEICの表示の回転Orientationに対応
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "CoreImage"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

on run
	#デフォルトロケーション
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
	set aliasPicturesDirPath to (ocidPicturesDirPathURL's absoluteURL()) as alias
	#ダイアログを前面に出す
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	#ダイアログ
	set listUTI to {"public.png", "public.jpeg", "public.image"}
	set strMes to ("画像ファイルを選んでください") as text
	set strPrompt to ("画像ファイルを選んでください") as text
	try
		set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasPicturesDirPath of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
		if listAliasFilePath is {} then
			return "選んでください"
		end if
	on error
		return "エラーしました"
	end try
	open listAliasFilePath
end run

on open listAliasFilePath
	########################
	#フォルダイメージの保存先
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
	set ocidSaveDirPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:("Icons/Icons_Folder") isDirectory:(true)
	
	########################
	#ドロップされた場合のファイル判定OKの場合の格納用リスト
	set ocidImageFileArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	#ドロップされたファイルを順番に
	repeat with itemAliasFilePath in listAliasFilePath
		#パス
		set strFilePath to (POSIX path of itemAliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
		#UTIの取得
		set listResponse to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
		if (item 1 of listResponse) = (true) then
			log "getResourceValue 正常処理"
			set ocidUTType to (item 2 of listResponse)
		else if (item 3 of listResponse) ≠ (missing value) then
			log (item 3 of listResponse)'s code() as text
			log (item 3 of listResponse)'s localizedDescription() as text
			return "getResourceValue エラーしました"
		end if
		#UTIの親構造まで全部のリスト
		set ocidParentUTIArray to (ocidUTType's supertypes())'s allObjects()
		#比較用のUTI
		set ocidUTIpng to (refMe's UTType's typeWithIdentifier:("public.image"))
		#imageが含まれていればOK
		set boolContain to (ocidParentUTIArray's containsObject:(ocidUTIpng))
		if boolContain is true then
			(ocidImageFileArray's addObject:(ocidFilePathURL))
		end if
	end repeat
	########################
	#フォルダのアイコンを読み込み
	(* ドロップレット用
	set aliasPathToMe to (path to me) as alias
	set strPathToMe to (POSIX path of aliasPathToMe) as text
	set ocidPathToMeStr to (refMe's NSString's stringWithString:(strPathToMe))
	set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
	set ocidPathToMeURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:false)
	#フォルダアイコンのパス(テスト環境)
	set ocidContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
	set ocidFolderIconFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("Contents/Resources/icns/FolderDark.icns") isDirectory:(false)
	#コンパイル時はこちら
	#	set ocidFolderIconFilePathURL to ocidPathToMeURL's URLByAppendingPathComponent:("Contents/Resources/icns/FolderDark.icns") isDirectory:(false)
	*)
	#フォルダアイコンがすでにあるか？確認
	set ocidGenericFolderIconPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:("Icons/GenericFolderIcon.iconset/Folder.icns") isDirectory:(false)
	set ocidGenericFolderIconPath to ocidGenericFolderIconPathURL's |path|()
	#アイコンファイルの有無
	set boolDirExists to appFileManager's fileExistsAtPath:(ocidGenericFolderIconPath) isDirectory:(false)
	if boolDirExists = true then
		#アイコンファイルがあるのでこのまま処理する
		set ocidFolderIconFilePathURL to ocidGenericFolderIconPathURL
	else if boolDirExists = false then
		#アイコンファイルが無いので作る
		#フォルダアイコンの取得
		set boolDone to doMakeGenericFolderIcon()
		if boolDone is false then
			return "OSデフォルトのフォルダアイコンの取得に失敗しました"
		else if boolDone is true then
			set ocidFolderIconFilePathURL to ocidGenericFolderIconPathURL
		end if
	end if
	########################
	#処理開始
	#読み込みNSDATA
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFolderIconFilePathURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidFolderIconData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "エラーしました"
	end if
	#NSDATAをNSIMAGEに
	set ocidFolderIconImage to refMe's NSImage's alloc()'s initWithData:(ocidFolderIconData)
	#representations
	set ocidImageRepArray to ocidFolderIconImage's representations()
	set ocidFolderImgRep to ocidImageRepArray's firstObject()
	#解像度を72ppiにしておく
	#ピクセルサイズを取得
	set ocidPixelsHigh to ocidFolderImgRep's pixelsHigh()
	set ocidPixelsWide to ocidFolderImgRep's pixelsWide()
	#サイズにして
	set ocidSetSize to refMe's NSSize's NSMakeSize(ocidPixelsWide, ocidPixelsWide)
	#72ppi＝ピクセルサイズと同じポイントサイズにする
	ocidFolderImgRep's setSize:(ocidSetSize)
	########################
	#ドロップされた画像を順番に処理する
	repeat with itemImageFileURL in ocidImageFileArray
		#ドロップされた画像のファイル名
		set ocidFileName to itemImageFileURL's lastPathComponent()
		set ociBaseFileName to ocidFileName's stringByDeletingPathExtension()
		########################
		#フォルダを作っておく
		set ocidSaveFolderPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ociBaseFileName) isDirectory:(true))
		#フォルダを作っておく
		set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
		set listDone to (appFileManager's createDirectoryAtURL:(ocidSaveFolderPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		if (item 1 of listDone) is true then
			log "正常処理"
		else if (item 2 of listDone) ≠ (missing value) then
			log (item 2 of listDone)'s code() as text
			log (item 2 of listDone)'s localizedDescription() as text
			return "エラーしました"
		end if
		########################
		##ここでアイコンのサイズ決めている
		#	set numWidth to 512 as integer
		#	set numHight to 512 as integer
		set numWidth to ocidPixelsWide as integer
		set numHight to ocidPixelsHigh as integer
		#ドロップされた画像の読み込み
		#読み込みNSDATA
		set ocidOption to (refMe's NSDataReadingMappedIfSafe)
		set listResponse to (refMe's NSData's alloc()'s initWithContentsOfURL:(itemImageFileURL) options:(ocidOption) |error|:(reference))
		if (item 2 of listResponse) = (missing value) then
			log "正常処理"
			set ocidImageData to (item 1 of listResponse)
		else if (item 2 of listResponse) ≠ (missing value) then
			log (item 2 of listResponse)'s code() as text
			log (item 2 of listResponse)'s localizedDescription() as text
			return "エラーしました"
		end if
		########################
		#CIimage
		set ocidAddImageCI to (refMe's CIImage's imageWithData:(ocidImageData) options:(missing value))
		#ファイルのサイズを調べる
		set ocidCGRect to ocidAddImageCI's extent()
		#縦横の値を取得
		set numImageWidth to refMe's CGRectGetWidth(ocidCGRect) as number
		set numImageHeight to refMe's CGRectGetHeight(ocidCGRect) as number
		if numImageWidth < numImageHeight then
			set numResizeScale to (numWidth / numImageHeight)
		else
			#リサイズする指数
			set numResizeScale to (numWidth / numImageWidth)
		end if
		########################
		#HEICの回転対応
		#メタデータ取得
		set ocidOripertesDict to ocidAddImageCI's |properties|()
		set ocidOrientation to (ocidOripertesDict's valueForKey:("Orientation"))
		#Orientationの値が無い=通常画像
		if ocidOrientation = (missing value) then
			set strOrientation to ("1") as text
		else
			#IF文用にテキストにしておく
			set strOrientation to (ocidOrientation) as text
		end if
		#Transform指定
		#Orientationの値に応じてimageTransformForOrientationを指定しておく
		if strOrientation is "1" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationUp))
		else if strOrientation is "2" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationUpMirrored))
		else if strOrientation is "3" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationDown))
		else if strOrientation is "4" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationDownMirrored))
		else if strOrientation is "5" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationLeftMirrored))
		else if strOrientation is "6" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationRight))
		else if strOrientation is "7" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationRightMirrored))
		else if strOrientation is "8" then
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationLeft))
		else
			set recordCiImageData to (ocidAddImageCI's imageTransformForOrientation:(refMe's kCGImagePropertyOrientationUp))
		end if
		
		########################
		#Transform適応
		set ocidCIImageData to (ocidAddImageCI's imageByApplyingTransform:recordCiImageData)
		####Parameters
		set recordParameters to {inputImage:ocidCIImageData, inputScale:numResizeScale, inputAspectRatio:1.0} as record
		####リサイズする指数でリサイズ
		set ocidCiFilterData to (refMe's CIFilter's filterWithName:"CILanczosScaleTransform" withInputParameters:(recordParameters))
		#####リサイズ済みイメージ
		set ocidResizedCiImage to ocidCiFilterData's outputImage()
		#####NSBitmapImageRepに変換して
		set ocidResizedImagePep to (refMe's NSBitmapImageRep's alloc()'s initWithCIImage:(ocidResizedCiImage))
		if (strOrientation as integer) > 4 then
			set numResizedWide to ocidResizedImagePep's pixelsHigh()
			set numResizedHigh to ocidResizedImagePep's pixelsWide()
		else
			set numResizedHigh to ocidResizedImagePep's pixelsHigh()
			set numResizedWide to ocidResizedImagePep's pixelsWide()
		end if
		if numImageWidth < numImageHeight then
			set numOffSetW to ((numResizedHigh - numResizedWide) / 2) as integer
			set numOffSetH to 0 as integer
		else
			set numOffSetH to ((numResizedWide - numResizedHigh) / 2) as integer
			set numOffSetW to 0 as integer
		end if
		
		########################
		#出力イメージ NSBitmapImageRep's
		set ocidSetColor to (refMe's NSColor's colorWithDeviceRed:0 green:0 blue:0 alpha:1)
		set ocidBitmapFormat to refMe's NSBitmapFormatAlphaFirst
		set ocidColorSpaceName to refMe's NSCalibratedRGBColorSpace
		set ocidNSBitmapImageFileType to refMe's NSBitmapImageFileTypeTIFF
		set ocidBitmapImageRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numWidth) pixelsHigh:(numHight) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(ocidColorSpaceName) bitmapFormat:(ocidBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
		###初期化
		refMe's NSGraphicsContext's saveGraphicsState()
		(refMe's NSGraphicsContext's setCurrentContext:(refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:ocidBitmapImageRep))
		####画像作成終了
		refMe's NSGraphicsContext's restoreGraphicsState()
		########################
		#フォルダのイメージを重ねる
		#NSGraphicsContext's
		refMe's NSGraphicsContext's saveGraphicsState()
		###生成された画像でNSGraphicsContext初期化
		set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidBitmapImageRep))
		(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
		#
		set ocidSetOrigin to refMe's NSPoint's NSMakePoint(0, 0)
		set ocidSetSize to refMe's NSMakeSize's NSMakeSize(numWidth, numHight)
		set ocidFromRect to refMe's NSRect's NSMakeRect((ocidSetOrigin's x()), (ocidSetOrigin's y()), (ocidSetSize's width()), (ocidSetSize's height()))
		set ocidDrawRect to ocidFromRect
		#この記述でも充分
		#set ocidFromRect to {origin:{x:0, y:0}, |size|:{width:numWidth, height:numHight}} as list
		#set ocidDrawRect to {origin:{x:0, y:0}, |size|:{width:numWidth, height:numHight}} as list
		####フォルダ画像を背景画像上に配置する
		set ocidOption to (refMe's NSCompositingOperationSourceOver)
		set boolDone to (ocidFolderImgRep's drawInRect:(ocidDrawRect) fromRect:(ocidFromRect) operation:(ocidOption) fraction:1.0 respectFlipped:true hints:(missing value))
		if boolDone is false then
			return "画像の合成に失敗しました"
		end if
		####画像作成終了
		refMe's NSGraphicsContext's restoreGraphicsState()
		########################
		#ドロップシャドウ生成
		set ocidShadow to refMe's NSShadow's alloc()'s init()
		set ocidShadowColor to (refMe's NSColor's colorWithDeviceRed:0 green:0 blue:0 alpha:0.5)
		(ocidShadow's setShadowColor:(ocidShadowColor))
		(ocidShadow's setShadowBlurRadius:(4))
		set ocidShadowSize to refMe's NSMakeSize(3, -3)
		(ocidShadow's setShadowOffset:(ocidShadowSize))
		########################
		#フォルダの上にアイコン画像を重ねる
		#NSGraphicsContext's
		refMe's NSGraphicsContext's saveGraphicsState()
		###生成された画像でNSGraphicsContext初期化
		set ocidContext to (refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:(ocidBitmapImageRep))
		(refMe's NSGraphicsContext's setCurrentContext:(ocidContext))
		set ocidFromRect to {origin:{x:0, y:0}, |size|:{width:numWidth, Hight:numHight}}
		#HEICの位置合わせは出物あわせで根拠が無い…汗
		if (strOrientation as integer) > 4 then
			set numXoffSet to (256 + (numOffSetH / 2)) as integer
			set numYoffSet to (220 + numOffSetW) as integer
		else
			set numXoffSet to (256 + (numOffSetW / 2)) as integer
			set numYoffSet to (220 + numOffSetH) as integer
		end if
		#フォルダアイコン画像の半分の縦横サイズで
		#指定のオフセット位置に描画する
		set ocidSetOrigin to refMe's NSPoint's NSMakePoint(numXoffSet, numYoffSet)
		set ocidSetSize to refMe's NSMakeSize's NSMakeSize((numWidth / 2), (numHight / 2))
		set ocidSetRect to refMe's NSRect's NSMakeRect((ocidSetOrigin's x()), (ocidSetOrigin's y()), (ocidSetSize's width()), (ocidSetSize's height()))
		#この記述でもOKだった
		#	set recordDrawRect to {origin:{x:(numXoffSet), y:(numYoffSet)}, |size|:{width:(numWidth / 2), height:(numHight / 2)}} as record
		###コマ画像を背景画像上に配置する
		set ocidOption to (refMe's NSCompositingOperationSourceOver)
		###ドロップシャドウ適応
		ocidShadow's |set|()
		set boolDone to (ocidResizedImagePep's drawInRect:(ocidSetRect) fromRect:(ocidFromRect) operation:(ocidOption) fraction:1.0 respectFlipped:true hints:(missing value))
		if boolDone is false then
			return "画像の合成に失敗しました"
		end if
		####画像作成終了
		refMe's NSGraphicsContext's restoreGraphicsState()
		
		########################
		#出力用にTIFFに変換する
		set ocidPropertyDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		####TIFF用の圧縮プロパティ(NSImageCompressionFactor)
		(ocidPropertyDict's setObject:0 forKey:(refMe's NSImageCompressionFactor))
		####インラインデータに変換
		set ocidType to (refMe's NSBitmapImageFileTypeTIFF)
		set ocidTiffData to (ocidBitmapImageRep's representationUsingType:(ocidType) |properties|:(ocidPropertyDict))
		#保存先パス
		set ocidSaveImgFilePathURL to (ocidSaveFolderPathURL's URLByAppendingPathComponent:(ociBaseFileName) isDirectory:(false))
		set ocidTiffPathURL to (ocidSaveImgFilePathURL's URLByAppendingPathExtension:("tiff"))
		set ocidOption to (refMe's NSDataWritingAtomic)
		set listDone to (ocidTiffData's writeToURL:(ocidTiffPathURL) options:(ocidOption) |error|:(reference))
		if (item 1 of listDone) is true then
			log "正常処理"
		else if (item 2 of listDone) ≠ (missing value) then
			log (item 2 of listDone)'s code() as text
			log (item 2 of listDone)'s localizedDescription() as text
			return "エラーしました"
		end if
		
		########################
		#出力用にPNGに変換する
		set ocidPropertyDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		(ocidPropertyDict's setObject:(refMe's NSNumber's numberWithBool:false) forKey:(refMe's NSImageInterlaced))
		(ocidPropertyDict's setObject:(refMe's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(refMe's NSImageGamma))
		#変換
		set ocidType to (refMe's NSBitmapImageFileTypePNG)
		set ocidPngData to (ocidBitmapImageRep's representationUsingType:(ocidType) |properties|:(ocidPropertyDict))
		#保存先パス
		set ocidSaveImgFilePathURL to (ocidSaveFolderPathURL's URLByAppendingPathComponent:(ociBaseFileName) isDirectory:(false))
		set ocidPngPathURL to (ocidSaveImgFilePathURL's URLByAppendingPathExtension:("png"))
		set ocidOption to (refMe's NSDataWritingAtomic)
		set listDone to (ocidPngData's writeToURL:(ocidPngPathURL) options:(ocidOption) |error|:(reference))
		if (item 1 of listDone) is true then
			log "正常処理"
		else if (item 2 of listDone) ≠ (missing value) then
			log (item 2 of listDone)'s code() as text
			log (item 2 of listDone)'s localizedDescription() as text
			return "エラーしました"
		end if
		
		########################
		#アイコン用にPNGイメージをNSIMAGEに
		set ocidAddIconImageData to (refMe's NSImage's alloc()'s initWithData:(ocidPngData))
		########################
		#アイコンを付与する
		set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidSaveFolderPath to ocidSaveFolderPathURL's |path|()
		###アイコン付与
		set ocidOption to (refMe's NSExclude10_4ElementsIconCreationOption)
		set boolDone to (appSharedWorkspace's setIcon:(ocidAddIconImageData) forFile:(ocidSaveFolderPath) options:(ocidOption))
		if boolDone is true then
			log "正常処理"
		else if boolDone is false then
			return "エラーしました"
		end if
	end repeat
	
	##保存先を開く
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	appSharedWorkspace's activateFileViewerSelectingURLs:({ocidSaveFolderPathURL})
	
end open

####################################
#OSデフォルトのアイコンイメージを取得
to doMakeGenericFolderIcon()
	#作成するフォルダのアクセス権
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
	
	#Assets.carのパス
	set strCarFilePath to ("/System/Library/PrivateFrameworks/IconFoundation.framework/Versions/A/Resources/Assets.car") as text
	set ocidCarFilePath to refMe's NSString's stringWithString:(strCarFilePath)
	set ocidCarFilePathURL to refMe's NSURL's fileURLWithPath:(ocidCarFilePath)
	set ocidFileName to ocidCarFilePathURL's lastPathComponent()
	
	#Classは４種類
	set listFolderName to {"FolderDark", "SmartFolder", "Folder", "SmartFolderDark"} as list
	#４種類全部ICNSを生成する
	repeat with itemFolderName in listFolderName
		##########################
		#CARファイルからiconsetを書き出す
		#画像の保存先iconset
		set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
		set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
		set strSubPath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".iconset") as text
		set ocidIconsDirPathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath))
		#フォルダを作っておく
		set listDone to (appFileManager's createDirectoryAtURL:(ocidIconsDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		if (item 1 of listDone) is true then
			log "正常処理"
		else if (item 2 of listDone) ≠ (missing value) then
			log (item 2 of listDone)'s code() as text
			log (item 2 of listDone)'s localizedDescription() as text
			log "エラーしました"
			return false
		end if
		#コマンド整形
		set strIconFilePath to (ocidCarFilePathURL's |path|) as text
		set strSaveDirPath to (ocidIconsDirPathURL's |path|) as text
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strIconFilePath & "\" " & itemFolderName & " -o \"" & strSaveDirPath & "\"") as text
		log strCommandText
		#コマンド実行
		try
			do shell script strCommandText
		on error
			log "コマンドでエラーしました"
			return false
		end try
	end repeat
	##########################
	#iconsetからicnsファイルを作成
	#パス
	set strSubPath to ("Icons/GenericFolderIcon.iconset") as text
	set ocidIconsDirPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath)
	set ocidDistIconFilePathURL to ocidIconsDirPathURL's URLByAppendingPathComponent:(ocidFileName)
	#Carファイルのコピーはしないことにする
	#set listDone to appFileManager's copyItemAtURL:(ocidCarFilePathURL) toURL:(ocidDistIconFilePathURL) |error|:(reference)
	#４種類全部作る
	set listFolderName to {"FolderDark", "SmartFolder", "Folder", "SmartFolderDark"} as list
	#４種類を順番に
	repeat with itemFolderName in listFolderName
		#パス
		set strSubPath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".iconset") as text
		set ocidIconsDirPathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath))
		set strFileNamePath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".icns") as text
		set ocidSaveFilePathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strFileNamePath))
		#コマンド整形
		set strIconDirPath to (ocidIconsDirPathURL's |path|) as text
		set strSaveFilePath to (ocidSaveFilePathURL's |path|) as text
		set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strIconDirPath & "\"  -o \"" & strSaveFilePath & "\"") as text
		log strCommandText
		#コマンド実行
		try
			do shell script strCommandText
		on error
			return false
		end try
	end repeat
	#全部終了したらtrueを返す
	return true
	
end doMakeGenericFolderIcon
