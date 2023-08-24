#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ファイル名を内包されているフォルダ名＋連番にリネーム
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###設定項目  桁数だけ0を
###ゼロパディング（ゼロサプレス）＝数値の桁揃え
set strZeroSupp to ("000") as text
#############################
###設定項目 接尾語 ファイル名と連番の間
set strDemText to ("_") as text

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias

###UTIリスト
set listUTI to {"public.item"}

set strMes to ("ファイルを選んでくださいA") as text
set strPrompt to ("ファイルを選んでください\r内包されているフォルダの名前＋連番でリネームします") as text
try
	###　ファイル選択時
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if listAliasFilePath is {} then
	log "エラーしました"
	return "選んでください"
end if
#############################
###フォルダ名の取得
set aliasFirstItemPath to (first item of listAliasFilePath) as alias
tell application "Finder"
	set aliasContainerDirPath to (container of aliasFirstItemPath) as alias
	set strDirName to (name of aliasContainerDirPath) as text
end tell

#############################
###ファイルURLのみを格納するリスト
set ocidFilePathURLAllArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
###まずは全部のURLをArrayに入れる
repeat with itemAliasFilePath in listAliasFilePath
	######パス 
	set aliasFilePath to itemAliasFilePath as alias
	###UNIXパスにして
	set strFilePath to (POSIX path of aliasFilePath) as text
	###Stringsに
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	###パス確定させて
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
	###NSURLに
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	###戻り値をリストに格納
	(ocidFilePathURLAllArray's addObject:(ocidFilePathURL))
end repeat

###ファイルリストのソート
set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
(ocidFilePathURLAllArray's sortUsingDescriptors:{ocidSortDescriptor})

#############################
###リネーム
###リストの数 objectAtIndexはゼロスタートなので１引く
set numCntArray to ((count of listAliasFilePath) - 1) as integer
###リストの数だけ繰り返し
repeat with itemIntNo from 0 to numCntArray by 1
	set strSeroSup to (strZeroSupp & (itemIntNo as text)) as text
	set strFileNO to (text -3 through -1 of strSeroSup) as text
	###元ファイルURL
	set ocidItemPathURL to (ocidFilePathURLAllArray's objectAtIndex:(itemIntNo))
	###拡張子取得
	set strExtension to (ocidItemPathURL's pathExtension()) as text
	###コンテナディレクトリ
	set ocidContainerDirURL to ocidItemPathURL's URLByDeletingLastPathComponent()
	###ファイル名
	set strNewFileName to (strDirName & strDemText & strFileNO & "." & strExtension)
	###リネーム済みURLL
	set ocidNewFilePathURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strNewFileName) isDirectory:false)
	###リネーム
	set listDone to (appFileManager's moveItemAtURL:(ocidItemPathURL) toURL:(ocidNewFilePathURL) |error|:(reference))
end repeat



