#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use scripting additions


property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)


####何が前面か
tell application "System Events"
	set strAppTitile to title of (front process whose frontmost is true)
end tell
if strAppTitile is "プレビュー" then
	tell application "Preview"
		tell document 1
			set strFilePath to path as text
			close
		end tell
	end tell
	###開いているファイルパスをリストに追加
	set aliasFilePath to POSIX file of strFilePath as alias
else if strAppTitile is "Acrobat Reader" then
	tell application id "com.adobe.Reader"
		activate
		##ファイルパス
		tell active doc
			try
				set aliasFilePath to file alias
				log aliasFilePath
			on error
				set strMes to "エラー:ファイルが開いていません" as text
				display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
				return "ファイルが選ばれていません"
			end try
		end tell
	end tell
	###開いているファイルパスをリストに追加
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
		close objAvtivDoc
	end tell
else
	###ダイアログを前面に出す
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
	
	set ocidUserDesktopPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidUserDesktopPath to ocidUserDesktopPathArray's objectAtIndex:0
	set listChooseFileUTI to {"com.adobe.pdf"}
	set strPromptText to "PDFファイルを選んでください" as text
	set aliasFilePath to (choose file with prompt strPromptText default location (ocidUserDesktopPath as alias) of type listChooseFileUTI without invisibles, multiple selections allowed and showing package contents) as alias
end if
###パス
set strFilePath to POSIX path of aliasFilePath as text
set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
#####PDFDocumentとして読み込み
set ocidActiveDoc to (refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL)
###
set boolEnc to ocidActiveDoc's isEncrypted
if boolEnc = ocidFalse then
	set boolLock to ocidActiveDoc's isLocked
	if boolLock = ocidFalse then
		return "暗号化もロックもされていません"
	end if
end if
########################
## クリップボードの中身取り出し
###初期化
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to appPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strResponse to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strResponse to ocidReadString as text
	else
		log "テキストなし"
		set strResponse to "PDFの所有者の暗号化解除パスワード" as text
	end if
end if
try
	set aliasIconPath to POSIX file "/System/Applications/Preview.app/Contents/Resources/AppIcon.icns" as alias
	set recordResponse to (display dialog "PDFの所有者の暗号化解除パスワード" with title "パスワード入力" default answer strResponse buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 30 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strPW to (text returned of recordResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if




###拡張子とって
set ocidBaseFilePath to ocidFilePathURL's URLByDeletingPathExtension()
###拡張子を取ったファイル名
set strFileName to ocidBaseFilePath's lastPathComponent() as text
###保存用の新しいファイル名
set strNewFileName to strFileName & ".decrypt" & ".pdf" as text
####元ファイルのコンテナ
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent()
###コンテナに新しいファイル名追加して新しいファイルのURL
set ocidSaveFilePathURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strNewFileName) isDirectory:false)

(ocidActiveDoc's unlockWithPassword:(strPW))
#必要なデータを取得
set ocidOutLine to ocidActiveDoc's outlineRoot()
set ocidAttribute to ocidActiveDoc's documentAttributes()
###新しいPDFへ↑のデータを付与
set ocidSaveDoc to refMe's PDFDocument's alloc()'s init()
(ocidSaveDoc's setOutlineRoot:(ocidOutLine))
(ocidSaveDoc's setDocumentAttributes:(ocidAttribute))
###ページ数数えて
set numCntAllPage to ocidActiveDoc's pageCount() as integer
##全ページ取得
repeat with itemIntNo from 0 to (numCntAllPage - 1) by 1
	#暗号化PDFからページを取り出して
	set ocidPDFpage to (ocidActiveDoc's pageAtIndex:(itemIntNo))
	#保存するPDFにセットしていく
	(ocidSaveDoc's insertPage:(ocidPDFpage) atIndex:(itemIntNo))
end repeat

###保存する
set ocidOptionDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidOptionDict's setValue:(missing value) forKey:(refMe's PDFDocumentOwnerPasswordOption))
(ocidOptionDict's setValue:(missing value) forKey:(refMe's PDFDocumentUserPasswordOption))
#(ocidOptionDict's setValue:(true) forKey:(refMe's PDFDocumentOptimizeImagesForScreenOption))
#	(ocidOptionDict's setValue:(1) forKey:(refMe's PDFPageImageInitializationOptionCompressionQuality))
set boolDone to (ocidSaveDoc's writeToURL:(ocidSaveFilePathURL) withOptions:(ocidOptionDict))
ocidActiveDoc's release()



