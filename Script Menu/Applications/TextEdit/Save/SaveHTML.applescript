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
set strExtendion to ("html") as text
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
#####HTML用のファイル名を整形
set ocidNewFileName to ocidBaseFileName's stringByAppendingPathExtension:(strExtendion)

###パスからファイル名を取って保存先パスを調べる
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
###コンテナフォルダ（保存先のフォルダパス）
set ocidContainerDirPath to ocidFilePath's stringByDeletingLastPathComponent()
####コンテナにファイル名追加して保存先パス
set ocidFilePath to ocidContainerDirPath's stringByAppendingPathComponent:(ocidNewFileName)
###テキスト形式に戻す
set strSaveFilePath to ocidFilePath as text


tell application id strBundleID
	activate
	tell front document
		activate
		save in (POSIX file strSaveFilePath)
	end tell
end tell

#########################
####処理終了
#########################

###Finderで開く
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's selectFile:(ocidFilePath) inFileViewerRootedAtPath:(ocidContainerDirPath)
###コンテナディレクトリ（保存先）をNSURLにして
##set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true
##appShardWorkspace's openURL:(ocidFilePathURL)

tell application "Finder" to activate

return
