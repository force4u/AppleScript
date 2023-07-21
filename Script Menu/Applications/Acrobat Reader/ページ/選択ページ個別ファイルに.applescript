#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　個別ページに書き出し
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use scripting additions

property refMe : a reference to current application


##################################
#### 文書を開いているか？
##################################
tell application id "com.adobe.Reader"
	activate
	tell active doc
		set numAllPage to do script ("this.numPages;")
		try
			if numAllPage is "undefined" then
				error number -1708
			end if
		on error
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
			display alert "エラー:文書が選択されていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
			return "エラー:文書が選択されていません"
		end try
	end tell
end tell
#######################
#####Acraobat
#######################
tell application id "com.adobe.Reader"
	activate
	##ファイルパス
	tell active doc
		set aliasFilePath to file alias
	end tell
	##開いているファイルのページ数
	tell active doc
		set numCntAllPage to (count every page) as integer
	end tell
	tell front PDF Window
		set nunViewPageNo to page number as integer
	end tell
end tell
#######################
set ocidArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
repeat with itemIntNo from 1 to (numCntAllPage as integer) by 1
	(ocidArrayM's addObject:(itemIntNo))
end repeat
set listArrayM to ocidArrayM as list
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strTitle to "選んでください" as text
	set strPrompt to "書き出すページを選んでください（複数可）" as text
	set listResponse to (choose from list listArrayM with title strTitle with prompt strPrompt default items (item nunViewPageNo of listArrayM) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if listResponse = {} then
	log "何も選択していない"
	return "何も選択していない"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if

##################################
####変更箇所は保存
##################################
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
	###close objAvtivDoc
end tell
#######################
#####本処理
#######################
####入力PDFパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
################################
###フォルダの名前はここで決めています
set strSaveDirName to ((ocidBaseFileName as text) & "_個別ページ")
set ocidSaveDirPathURL to ocidContainerDirURL's URLByAppendingPathComponent:(strSaveDirName)
###保存先を作る
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
####PDFファイルを格納
set ocidActiveDoc to refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL
###メタデータ取り出し
set ocidActiveDocAttrDict to ocidActiveDoc's documentAttributes()
###ページ数数えて
set numCntPageNo to ocidActiveDoc's pageCount()

repeat with itemResponse in listResponse
	
	###対象のページを取り出して
	set ocidExtractPage to (ocidActiveDoc's pageAtIndex:(itemResponse - 1))
	###新しいPDFドキュメントを作成して
	set ocidSaveDoc to refMe's PDFDocument's alloc()'s init()
	###取り出したページを挿入
	(ocidSaveDoc's insertPage:ocidExtractPage atIndex:0)
	###メタデータも移す
	set ocidSetAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	set ocidSaveDoc's documentAttributes to ocidActiveDocAttrDict
	###ページ番号をゼロサプレス
	set strZeroAdd to ("000" & itemResponse) as text
	set strPageNo to (text -3 through -1 of strZeroAdd) as text
	################################
	###保存ファイル名はここで決めています
	set strSaveFileName to ((ocidBaseFileName as text) & ".P" & strPageNo & ".pdf") as text
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName) isDirectory:false)
	(ocidSaveDoc's writeToURL:(ocidSaveFilePathURL))
	delay 0.5
end repeat




