#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
error number -128
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##########################
## ダイアログ
##########################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDesktopPath to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias

set listChooseFileUTI to {"com.compuserve.gif"}
set strPromptText to "ファイルを選んでください" as text
set strPromptMes to "ファイルを選んでください" as text
set aliasFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and showing package contents without multiple selections allowed) as alias
##########################
## パス
##########################

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
###作成するフォルダ名
set ocidFileName to ocidFilePathURL's lastPathComponent()
set strBaseFileName to ocidFileName's stringByDeletingPathExtension() as text
set strSaveDirName to (strBaseFileName & "_Image Sequence") as text
####コンテナディレクトリ
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
###保存用ディレクトリ
set ocidSaveFileDirURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:strSaveDirName)
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveFileDirURL) withIntermediateDirectories:true attributes:(missing value) |error|:(reference)

##########################
## 画像読み込み
##########################
set ocidGifImage to refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set ocidGifImageArray to ocidGifImage's representations()
set ocidGifImageRep to ocidGifImageArray's objectAtIndex:0
##########################
###保存時必要になるPNGオプション
##########################
####NSImageColorSyncProfileData
set ocidColorSpace to refMe's NSColorSpace's displayP3ColorSpace()
set ocidColorSpaceData to ocidColorSpace's colorSyncProfile()
####NSImageEXIFData
set ocidEXIFData to (ocidGifImageRep's valueForProperty:(refMe's NSImageEXIFData))
####ガンマ値換算 まぁ2.2入れておけば間違い無いか…しらんけど
set numGamma to (1 / 2.2) as number
####propertiesデータレコード整形(PNG用)
set ocidImageProperties to {NSImageGamma:(numGamma), NSImageEXIFData:(ocidEXIFData), NSImageInterlaced:false, NSImageColorSyncProfileData:(ocidColorSpaceData)} as record

####GIFのコマ数　フレーム数
set numFrameCnt to (ocidGifImageRep's valueForProperty:(refMe's NSImageFrameCount)) as integer
log numFrameCnt
###フレーム取り出し用のカウンタ
set numSetFrameNo to 0 as integer

repeat numFrameCnt times
	####フレーム番号　コマ番号　をセット
	ocidGifImageRep's setProperty:(refMe's NSImageCurrentFrame) withValue:(numSetFrameNo)
	###確認用
	##	set ocidFlameRep to (ocidGifImageRep's valueForProperty:(refMe's NSImageCurrentFrame)) as integer
	##	log ocidFlameRep
	#####保存用ファイル名　連番ゼロサプレス
	set strZeroSup to "000" as text
	set strZeroSup to (strZeroSup & ((numSetFrameNo + 1) as text)) as text
	set strZeroSup to (text -3 through -1 of strZeroSup) as text
	set strSaveFileName to (strBaseFileName & "." & strZeroSup & ".png") as text
	###保存用のパスURL
	set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:(strSaveFileName))
	###PNGデータに変換
	set ocidSaveData to (ocidGifImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(ocidImageProperties))
	###保存
	set ocidWroteToFileDone to (ocidSaveData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference))
	###カウントアップ
	set numSetFrameNo to numSetFrameNo + 1 as integer
end repeat

###保存フォルダを選択して終了
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's selectFile:(ocidSaveFileDirURL's |path|()) inFileViewerRootedAtPath:"/"







