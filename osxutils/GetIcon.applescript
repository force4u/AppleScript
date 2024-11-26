#!/usr/bin/env osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions


on run (argFilePath)
	if (argFilePath as text) is "" then
		return doPrintHelp()
	end if
	set appFileManager to current application's NSFileManager's defaultManager()
	set strFilePath to argFilePath as text
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePathStr to (ocidFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:(false)
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
	#保存先アイコンファイル
	set ocidCurrentDirPath to appFileManager's currentDirectoryPath()
	set ocidCurrentDirPathURL to current application's NSURL's alloc()'s initFileURLWithPath:(ocidCurrentDirPath) isDirectory:(true)
	set ocidBaseSaveFileURL to ocidCurrentDirPathURL's URLByAppendingPathComponent:(ocidBaseFileName) isDirectory:(false)
	set ocidSaveIconFilePathURL to ocidBaseSaveFileURL's URLByAppendingPathExtension:("icns")
	set strSaveIconFilePath to ocidSaveIconFilePathURL's |path| as text
	
	#保存先 アイコンセット
	set ocidTempDirURL to appFileManager's temporaryDirectory()
	set ocidUUID to current application's NSUUID's alloc()'s init()
	set ocidUUIDString to ocidUUID's UUIDString
	set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
	#ファイル名からアイコンセット名
	set ocidBaseSubDirURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidBaseFileName) isDirectory:(false)
	set ocidIconSetDirPathURL to ocidBaseSubDirURL's URLByAppendingPathExtension:("iconset")
	set strIconSetDirPath to ocidIconSetDirPathURL's |path| as text
	
	#iconsetのフォルダ作成
	set ocidAttrDict to current application's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(448) forKey:(current application's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidIconSetDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	#アイコンデータの収集
	#無駄だけどNSURLCustomIconKeyで取得して
	set listResponse to (ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLCustomIconKey) |error|:(reference))
	set ocidIconData to (item 2 of listResponse)
	#取得出来なかったら
	if ocidIconData = (missing value) then
		#NSWorkspaceでアイコンデータを取得
		set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
		set ocidIconData to appSharedWorkspace's iconForFile:(ocidFilePath)
	end if
	#取得したNSIMAGEを展開
	set ocidRepArray to ocidIconData's representations()
	set setReFileName to missing value
	#PNG保存オプション
	set ocidProperty to (current application's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidProperty's setObject:(current application's NSNumber's numberWithBool:false) forKey:(current application's NSImageInterlaced))
	(ocidProperty's setObject:(current application's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(current application's NSImageGamma))
	
	#順番に処理
	repeat with itemImageRep in ocidRepArray
		#ピクセルサイズ
		set numPixelsWide to itemImageRep's pixelsWide() as integer
		set numPixelsHigh to itemImageRep's pixelsHigh() as integer
		#ポイントサイズ
		set numPtWide to (itemImageRep's |size|())'s width() as integer
		set numPtHight to (itemImageRep's |size|())'s height() as integer
		#解像度で分岐
		if numPixelsWide = numPtWide then
			#72ppiの場合
			set strSaveFileName to ("icon_" & numPixelsWide & "x" & numPixelsHigh & ".png") as text
			set ocidCopyRect to {origin:{x:(0), y:(0)}, |size|:{width:(numPixelsWide), height:(numPixelsHigh)}}
			set ocidPasteRect to {origin:{x:(0), y:(0)}, |size|:{width:(numPixelsWide), height:(numPixelsHigh)}}
			set ocidSetSize to current application's NSSize's NSMakeSize(numPixelsWide, numPixelsWide)
		else
			#144ppiの場合
			set strSaveFileName to ("icon_" & numPixelsWide & "x" & numPixelsHigh & "@2x.png") as text
			set ocidCopyRect to {origin:{x:(0), y:(0)}, |size|:{width:(numPixelsWide), height:(numPixelsHigh)}}
			set ocidPasteRect to {origin:{x:(0), y:(0)}, |size|:{width:(numPixelsWide * 2), height:(numPixelsHigh * 2)}}
			set ocidSetSize to current application's NSSize's NSMakeSize(numPtWide, numPtHight)
		end if
		#NSISIconImageRepを処理するために画像をDRAWする
		#同サイズの新規イメージを作って
		set ocidAardboardRep to (current application's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:(numPixelsWide) pixelsHigh:(numPixelsHigh) bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(current application's NSCalibratedRGBColorSpace) bitmapFormat:(current application's NSBitmapFormatAlphaFirst) bytesPerRow:0 bitsPerPixel:32)
		###編集開始
		set ocidGraphicsContext to current application's NSGraphicsContext
		ocidGraphicsContext's saveGraphicsState()
		(ocidGraphicsContext's setCurrentContext:(ocidGraphicsContext's graphicsContextWithBitmapImageRep:(ocidAardboardRep)))
		#アイコンイメージをペースト
		(itemImageRep's drawInRect:(ocidPasteRect) fromRect:(ocidCopyRect) operation:(current application's NSCompositingOperationSourceOver) fraction:1.0 respectFlipped:false hints:(missing value))
		ocidGraphicsContext's restoreGraphicsState()
		(ocidAardboardRep's setSize:(ocidSetSize))
		###編集終了
		#PNGイメージデータに変換
		set ocidNSInlineData to (ocidAardboardRep's representationUsingType:(current application's NSBitmapImageFileTypePNG) |properties|:(ocidProperty))
		#保存ファイルパス
		set ocidSaveImageFilePathURL to (ocidIconSetDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
		#同じファイル名なら処理しない
		if setReFileName is strSaveFileName then
			set setReFileName to strSaveFileName
		else
			#ファイル名が違うなら保存
			set listDone to (ocidNSInlineData's writeToURL:(ocidSaveImageFilePathURL) options:(current application's NSDataWritingAtomic) |error|:(reference))
		end if
	end repeat
	
	set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strIconSetDirPath & "\" -o \"" & strSaveIconFilePath & "\"")
	log "\r" & strCommandText & "\r"
	set strExec to "/bin/zsh -c '" & strCommandText & "'"
	try
		do shell script strExec
	end try
	log "アイコンの保存先は: " & strSaveIconFilePath as text
end run


on doPrintHelp()
	set strHelpText to ("アイコンの内容をicnsファイルにしてカレントディレクトリに保存します
使用方法:
  GetIcon.applescript /some/somefile 
引数:
  /パス/ファイル  または　/パス/フォルダ
注意:
  生成された中間ファイルのiconsetは テンポラリーに保存されますので
  次回のOS再起動時に自動的に削除されます
  ICNSファイルはコマンド実行時のカレントディレクトリに保存します
  書き込みアクセス権が無い場合はエラーになってICNSファイルは生成されません

") as text
	return strHelpText
end doPrintHelp