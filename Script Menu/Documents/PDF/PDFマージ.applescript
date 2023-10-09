
#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "PDFKit"
use scripting additions

property refMe : a reference to current application

###【１】ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasDefaultLocation to (path to desktop folder from user domain) as alias
set listChooseFileUTI to {"com.adobe.pdf"}
set strPromptText to "【１】ファイルを選んでください\nこの後で選択するPDFが最後に追加されます" as text
set strPromptMes to "【１】PDFファイルを選んでください\nこの後で選択するPDFが最後に追加されます" as text
set aliasFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI without showing package contents, invisibles and multiple selections allowed) as alias

##パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###ファイル名を決めるダイアログ用
set ocidFileName to ocidFilePathURL's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
set strDialogeFileName to ((ocidBaseFileName as text) & "_結合済.pdf") as text
###ダイアログ用のコンテナURL
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
set aliasContainerDirPath to (ocidContainerDirPathURL's absoluteURL()) as alias


###【２】ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strPromptText to "【２】ファイルを選んでください\n【１】で選んだPDFの最後に追加されます" as text
set strPromptMes to "【２】PDFファイルを選んでください\n【１】で選んだPDFの最後に追加されます" as text
set aliasAddFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI without showing package contents, invisibles and multiple selections allowed) as alias
##パス
set strAddFilePath to (POSIX path of aliasAddFilePath) as text
set ocidAddFilePathStr to refMe's NSString's stringWithString:(strAddFilePath)
set ocidAddFilePath to ocidAddFilePathStr's stringByStandardizingPath()
set ocidAddFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddFilePath) isDirectory:false)


###【３】ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strTargetExtension to "pdf"
set strPromptText to "結合後の名前を決めてください\n【１】と同じにすると上書きになります" as text
set strMesText to "結合後の名前を決めてください\n【１】と同じにすると上書きになります" as text
###ファイル名　ダイアログ
set aliasSaveFilePath to (choose file name strMesText default location aliasContainerDirPath default name strDialogeFileName with prompt strPromptText) as «class furl»
###パス
set strSaveFilePath to (POSIX path of aliasSaveFilePath) as text
set ocidSaveFilePathStr to refMe's NSString's stringWithString:(strSaveFilePath)
set ocidSaveFilePath to ocidSaveFilePathStr's stringByStandardizingPath()
set ocidSaveFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveFilePath) isDirectory:false)
set ocidSaveContainerDirPathURL to ocidSaveFilePathURL's URLByDeletingLastPathComponent()
###拡張子
set strExtension to (ocidSaveFilePathURL's pathExtension()) as text
###最後のアイテムがファイル名
set strFileName to (ocidSaveFilePathURL's lastPathComponent()) as text
###拡張子のつけ忘れ対策
if strFileName does not contain strTargetExtension then
	set strFileName to (strFileName & "." & strTargetExtension) as text
	set ocidSaveFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strFileName)
end if

##################
###【１】のPDFの読み込み
set ocidPDFDocument to refMe's PDFDocument's alloc()'s initWithURL:(ocidFilePathURL)
##ページ数（インサート位置用）
set numCntPage to (ocidPDFDocument's pageCount()) as integer
###【２】のPDFの読み込み
set ocidAddPDFDocument to refMe's PDFDocument's alloc()'s initWithURL:(ocidAddFilePathURL)
##ページ数（ページデータ取り出し用）
set numCntAddPage to (ocidAddPDFDocument's pageCount()) as integer
##Oc用のゼロスタートでのページ数
set numCntAddPageOc to (numCntAddPage - 1) as integer
###追加する【２】のページ数分繰り返し
repeat with itemIntNo from 0 to numCntAddPageOc by 1
	###【２】の指定ページを取り出して
	set ocidAddPage to (ocidAddPDFDocument's pageAtIndex:(itemIntNo))
	###【１】の読み込みPDFに追加
	(ocidPDFDocument's insertPage:(ocidAddPage) atIndex:(numCntPage))
	##カウントアップ
	set numCntPage to (numCntPage + 1) as integer
end repeat
#####保存する
set boolDone to ocidPDFDocument's writeToURL:(ocidSaveFilePathURL)
log boolDone
