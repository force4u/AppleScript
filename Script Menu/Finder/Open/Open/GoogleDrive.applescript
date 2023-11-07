#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

####設定
set strDriveName to "GoogleDrive" as text
(*
set strDriveName to "Box"
set strDriveName to "OneDrive"
set strDriveName to "DropBox"
set strDriveName to "GoogleDrive"
*)


set appFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###################################
#####パス
###################################
set ocidHomeDirUrl to appFileManager's homeDirectoryForCurrentUser()
set ocidCloudStorageDirURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/CloudStorage"

###################################
#####複数アカウントあるか調べる
###################################
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:ocidCloudStorageDirURL includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
###Arrayに格納
set ocidPathUrlArray to item 1 of listPathUrlArray
###パス格納用のArrayを作って
set ocidPathArray to (refMe's NSMutableArray's arrayWithCapacity:0)
####コンテンツの数だけ繰り返し
repeat with itemPathUrlArray in ocidPathUrlArray
	###最後のパスを取得して
	set ocidLastPathName to itemPathUrlArray's lastPathComponent()
	###テキストに
	set strLastPathName to ocidLastPathName as text
	###最後のパスにBoxが含まれていたら
	if strLastPathName starts with strDriveName then
		###Arrayに格納
		(ocidPathArray's addObject:itemPathUrlArray)
	end if
end repeat
###################################
#####複数アカウント時
###################################
set numCntArray to (ocidPathArray count) as integer
#####アカウント数0
if numCntArray = 0 then
	return "CloudStorageに対象のアカウントがありません。ソフトウェアをアップデートしてください"
	####アカウント数１
else if numCntArray = 1 then
	set ocidFilePathURL to ocidPathArray's objectAtIndex:0
	set aliasFilePathURL to ocidFilePathURL as alias
	set boolResults to (appShardWorkspace's openURL:ocidFilePathURL)
	if boolResults is false then
		tell application "Finder"
			make new Finder window to aliasFilePathURL
		end tell
	end if
	return "処理終了"
else
	####複数アカウント
	set listDirName to {} as list
	repeat with itemPathArray in ocidPathArray
		set strDirName to (itemPathArray's lastPathComponent()) as text
		copy strDirName to end of listDirName
	end repeat
	####ダイアログを前面に出す
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
	try
		set listResponse to (choose from list listDirName with title "選んでください" with prompt "開くフォルダを選んでください" default items (item 1 of listDirName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
		log class of listResponse
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if listResponse is false then
		return "キャンセルしました"
	end if
	set itemPathArray to (item 1 of listResponse) as text
	set ocidCloudStorageDirURL to ocidCloudStorageDirURL's URLByAppendingPathComponent:strDirName
end if

###################################
#####開く
###################################
repeat with itemPathArray in ocidPathArray
	set aliasFilePathURL to itemPathArray as alias
	set boolResults to (appShardWorkspace's openURL:itemPathArray)
	if boolResults is false then
		tell application "Finder"
			make new Finder window to aliasFilePathURL
		end tell
	end if
end repeat

return "選択オープン処理終了"




