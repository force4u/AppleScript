#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#	ICNSファイルから各サイズのPNG画像を取り出します
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##################
#入力ダイアログ
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
set listUTI to {"com.apple.icns"}
set strMes to ("ICNSファイルを選んでください") as text
set strPrompt to ("ICNSファイルを選んでください") as text
try
	set aliasFilePath to (choose file strMes with prompt strPrompt default location aliasPicturesDirPath of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	return "エラーしました"
end try

##################
#入力パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
#保存用のディレクトリ名を作っておく　iconsetを強制
set ocidFileName to ocidFilePathURL's lastPathComponent()
set ocidBaseFilePath to ocidFileName's stringByDeletingPathExtension()
set ocidSaveDirName to ocidBaseFilePath's stringByAppendingPathExtension:("iconset")

##################
#出力先 フォルダ選択
tell application "Finder"
	set aliasContainerDirPath to (container of aliasFilePath) as alias
end tell
#ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strMes to "保存先フォルダを選んでください" as text
set strPrompt to "保存先フォルダを選択してください" as text
try
	set aliasChooseDirPath to (choose folder strMes with prompt strPrompt default location aliasContainerDirPath with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try

##################
#出力先 パスにしておく
set strChooseDirPath to (POSIX path of aliasChooseDirPath) as text
set ocidChooseDirPathStr to (refMe's NSMutableString's stringWithString:(strChooseDirPath))
set ocidChooseDirPath to ocidChooseDirPathStr's stringByStandardizingPath()
set ocidChooseDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidChooseDirPath) isDirectory:false)
set ocidSaveDirPathURL to ocidChooseDirPathURL's URLByAppendingPathComponent:(ocidSaveDirName) isDirectory:(true)
#フォルダを作っておく
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

##################
#読み込みNSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidFolderIconData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "エラーしました"
end if

##################
#NSDATAをNSIMAGEに
set ocidFolderIconImage to refMe's NSImage's alloc()'s initWithData:(ocidFolderIconData)

##################
#representations
set ocidImageRepArray to ocidFolderIconImage's representations()
#順番の処理
repeat with itemImgRep in ocidImageRepArray
	##################
	#サイズ取得して保存パスを作成
	#ピクセルサイズを取得
	set ocidPixelsHigh to itemImgRep's pixelsHigh()
	set ocidPixelsWide to itemImgRep's pixelsWide()
	#ポイントサイズ
	set ocidPtSize to itemImgRep's |size|()
	set ocidPointHigh to ocidPtSize's width()
	set ocidPontWide to ocidPtSize's height()
	#解像度
	set numResolution to (ocidPixelsWide / ocidPontWide) as integer
	#ファイル名にしていく
	if numResolution = 2 then
		set strSaveFileName to ("icon_" & (ocidPontWide as integer) & "x" & (ocidPointHigh as integer) & "@2x.png") as text
	else
		set strSaveFileName to ("icon_" & ocidPixelsWide & "x" & ocidPixelsHigh & ".png") as text
	end if
	#保存先のパスにしておく
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:(false))
	##################
	#イメージを保存用に変換
	#変換オプション
	set ocidProperty to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidProperty's setObject:(refMe's NSNumber's numberWithBool:false) forKey:(refMe's NSImageInterlaced))
	(ocidProperty's setObject:(refMe's NSNumber's numberWithDouble:(1 / 2.2)) forKey:(refMe's NSImageGamma))
	#変換
	set ocidType to (refMe's NSBitmapImageFileTypePNG)
	set ocidNSInlineData to (itemImgRep's representationUsingType:(ocidType) |properties|:(ocidProperty))
	#保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to (ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	if (item 1 of listDone) is true then
		log "正常処理"
	else if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s code() as text
		log (item 2 of listDone)'s localizedDescription() as text
		return "エラーしました"
	end if
	
end repeat

##保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:({ocidSaveDirPathURL})

return