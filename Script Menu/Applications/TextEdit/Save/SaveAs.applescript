#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###設定項目
set strBundleID to ("com.apple.TextEdit") as text

#########################
####前面の書類から必要な情報を取得
#########################
tell application id strBundleID
	set numCntWindow to (count of every window) as integer
end tell
if numCntWindow = 0 then
	return "書類がありません"
end if


tell application "TextEdit"
	activate
	tell front document
		set strFileName to name as text
		set strFilePath to path as text
	end tell
end tell

if strFilePath is "" then
	(*
	log "このファイルは未保存なのでiCloudに保存します"
	set strFilePath to ("~/Library/Mobile Documents/com~apple~TextEdit/Documents/" & strFileName) as text
	
	log "このファイルは未保存なのでコンテナに保存します"
	set strFilePath to ("~/Library/Containers/com.apple.TextEdit/Data/" & strFileName) as text	
*)
	log "このファイルは未保存なのでデスクトップに保存します"
	set strFilePath to ("~/Desktop/" & strFileName) as text
end if


####ファイル名から拡張子取ってベースファイル名
set ocidFileName to refMe's NSString's stringWithString:(strFileName)
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()

###パスからファイル名を取って保存先パスを調べる
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
###コンテナフォルダ（保存先のフォルダパス）
set ocidContainerDirPath to ocidFilePath's stringByDeletingLastPathComponent()

#########################
####ダイアログ
#########################
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

set recordFileType to {Doc:"com.microsoft.word.doc", XML:"com.microsoft.word.wordml", DOCX:"org.openxmlformats.wordprocessingml.document", ODT:"torg.oasis-open.opendocument.text", HTML:"public.html", WEBARCHIVE:"com.apple.webarchive", RTFD:"com.apple.rtfd", RTF:"public.rtf"} as record
set ocidFileTypeDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordFileType)
set ocidAllKeys to ocidFileTypeDict's allKeys()
set listChooser to ocidAllKeys as list

try
	tell current application
		activate
		set listResponse to (choose from list listChooser with title "選んでください" with prompt "保存方式を選んでください" default items (item 1 of listChooser) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
	end tell
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
####multiple selections allowed falseの場合
if listResponse is false then
	return "キャンセルしましたA"
	error "キャンセルしました" number -200
	####multiple selections allowed用
else if (item 1 of listResponse) is false then
	return "キャンセルしましたB"
	error "キャンセルしました" number -200
end if

#########################
####本処理
#########################
repeat with itemResponse in listResponse
	
	set strResponse to itemResponse as text
	###小文字に
	set ocidResponse to (refMe's NSString's stringWithString:(strResponse))
	set ocidExetensionName to ocidResponse's lowercaseString()
	set strExetensionName to ocidExetensionName as text
	#####保存用のファイル名を整形
	set ocidNewFileName to (ocidBaseFileName's stringByAppendingPathExtension:(strExetensionName))
	####コンテナにファイル名追加して保存先パス
	set ocidFilePath to (ocidContainerDirPath's stringByAppendingPathComponent:(ocidNewFileName))
	###テキスト形式に戻す
	set strSaveFilePath to ocidFilePath as text
	
	
	tell application "TextEdit"
		activate
		tell front document
			activate
			save in (POSIX file strSaveFilePath)
		end tell
	end tell
	
end repeat


#########################
####処理終了
#########################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's selectFile:(ocidFilePath) inFileViewerRootedAtPath:(ocidContainerDirPath)
###コンテナディレクトリ（保存先）をNSURLにして
##set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true
##appShardWorkspace's openURL:(ocidFilePathURL)

tell application "Finder" to activate

return
