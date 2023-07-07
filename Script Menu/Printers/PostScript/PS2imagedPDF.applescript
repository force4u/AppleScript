#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


###################################
#####ダイアログ
###################################a
tell application "Finder"
	##set aliasDefaultLocation to container of (path to me) as alias
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
set listChooseFileUTI to {"com.adobe.postscript"}
set strPromptText to "ファイルを選んでください" as text
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and showing package contents without multiple selections allowed) as list
###################################
#####パス処理
###################################
###エリアス
set aliasFilePath to item 1 of listAliasFilePath as alias
###UNIXパス
set strFilePath to POSIX path of aliasFilePath as text
###String
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
###NSURL
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
####ファイル名を取得
set ocidFileName to ocidFilePathURL's lastPathComponent()
####拡張子を取得
set ocidFileExtension to ocidFilePathURL's pathExtension()
####ファイル名から拡張子を取っていわゆるベースファイル名を取得
set ocidPrefixName to ocidFileName's stringByDeletingPathExtension
####コンテナディレクトリ
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()

###################################
#####保存ダイアログ
###################################
###ファイル名
set strPrefixName to ocidPrefixName as text
###拡張子
###同じ拡張子の場合
##set strFileExtension to ocidFileExtension as text
###拡張子変える場合
set strFileExtension to "pdf"
###ダイアログに出すファイル名
set strDefaultName to (strPrefixName & ".output." & strFileExtension) as text
set strPromptText to "名前を決めてください"
###選んだファイルの同階層をデフォルトの場合
set aliasDefaultLocation to ocidContainerDirPathURL as alias
####デスクトップの場合
##set aliasDefaultLocation to (path to desktop folder from user domain) as alias
####ファイル名ダイアログ
####実在しない『はず』なのでas «class furl»で
set aliasSaveFilePath to (choose file name default location aliasDefaultLocation default name strDefaultName with prompt strPromptText) as «class furl»
####UNIXパス
set strSaveFilePath to POSIX path of aliasSaveFilePath as text
####ドキュメントのパスをNSString
set ocidSaveFilePath to refMe's NSString's stringWithString:(strSaveFilePath)
####ドキュメントのパスをNSURLに
set ocidSaveFilePathURL to refMe's NSURL's fileURLWithPath:(ocidSaveFilePath)
###拡張子取得
set strFileExtensionName to ocidSaveFilePathURL's pathExtension() as text
###ダイアログで拡張子を取っちゃった時対策
if strFileExtensionName is not strFileExtension then
	set ocidSaveFilePathURL to ocidSaveFilePathURL's URLByAppendingPathExtension:(strFileExtension)
end if

###################################
#####テンポラリーにPDFを生成する
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTemporaryDirURL to appFileManager's temporaryDirectory()
set str8Digit to (random number from 10000000 to 99999999) as text
set strTempFileName to (str8Digit & ".pdf") as text
set ocidTemporaryFileURL to ocidTemporaryDirURL's URLByAppendingPathComponent:(strTempFileName)
set strTemporaryFileURL to (ocidTemporaryFileURL's |path|()) as text
####コマンドパス	
set strBinPath to "/usr/bin/pstopdf"
#####コマンド整形
set strCommandText to ("\"" & strBinPath & "\"  \"" & strFilePath & "\" -o \"" & strTemporaryFileURL & "\"")
do shell script strCommandText

###################################
#####本処理
###################################
###カラープロファイルを読み出しておく ファイルはお好みで
set strIccFilePath to "/System/Library/ColorSync/Profiles/sRGB Profile.icc"

set ocidIccFilePathStr to (refMe's NSString's stringWithString:strIccFilePath)
set ocidIccFilePath to ocidIccFilePathStr's stringByStandardizingPath
set ocidIccFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidIccFilePath isDirectory:false)
set ocidProfileData to refMe's NSData's alloc()'s initWithContentsOfURL:ocidIccFilePathURL

###NSDATAに読み込む
set ocidReadPdfData to (refMe's NSData's alloc()'s initWithContentsOfURL:ocidTemporaryFileURL)
####NSPDFImageRepに変換
set ocidPdfPep to (refMe's NSPDFImageRep's alloc()'s initWithData:ocidReadPdfData)
###ページ数数えて
set numPageCnt to ocidPdfPep's pageCount() as integer
###ページカウントの書き出しファイル用のページ番号
set numCntPageNo to 1 as integer
###ページカウントの初期値JS
set numCntPageNoJs to numCntPageNo - 1 as integer
####################
#####保存されるPDF
####################
set ocidSaveDoc to (refMe's PDFDocument's alloc()'s init())
####################
#####ページ数だけ繰り返し
####################
repeat numPageCnt times
	####順番にページデータを読み出し
	(ocidPdfPep's setCurrentPage:numCntPageNoJs)
	##################################
	####ページデータをNSIMAGEに格納
	##################################
	set ocidPageImageData to refMe's NSImage's alloc()'s init()
	(ocidPageImageData's addRepresentation:ocidPdfPep)
	###中間ファイルとしてのTIFFに変換
	set ocidOsDispatchData to ocidPageImageData's TIFFRepresentation()
	####出力されるBmpImageRepに格納 TIFFのままにする
	set ocidBmpImageRep to (refMe's NSBitmapImageRep's imageRepWithData:ocidOsDispatchData)
	set ocidPropertyDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidPropertyDict's setObject:1 forKey:(refMe's NSImageCompressionFactor))
	(ocidPropertyDict's setObject:(refMe's NSTIFFCompressionNone) forKey:(refMe's NSImageCompressionMethod))
	(ocidPropertyDict's setObject:ocidProfileData forKey:(refMe's NSImageColorSyncProfileData))
	set ocidFileType to refMe's NSBitmapImageFileTypeTIFF
	##########変換
	set ocidNSInlineData to (ocidBmpImageRep's representationUsingType:ocidFileType |properties|:ocidPropertyDict)
	##################################
	###変換済みイメージをページデータに
	##################################
	set ocidPageImageData to refMe's NSImage's alloc()'s initWithData:ocidNSInlineData
	set ocdiAddPage to refMe's PDFPage's alloc()'s initWithImage:ocidPageImageData
	ocidSaveDoc's insertPage:ocdiAddPage atIndex:numCntPageNoJs
	#############カウントアップ
	set numCntPageNoJs to numCntPageNoJs + 1 as integer
	###データ解放
	set ocidNSInlineData to ""
	set ocidPageImageData to ""
	set ocidOsDispatchData to ""
	set ocidBmpImageRep to ""
end repeat

(ocidSaveDoc's writeToURL:ocidSaveFilePathURL)
