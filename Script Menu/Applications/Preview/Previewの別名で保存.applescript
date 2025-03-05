#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
プレビューでの別名保存
ファイルのフォーマットの指定はUTIで指定して
拡張子がUTIにマッチしている必要がある
【注意】
プレビューの別名保存は、同名のファイルがある場合
『上書き』になって置換＝置き換わります。
保存先は常に別のフォルダにすることをお勧めします。
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


#####################
#設定項目
#保存ファイル名にピクセルサイズと解像度を入れる
# 入れる場合は true 入れない場合はfalse
set boolSizeInName to false as boolean

#####################
#私が確認した限りだけど保存できるフォーマット
set recordFileFormatUTI to {|com.adobe.pdf|:"pdf", |public.jpeg|:"jpeg", |public.png|:"png", |public.tiff|:"tif", |public.heic|:"heic", |public.heics|:"heics", |public.pbm|:"pbm", |org.khronos.astc|:"astc", |org.khronos.ktx|:"ktx", |com.microsoft.bmp|:"bmp", |com.microsoft.ico|:"ico", |com.truevision.tga-image|:"tga", |com.compuserve.gif|:"gif", |public.jpeg-2000|:"jp2", |com.apple.icns|:"icns"} as record

#####################
#DICTにしてキー一覧を取得する
set ocidFileFormatUtiDict to refMe's NSMutableDictionary's alloc()'s init()
ocidFileFormatUtiDict's setDictionary:(recordFileFormatUTI)
set ocidAllKeys to ocidFileFormatUtiDict's allKeys()
#ソート
set ocidAllKeys to ocidAllKeys's sortedArrayUsingSelector:("localizedStandardCompare:")
#ダイアログに渡すようにリストにする
set listAllKeys to ocidAllKeys as list
#####################
#ファイル選択
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "SystemUIServer" to activate
else
	tell current application to activate
end if
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("画像ファイルを選んでください\r com.microsoft.icoは256px以下の正方形\r com.apple.icnsは512px以下の正方形である必要があります") as text
set listUTI to {"public.image"}
try
	tell application "SystemUIServer"
		activate
		###　ファイル選択時
		set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	end tell
on error
	log "エラーしました"
	return "エラーしました"
end try
if listAliasFilePath is {} then
	return "選んでください"
end if

#####################
#保存先指定
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "SystemUIServer" to activate
else
	tell current application to activate
end if
set strMes to "フォルダを選んでください" as text
set strPrompt to "保存先フォルダを選択してください" as text
tell application "Finder"
	set aliasContainerDirPath to (container of (item 1 of listAliasFilePath)) as alias
end tell
try
	tell application "SystemUIServer"
		#Activateは必須
		activate
		set aliasSaveDirPath to (choose folder strMes with prompt strPrompt default location aliasContainerDirPath with invisibles and showing package contents without multiple selections allowed) as alias
	end tell
on error
	log "エラーしました"
	return "エラーしました"
end try
set strSaveDirPath to (POSIX path of aliasSaveDirPath) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)

#####################
#フォーマット選択
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "SystemUIServer" to activate
else
	tell current application to activate
end if
set strTitle to ("選んでください") as text
set strPrompt to ("ひとつ選んでください\n") as text
try
	tell application "SystemUIServer"
		activate
		set valueResponse to (choose from list listAllKeys with title strTitle with prompt strPrompt default items (item 1 of listAllKeys) OK button name "OK" cancel button name "キャンセル" with empty selection allowed without multiple selections allowed)
	end tell
on error
	log "Error choose from list"
	return false
end try
if (class of valueResponse) is boolean then
	log "Error キャンセルしました"
	return false
else if (class of valueResponse) is list then
	if valueResponse is {} then
		log "Error 何も選んでいません"
		return false
	else
		set strUTI to (item 1 of valueResponse) as text
	end if
end if
#DICTから拡張子を取得
set ocidExtnsion to ocidFileFormatUtiDict's valueForKey:(strUTI)
set strExtnsion to ocidExtnsion as text


repeat with itemAliasFilePath in listAliasFilePath
	
	#パスをURLにしておく
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:(false))
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
	
	#解像度と縦横PXサイズを取得しておく
	set ocidImageRep to (refMe's NSImageRep's imageRepsWithContentsOfURL:(ocidFilePathURL))'s firstObject()
	#PXサイズ
	set ocidPxW to ocidImageRep's pixelsWide()
	set ocidPxH to ocidImageRep's pixelsHigh()
	#Ptサイズ
	set recordImageSize to ocidImageRep's |size|()
	set ocidPtW to recordImageSize's width()
	set ocidPtH to recordImageSize's height()
	#解像度
	set numResolution to ((ocidPxW / ocidPtW) * 72) as integer
	set strResolution to numResolution as text
	if boolSizeInName is true then
		#保存用の拡張子
		set strNewExtension to ("" & (ocidPxW as text) & "x" & (ocidPxH as text) & "@" & strResolution & "ppi." & strExtnsion & "") as text
	else if boolSizeInName is false then
		set strNewExtension to strExtnsion as text
	end if
	#保存パス
	set ocidSaveBaseFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidBaseFileName) isDirectory:(false))
	set ocidSaveFilePathURL to (ocidSaveBaseFilePathURL's URLByAppendingPathExtension:(strNewExtension))
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
	######
	#サイズ判定
	if strUTI is "com.apple.icns" or strUTI is "com.microsoft.ico" then
		if ocidPxW ≠ ocidPxH then
			return "アイコン画像変換は正方形である必要があります"
		end if
	end if
	if strUTI is "com.apple.icns" then
		if (ocidPxW as integer) > 512 then
			return "AppleIcns画像変換は512px以下である必要があります"
		end if
	end if
	if strUTI is "com.microsoft.ico" then
		if (ocidPxW as integer) > 256 then
			return "MicrosoftICo画像変換は256px以下である必要があります"
		end if
	end if
	
	tell application "Preview"
		set refOpenDoc to open file aliasFilePath
		#ファイルがOPENされるのをまつ
		repeat 10 times
			tell refOpenDoc
				set strFilePath to path as text
				set strFileName to name as text
			end tell
			tell front document
				set strCurrentFilePath to path as text
				set strCurrentFileName to name as text
			end tell
			#選択画面で選んだパスと同一になるまで待つ
			if strCurrentFilePath is strFilePath then
				exit repeat
			else
				delay 0.2
			end if
		end repeat
	end tell
	
	tell application "Preview"
		tell front document
			save as strUTI in aliasSaveFilePath
		end tell
		tell front document
			close saving no
		end tell
	end tell
	
end repeat


#保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveDirPathURL)

