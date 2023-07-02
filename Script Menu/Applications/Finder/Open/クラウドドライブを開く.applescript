#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
##ファイルマネージャー初期化
set appFileManager to refMe's NSFileManager's defaultManager()
##CloudStorageのURL
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidCloudStorageURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"CloudStorage"
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:ocidCloudStorageURL includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
set ocidPathArray to item 1 of listPathUrlArray
####################################
##ディレクトリ名を取得
####################################
set listDirName to {"iCloud Drive"} as list

##AdobeCC利用中かチェックする
set ocidHomeDirPathURL to appFileManager's homeDirectoryForCurrentUser()
set ocidChkDirPathURL to ocidHomeDirPathURL's URLByAppendingPathComponent:("Creative Cloud Files") isDirectory:true
set ocidChkDirPath to ocidChkDirPathURL's |path|()
set boolExistChk to appFileManager's fileExistsAtPath:(ocidChkDirPath) isDirectory:(true)
if boolExistChk is true then
	set end of listDirName to "Creative Cloud Files"
end if

##CloudStorageにあるディレクトリをリストに入れる
repeat with itemPathArray in ocidPathArray
	set ocidDirName to itemPathArray's lastPathComponent()
	set strDirName to ocidDirName as text
	set end of listDirName to strDirName
end repeat


####################################
##ダイアログ
####################################

###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
try
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
			set listResponse to (choose from list listDirName with title "選んでください" with prompt "クラウドストレージを開きます" default items (item 1 of listDirName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
		end tell
	else
		####スクリプトエディタから実行したら
		tell current application
			activate
			set listResponse to (choose from list listDirName with title "選んでください" with prompt "クラウドストレージを開きます" default items (item 1 of listDirName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
		end tell
	end if
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if
####ワークスペース初期化
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
####ダイアログで選択した数だけ繰り返し
repeat with itemResponse in listResponse
	set strResponse to itemResponse as text
	##別処理のための分岐
	if strResponse is "iCloud Drive" then
		###URLにしてからパスに戻して
		set ocidiCloudFilePathURL to (ocidUserLibraryPathURL's URLByAppendingPathComponent:("Mobile Documents") isDirectory:true)
		set ocidiCloudFilePath to ocidiCloudFilePathURL's |path|()
		###開く
		(appSharedWorkspace's selectFile:(missing value) inFileViewerRootedAtPath:(ocidiCloudFilePath))
	else if strResponse is "Creative Cloud Files" then
		###開く
		(appSharedWorkspace's selectFile:(ocidChkDirPath) inFileViewerRootedAtPath:(ocidChkDirPath))
	else
		###URLにしてからパスに戻して
		set ocidCloudStorageFilePathURL to (ocidCloudStorageURL's URLByAppendingPathComponent:(strResponse))
		set ocidCloudStorageFilePath to ocidCloudStorageFilePathURL's |path|()
		###開く
		(appSharedWorkspace's selectFile:(missing value) inFileViewerRootedAtPath:(ocidCloudStorageFilePath))
	end if
end repeat

###Finderを前面に
set strBundleID to "com.apple.finder" as text
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
repeat 10 times
	set boolActive to ocidApp's active
	if boolActive = (refMe's NSNumber's numberWithBool:true) then
		exit repeat
	else
		delay 0.5
		set boolDone to ocidApp's activateWithOptions:(refMe's NSApplicationActivateIgnoringOtherApps)
	end if
end repeat
return "処理終了"
