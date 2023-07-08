#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
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

set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)

####何が前面か
tell application "System Events"
	set strAppTitile to title of (front process whose frontmost is true)
end tell

set listAliasFilePath to {}
###前面がプレビュー
if strAppTitile is "プレビュー" then
	tell application "Preview"
		tell front document
			set strFilePath to path as text
			set boolMode to modified
			###変更箇所があるなら保存する
			if boolMode is true then
				close saving yes
			else
				close saving no
			end if
		end tell
	end tell
	set aliasFilePath to POSIX file strFilePath
	copy aliasFilePath to end of listAliasFilePath
	###前面がリーダー
else if strAppTitile is "Acrobat Reader" then
	tell application id "com.adobe.Reader"
		activate
		##ファイルパス
		tell active doc
			set aliasFilePath to file alias
		end tell
	end tell
	set strFilePath to (POSIX path of aliasFilePath) as text
	tell application id "com.adobe.Reader"
		activate
		set objAvtivDoc to active doc
		tell objAvtivDoc
			set boolMode to modified
			###変更箇所があるなら保存する
			if boolMode is true then
				save
			end if
		end tell
		
	end tell
	copy aliasFilePath to end of listAliasFilePath
	###それ以外ならダイアログ
else
	##############################
	#####ダイアログを前面に出す
	##############################
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	#######################################
	#####ファイル選択ダイアログ
	#######################################
	###ダイアログのデフォルト
	set ocidUserDesktopPath to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set aliasDefaultLocation to ocidUserDesktopPath as alias
	tell application "Finder"
	end tell
	set listChooseFileUTI to {"com.adobe.pdf"}
	set strPromptText to "PDFファイルを選んでください" as text
	set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and multiple selections allowed without showing package contents) as list
end if
#######################################
###ダイアログで選択した書類の数だけ繰り返し
#######################################
repeat with itemAliasFilePath in listAliasFilePath
	set strFilePath to POSIX path of itemAliasFilePath as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
	set ocidFileName to ocidFilePath's lastPathComponent()
	set strBaseFileName to ocidFileName's stringByDeletingPathExtension() as text
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set strSaveDirName to (strBaseFileName & "_PagePDF") as text
	set ocidSaveDirPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:strSaveDirName isDirectory:true)
	(appFileManager's createDirectoryAtURL:ocidSaveDirPathURL withIntermediateDirectories:true attributes:(missing value) |error|:(reference))
	
	
	########################################
	#####PDFDocumentとして読み込み
	set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL)
	###メタデータも取り出し
	set ocidActiveDocAttrDict to ocidActivDoc's documentAttributes()
	###ページ数
	set numActivDocPage to ocidActivDoc's pageCount()
	
	########################################
	#####暗号化チェック
	set boolEncrypted to ocidActivDoc's isEncrypted()
	if boolEncrypted is true then
		log strBaseFileName & "暗号化されています"
		##	return "暗号化されているので変更できません"
	end if
	########################################
	#####ロック確認
	set boolLocked to ocidActivDoc's isLocked()
	if boolLocked is true then
		log strBaseFileName & "パスワードでロックされています"
		##	return "パスワードでロックされているので変更できません"
	end if
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
		####メタデータを新規ドキュメントについて
		(ocidSaveDoc's setDocumentAttributes:ocidActiveDocAttrDict)
		#################################
		#####保存
		#################################
		###保存するファイル名
		set strPageNo to (numCntPage + 1) as text
		set strFileName to (strBaseFileName & "." & strPageNo & ".pdf") as text
		###保存するURL
		set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:strFileName isDirectory:false)
		###新規ドキュメントを保存
		(ocidSaveDoc's writeToURL:ocidSaveFilePathURL)
		###開放
		set ocidSaveDoc to ""
	end repeat
	###############解放
	set ocidActivDoc to ""
end repeat

########################################
#####Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:{ocidSaveDirPathURL}

return "処理終了"





