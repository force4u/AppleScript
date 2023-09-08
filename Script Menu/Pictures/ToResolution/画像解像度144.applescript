
#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Quartz"
use framework "CoreImage"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

on run
	
	set aliasIconPass to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/MultipleItemsIcon.icns") as alias
	set strDialogText to "ドロップしても利用できます"
	set strTitleText to "画像ファイルを選んでください"
	set listButton to {"ファイルを選びます", "キャンセル"} as list
	display dialog strDialogText buttons listButton default button 1 cancel button 2 with title strTitleText with icon aliasIconPass giving up after 2 with hidden answer
	
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
	set listChooseFileUTI to {"public.image"}
	set strPromptText to "イメージファイルを選んでください" as text
	set strPromptMes to "イメージファイルを選んでください" as text
	set listAliasFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with showing package contents, invisibles and multiple selections allowed) as list
	
	-->値をOpenに渡たす
	open listAliasFilePath
end run


on open listAliasFilePath
	################################
	(*
	###カラープロファイルを読み出しておく ファイルはお好みで
	set strIccFilePath to "/System/Library/ColorSync/Profiles/sRGB Profile.icc"
		set ocidIccFilePathStr to (refMe's NSString's stringWithString:strIccFilePath)
	set ocidIccFilePath to ocidIccFilePathStr's stringByStandardizingPath
	set ocidIccFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidIccFilePath isDirectory:false)
	set ocidProfileData to refMe's NSData's alloc()'s initWithContentsOfURL:ocidIccFilePathURL
	*)
	##########################
	####ファイルの数だけ繰り返し
	##########################
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
	set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue
	repeat with itemAliasFilePath in listAliasFilePath
		####まずはUNIXパスにして
		set strFilePath to (POSIX path of itemAliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath)
		####ファイル名を取得
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		####ファイル名から拡張子を取っていわゆるベースファイル名を取得
		set strPrefixName to ocidFileName's stringByDeletingPathExtension as text
		####コンテナディレクトリを取得
		set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
		###拡張子を取得して小文字にしておく
		set ocidExtensionName to ocidFilePathURL's pathExtension()
		set ocidExtensionNameLowCase to ocidExtensionName's lowercaseString()
		set strExtensionName to ocidExtensionNameLowCase as text
		#####################
		#### 本処理
		#####################
		####データ読み込み
		set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:ocidFilePathURL)
		####ImageRepに変換
		set ocidImageRepArray to ocidImageData's representations()
		####サイズと解像度計算
		set ocidImageRep to (ocidImageRepArray's objectAtIndex:0)
		set numpixelsWidth to ocidImageRep's pixelsWide()
		set numpixelsHeight to ocidImageRep's pixelsHigh()
		set ocidImageRepSize to ocidImageRep's |size|()
		set numPointWidth to width of ocidImageRepSize
		set numPointHeight to height of ocidImageRepSize
		set numCurrentDPI to ((72 * numpixelsWidth) / numPointWidth) as integer
		log numCurrentDPI
		set numNewImageWidth to ((72.0 * numpixelsWidth) / 144)
		set numNewImageHeight to ((72.0 * numpixelsHeight) / 144)
		#####リサイズの値レコード
		set recordNewImageSize to {width:numNewImageWidth, height:numNewImageHeight} as record
		###リサイズ
		(ocidImageRep's setSize:recordNewImageSize)
		
		if strExtensionName is "png" then
			###展開 PNG
			set ocidSaveImageType to refMe's NSBitmapImageFileTypePNG
			set ocidNewImageData to (ocidImageRep's representationUsingType:ocidSaveImageType |properties|:{NSImageInterlaced:ocidTrue, NSImageDitherTransparency:ocidTrue})
			
		else if strExtensionName is "jpg" then
			###展開 JPEG
			set ocidSaveImageType to refMe's NSBitmapImageFileTypeJPEG
			set ocidNewImageData to (ocidImageRep's representationUsingType:ocidSaveImageType |properties|:{NSImageProgressive:ocidFalse, NSImageCompressionFactor:(1.0)})
			
		else if strExtensionName is "jpeg" then
			
			set ocidSaveImageType to refMe's NSBitmapImageFileTypeJPEG
			set ocidNewImageData to (ocidImageRep's representationUsingType:ocidSaveImageType |properties|:{NSImageProgressive:ocidFalse, NSImageCompressionFactor:(1.0)})
		else
			log "処理しないでそのまま保存"
		end if
		###上書き保存
		set boolResults to (ocidNewImageData's writeToURL:ocidFilePathURL atomically:true)
		
		if boolResults is true then
			log "処理OK"
		else
			log "処理NGなのでそのままにする"
			log "失敗ラベル赤を塗る"
			set boolResults to (ocidImagFilePathURL's setResourceValue:6 forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
		end if
		set ocidImageData to ""
		set ocidImageRep to ""
		set ocidNewImageData to ""
	end repeat
end open
