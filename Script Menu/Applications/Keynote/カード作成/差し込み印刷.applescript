#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#	com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

### 【１】入力ファイル
#ダイアログ
tell current application
	set strName to name as text
end tell
#スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
#デフォルトロケーション
tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
end tell
#タブ区切りテキスト（拡張子TSVなので留意してください）
set listUTI to {"public.tab-separated-values-text"}
set strMes to ("TSVファイルを選んでください") as text
set strPrompt to ("TSVファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
if aliasFilePath is (missing value) then
	return "TSVファイルを選んでください"
end if
#TSVファイルパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
####
#テンプレート
set strTemplateFileName to ("アスクル マルチカード（名刺サイズ）.key") as text
tell application "Finder"
	set aliasTemplateFilePath to file strTemplateFileName of folder "Template" of folder aliasDefaultLocation
	set aliasTemplateFilePath to aliasTemplateFilePath as alias
end tell
#テンプレートのパス
set strTemplateFilePath to (POSIX path of aliasTemplateFilePath) as text
set ocidTemplateFilePathStr to refMe's NSString's stringWithString:(strTemplateFilePath)
set ocidTemplateFilePath to ocidTemplateFilePathStr's stringByStandardizingPath()
set ocidTemplateFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTemplateFilePath) isDirectory:false)
#保存先
set strSaveDirName to ("出来上がり") as text
set strContainerDirPath to (POSIX path of aliasDefaultLocation) as text
set strSaveDirPath to (strContainerDirPath & strSaveDirName)
set ocidSaveDirPathStr to refMe's NSString's stringWithString:(strSaveDirPath)
set ocidSaveDirPath to ocidSaveDirPathStr's stringByStandardizingPath()
set ocidSaveDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveDirPath) isDirectory:true)
##すでにある場合はリネームして上書きしない
set appFileManager to refMe's NSFileManager's defaultManager()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveDirPath) isDirectory:(true)
if boolDirExists = true then
	log "すでにフォルダがあります"
	#日付時間を拡張子として追加
	set strDateno to doGetDateNo("yyyyMMdd-hhmm")
	set ocidContainerDirPathStr to refMe's NSString's stringWithString:(strContainerDirPath)
	set ocidContainerDirPath to ocidContainerDirPathStr's stringByStandardizingPath()
	set ocidContainerDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true)
	set ocidSaveDirExistPathURL to ocidSaveDirPathURL's URLByAppendingPathExtension:(strDateno)
	#移動
	set listDone to appFileManager's moveItemAtURL:(ocidSaveDirPathURL) toURL:(ocidSaveDirExistPathURL) |error|:(reference)
else if boolDirExists = false then
	log "フォルダないので処理続行"
end if
#保存先フォルダを生成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
##
### 【２】	ファイルのテキストを読み込み
set listResponse to (refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
set ocidReadString to (item 1 of listResponse)
#可変にして
set ocidLineString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
(ocidLineString's setString:(ocidReadString))
#改行をUNIXに強制
set ocidLineStringLF to (ocidLineString's stringByReplacingOccurrencesOfString:("\r\n") withString:("\n"))
set ocidLineString to (ocidLineStringLF's stringByReplacingOccurrencesOfString:("\r") withString:("\n"))
#改行毎でリストにする
set ocidCharSet to (refMe's NSCharacterSet's newlineCharacterSet)
set ocidLineArray to (ocidLineString's componentsSeparatedByCharactersInSet:(ocidCharSet))
#リストの数
set numCntLine to (count of ocidLineArray) as integer
#何ページ作成されるのか？
set numPrintPage to (round of (numCntLine / 10) rounding up) as integer
#
set numCntReadLineNO to 1 as integer
repeat with itemMakePageNo from 1 to numPrintPage by 1
	set strSaveFileName to (itemMakePageNo & ".key") as text
	set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName))
	#
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listDone to (appFileManager's copyItemAtURL:(ocidTemplateFilePathURL) toURL:(ocidSaveFilePathURL) |error|:(reference))
	set strSaveFilePath to ocidSaveFilePathURL's |path| as text
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	
	tell application "Keynote"
		set objActivDoc to open aliasSaveFilePath
		####################################
		###↓ここから本処理　ページ内（slide）の処理
		###################################
		set numCntSlide to 1 as integer
		set numTempNO to 0 as integer
		repeat with itemReadLineNo from numCntReadLineNO to (numCntReadLineNO + 9) by 1
			set ocidLineText to (ocidLineArray's objectAtIndex:(itemReadLineNo))
			set ocidChrSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:("\t"))
			set ocidLineTextArray to (ocidLineText's componentsSeparatedByCharactersInSet:(ocidChrSet))
			##項目を増やしたい場合はここを調整して
			set ocidLineNo to (ocidLineTextArray's objectAtIndex:(0))
			if (ocidLineNo as text) is ("") then
				exit repeat
			end if
			set ocidName to (ocidLineTextArray's objectAtIndex:(1))
			set ocidSubject to (ocidLineTextArray's objectAtIndex:(2))
			set strLineNO to ocidLineNo as text
			set strName to ocidName as text
			set strSubject to ocidSubject as text
			set numTempNO to numTempNO + 1 as integer
			set strRepTextSub to ("肩書き" & numTempNO) as text
			set strRepTextName to ("氏名" & numTempNO) as text
			set strRepTextNo to ("No" & numTempNO) as text
			#######	Keynoteの処理
			tell objActivDoc
				tell current slide
					set listTextItem to every text item
					repeat with itemText in listTextItem
						set strItemText to object text of itemText as text
						if strItemText is strRepTextName then
							set object text of itemText to (strName)
						else if strItemText is strRepTextNo then
							set object text of itemText to (strLineNO)
						else if strItemText is strRepTextSub then
							set object text of itemText to (strSubject)
						end if
					end repeat
				end tell
			end tell
			#
			set numCntReadLineNO to numCntReadLineNO + 1 as integer
			if numCntReadLineNO is (numCntLine - 1) then
				exit repeat
			end if
		end repeat
		set numCntSlide to numCntSlide + 1 as integer
		####################################
		###↑ここまで本処理　ページ内（slide）の処理
		###################################
		
		#	save objActivDoc in strSaveFilePath as Keynote
		#	close objActivDoc saving no
		close objActivDoc saving in strSaveFilePath
		if numCntReadLineNO is (numCntLine - 1) then
			exit repeat
		end if
		#Keynoteの終わり
	end tell
end repeat

return
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveDirPathURL)
###結果
log boolDone
if boolDone is false then
	set aliasFilePath to (ocidSaveDirPathURL's absoluteURL()) as alias
	tell application "Finder"
		open folder aliasFilePath
	end tell
	return "エラーしました"
end if

return

to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
