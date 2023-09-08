#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "PDFKit"
use scripting additions

property refMe : a reference to current application

###################################
#####ダイアログ
###################################a
tell application "Finder"
	##set aliasDefaultLocation to container of (path to me) as alias
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
set listChooseFileUTI to {"public.image"}
set strPromptText to "ファイルを選んでください" as text
#####ダイアログを前面に
set strName to (name of current application) as text
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles, multiple selections allowed and showing package contents) as list
##############################
#出力先ディレクトリ　ダイアログ
##############################
#####ダイアログを前面に
set strName to (name of current application) as text
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set aliasChooseFile to (item 1 of listAliasFilePath) as alias
set strSaveDirPath to (POSIX path of aliasChooseFile) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)
set ocidContainerDirPathURL to ocidSaveDirPathURL's URLByDeletingLastPathComponent()
set ocidContainerDirPathURL to ocidContainerDirPathURL's URLByDeletingLastPathComponent()
set aliasDefaultLocation to (ocidContainerDirPathURL's absoluteURL()) as alias
###
set strMes to "フォルダを選んでください" as text
set strPrompt to "フォルダを選択してください" as text
try
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###
set strSaveDirPath to (POSIX path of aliasResponse) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)
###################################
#####本処理
###################################

repeat with itemAliasFilePath in listAliasFilePath
	####パス処理
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	set ocidFilePath to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	####ファイル名を取得
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	####拡張子を取得
	set ocidFileExtension to ocidFilePathURL's pathExtension()
	####ファイル名から拡張子を取っていわゆるベースファイル名を取得
	set strPrefixName to (ocidFileName's stringByDeletingPathExtension) as text
	####
	set strSaveFileName to (strPrefixName & ".pdf") as text
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName))
	###PDF化本処理	
	###イメージファイルを読み込み
	set ocidReadImage to (refMe's NSImage's alloc()'s initWithContentsOfURL:ocidFilePathURL)
	####PDFドキュメント初期化
	set ocidPdfActivDoc to refMe's PDFDocument's alloc()'s init()
	###読み込んだイメージをPDFのページとして初期化
	set ocidPdfPage to (refMe's PDFPage's alloc()'s initWithImage:(ocidReadImage))
	####最初のページに挿入する
	(ocidPdfActivDoc's insertPage:ocidPdfPage atIndex:0)
	####ファイルを保存する
	set ocidOptionDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidOptionDict's setObject:(refMe's NSNumber's numberWithBool:true) forKey:(refMe's PDFDocumentOptimizeImagesForScreenOption))
	set boolDone to (ocidPdfActivDoc's writeToURL:(ocidSaveFilePathURL) withOptions:(ocidOptionDict))
	
end repeat

