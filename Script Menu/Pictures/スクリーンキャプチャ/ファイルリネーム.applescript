#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#スクリーンキャプチャー用に割り切ってります。
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
##ファイル名の接頭語
set strBaseFileName to "Screen" as text

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

###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set appFileManager to refMe's NSFileManager's defaultManager()
###デフォルトのロケーション
set strReadDirPath to "~/Pictures/ScreenCapture/ScreenCapture/" as text
set ocidReadDirPathStr to refMe's NSString's stringWithString:(strReadDirPath)
set ocidReadDirPath to ocidReadDirPathStr's stringByStandardizingPath()
set ocidReadDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidReadDirPath) isDirectory:true)
set aliasReadDirPath to (ocidReadDirPathURL's absoluteURL()) as alias
try
	###ダイアログ
	set strMes to "フォルダを選んでください" as text
	set strPrompt to "フォルダを選択してください" as text
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasReadDirPath without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
###ダイアログで選択したディレクトリ
set strReadDirPath to (POSIX path of aliasResponse) as text
set ocidReadDirPathStr to refMe's NSString's stringWithString:(strReadDirPath)
set ocidReadDirPath to ocidReadDirPathStr's stringByStandardizingPath()
set ocidReadDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidReadDirPath) isDirectory:true)
###コンテンツの収集
set ocidPropertiesForKeys to {(refMe's NSURLPathKey), (refMe's NSURLContentTypeKey)}
set listFileURLArray to appFileManager's contentsOfDirectoryAtURL:(ocidReadDirPathURL) includingPropertiesForKeys:(ocidPropertiesForKeys) options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) |error|:(reference)
set ocidFileURLArray to (item 1 of listFileURLArray)
###同名ファイル名用のカウンター
set intCntNo to 0 as integer
###ファイルの数だけ繰り返し
repeat with itemFileURL in ocidFileURLArray
	set ocidExtensionName to itemFileURL's pathExtension()
	###########################
	###【１】元イメージ
	##NSIMAGEに読み込む
	set ocidReadImage to (refMe's NSImage's alloc()'s initWithContentsOfURL:(itemFileURL))
	##SIZE
	set ocidImageSize to ocidReadImage's |size|()
	set ocidImageWidth to ocidImageSize's width()
	set ocidImageHeight to ocidImageSize's Height()
	##BitMapRepに変換
	set ocidImageRepArray to ocidReadImage's representations()
	set ocidImageRep to (ocidImageRepArray's objectAtIndex:0)
	##ピクセルサイズ取得
	set numPixelsWidth to ocidImageRep's pixelsWide()
	set numPixelsHeight to ocidImageRep's pixelsHigh()
	##リネーム用のファイル名生成
	if numPixelsWidth > ocidImageWidth then
		set intImageWidth to ocidImageWidth as integer
		set intImageHeight to ocidImageHeight as integer
		if (ocidImageWidth * 2) = numPixelsWidth then
			set strFileName to (strBaseFileName & "_" & intImageWidth & "x" & intImageHeight & "@2x." & ocidExtensionName) as text
		else if (ocidImageWidth * 3) = numPixelsWidth then
			set strFileName to (strBaseFileName & "_" & intImageWidth & "x" & intImageHeight & "@3x." & ocidExtensionName) as text
		end if
	else
		set strFileName to (strBaseFileName & "_" & numPixelsWidth & "x" & numPixelsHeight & "." & ocidExtensionName) as text
	end if
	set ocidNewFilePathURL to (ocidReadDirPathURL's URLByAppendingPathComponent:(strFileName))
	set ocidNewFilePath to ocidNewFilePathURL's |path|()
	###同名ファイルチェック
	set boolExists to (appFileManager's fileExistsAtPath:(ocidNewFilePath) isDirectory:(false))
	log boolExists
	if boolExists = false then
		log ocidNewFilePathURL's |path| as text
		###リネーム
		set listDone to (appFileManager's moveItemAtURL:(itemFileURL) toURL:(ocidNewFilePathURL) |error|:(reference))
		log item 1 of listDone
	else
		###リネーム　同名ありの場合は連番付与
		set strZeroSup to "000" as text
		set intCntNo to (intCntNo + 1) as integer
		set strCntNo to intCntNo as text
		set strZeroSup to (text -3 through -1 of (strZeroSup & strCntNo)) as text
		set strFileName to (strZeroSup & "_" & strFileName) as text
		set ocidNewFilePathURL to (ocidReadDirPathURL's URLByAppendingPathComponent:(strFileName))
		set listDone to (appFileManager's moveItemAtURL:(itemFileURL) toURL:(ocidNewFilePathURL) |error|:(reference))
		
	end if
	
	
end repeat


return

