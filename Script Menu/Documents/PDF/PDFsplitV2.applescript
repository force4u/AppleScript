#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#######################################
#####ファイル選択ダイアログ
#######################################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログのデフォルト
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
tell application "Finder"
end tell
set listChooseFileUTI to {"com.adobe.pdf"}
set strPromptText to "PDFファイルを選んでください" as text
set aliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles without showing package contents and multiple selections allowed) as alias
#######################################
############
#選択ファイルのパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
########################################
#####PDFDocumentとして読み込み
set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:(ocidFilePathURL))
#####暗号化チェック
set boolEncrypted to ocidActivDoc's isEncrypted()
if boolEncrypted is true then
	set strMes to strBaseFileName & "は暗号化されているので変更できません"
	display alert strMes buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10
	return strMes
end if
########################################
#####ロック確認
set boolLocked to ocidActivDoc's isLocked()
if boolLocked is true then
	set strMes to strBaseFileName & "はパスワードでロックされているので変更できません"
	display alert strMes buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10
	return strMes
end if
#######################################
#####保存先フォルダ選択
#######################################
#####ダイアログを前面に
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
##選択ファイルの同階層
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
set aliasDefaultLocation to (ocidContainerDirPathURL's absoluteURL()) as alias
set strMes to "個別ページを保存するフォルダを選んでください" as text
set strPrompt to "個別ページを保存するフォルダを選択してください" as text
try
	set aliasSaveDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###保存先ディレクトリ
set strSaveDirPath to (POSIX path of aliasSaveDirPath) as text
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)

#######################################
#####ファイル名形式選択
#######################################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listChooser to {"P000_ファイル名", "000ファイル名", "000_ファイル名", "000-ファイル名", "ファイル名_P000", "ファイル名000", "ファイル名_000", "ファイル名.000", "ファイル名-000"} as list
try
	set listResponse to (choose from list listChooser with title "選んでください" with prompt "個別ファイル名の形式を選んでください" default items (item 1 of listChooser) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strFilePattern to (item 1 of listResponse) as text
set ocidFilePattern to (refMe's NSString's stringWithString:(strFilePattern))

#######################################
###本処理
#######################################
##ファイル名
set ocidFileName to ocidFilePathURL's lastPathComponent()
##ベースファイル名
set strBaseFileName to ocidFileName's stringByDeletingPathExtension() as text
####################
###メタデータも取り出し
set ocidActiveDocAttrDict to ocidActivDoc's documentAttributes()
###ページ数
set numActivDocPage to ocidActivDoc's pageCount()
########################################
#####ページ数分繰り返し
repeat with numCntPage from 0 to (numActivDocPage - 1)
	########################################
	#####SaveDoc新規のPDFドキュメント
	set ocidSaveDoc to refMe's PDFDocument's alloc()'s init()
	#####元のドキュメントからページを取り出して
	set ocidDocPage to (ocidActivDoc's pageAtIndex:numCntPage)
	####新しいPDFドキュメントにページとして入れる
	(ocidSaveDoc's insertPage:ocidDocPage atIndex:0)
	####メタデータを新規ドキュメントに
	(ocidSaveDoc's setDocumentAttributes:ocidActiveDocAttrDict)
	#################################
	###ページ番号カウンター
	set strPageNo to (numCntPage + 1) as text
	set strSeroSup to ("000" & strPageNo) as text
	set strPageNo to (text -3 through -1 of strSeroSup) as text
	###ダイアログで選んだファイル名のパターンをファイル名
	set ocidSetFileName to (ocidFilePattern's stringByReplacingOccurrencesOfString:("ファイル名") withString:(strBaseFileName))
	set ocidSaveFileName to (ocidSetFileName's stringByReplacingOccurrencesOfString:("000") withString:(strPageNo))
	set ocidSaveFileName to (ocidSaveFileName's stringByAppendingString:(".pdf"))
	###保存するURL
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName) isDirectory:false)
	###新規ドキュメントを保存
	(ocidSaveDoc's writeToURL:ocidSaveFilePathURL)
	###開放
	set ocidSaveDoc to ""
end repeat
###############解放 
set ocidActivDoc to ""
########################################
#####Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:{ocidSaveDirPathURL}

return "処理終了"





