#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
デフォルトアプリケーションを設定する
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###設定項目 URLスキーム
set strScheme to "sip://" as text
###NSURL
set ocidScheme to refMe's NSURL's URLWithString:(strScheme)

###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###UTTypeタイプのデフォルトアプリケーション
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidScheme)

################################################
###起動ボリュームにあるURLのみにする
###URL格納用の可変ARRAY
set ocidChooseArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidChooseArray's setArray:ocidAppPathURL
###収集したURLの個数
set numCntArray to count of ocidAppPathURL
###収集したURLから外部ボリュームのものを削除
###起動ボリュームの名前
set strFilePath to "/System/Library/CoreServices/Finder.app" as text
set ocidFinderFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFinderFilePath to ocidFinderFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFinderFilePath) isDirectory:false)
set listVolumeNameKey to (ocidFinderFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
set strVolumeName to (item 2 of listVolumeNameKey) as text
####収集したURLの数だけ繰り返し
repeat numCntArray times
	###Arrayの削除なので後ろから処理
	set itemAppPathURL to ocidChooseArray's objectAtIndex:(numCntArray - 1)
	###ボリューム名を取得して
	set listPathVolumeName to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
	set strPathVolumeName to (item 2 of listPathVolumeName) as text
	###外部ボリュームのものは削除
	if strPathVolumeName is "Preboot" then
		log strPathVolumeName
	else if strPathVolumeName is not strVolumeName then
		ocidChooseArray's removeObjectAtIndex:(numCntArray - 1)
	end if
	set numCntArray to numCntArray - 1
end repeat


################################################
###アプリ名とURLのレコードを生成する
###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidBrowserDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####################################################
####UTTypeとして利用可能なアプリケーション一覧を取得する
####################################################
repeat with itemAppPathURL in ocidChooseArray
	###アプリケーションの名前
	set listResponse to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "ブラウザの名前は：" & strAppName & "です"
	copy strAppName to end of listAppName
	####パス
	set aliasAppPath to itemAppPathURL's absoluteURL() as alias
	log "ブラウザのパスは：" & aliasAppPath & "です"
	####バンドルID取得
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemAppPathURL))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	log "ブラウザのBunndleIDは：" & strBundleID & "です"
	(ocidBrowserDictionary's setObject:(itemAppPathURL) forKey:(strAppName))
end repeat

################################
##ダイアログ
################################
###ダイアログを前面に
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
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "URLスキーム\r【" & strScheme & "】を開く\rアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
################################
##アプリケーションのURLを取得する
################################
###アプリケーションのURLを取り出す
set ocidAppPathURL to ocidBrowserDictionary's objectForKey:(strResponse)
###選んだアプリケーションのバンドルID
set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
set ocidBunndleID to ocidAppBunndle's bundleIdentifier
###IF用にテキストにしておく
set strBunndleID to ocidBunndleID as text


################################
##デフォルトに設定する
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's setDefaultApplicationAtURL:(ocidAppPathURL) toOpenURLsWithScheme:("tel") completionHandler:(missing value)


#############################
###CFPreferencesを再起動
#############################
#####CFPreferencesを再起動させて変更後の値をロードさせる
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

