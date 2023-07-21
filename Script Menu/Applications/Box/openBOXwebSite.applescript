#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#URLをブラウザーを選んで開きます
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###開くURL
set strOpenURL to "https://app.box.com" as text


###開くURLをNSURLに
set ocidOpenURL to refMe's NSURL's URLWithString:(strOpenURL)
###設定項目ドキュメントのURL
set strScheme to "https://" as text
###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###NSURL
set ocidLocalHostURL to refMe's NSURL's URLWithString:(strScheme)
###URLタイプのデフォルトアプリケーション
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidLocalHostURL)
###URL格納用の可変ARRAY
set ocidChooseArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidChooseArray's setArray:ocidAppPathURL
###収集したURLの個数
set numCntArray to count of ocidAppPathURL
###収集したURLから外部ボリュームのものを削除
###起動ボリュームの名前　FinderのVolume名＝起動ディスクだから
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

###ダイアログ用にリストとレコードを作成
###アプリケーションのURLを参照させるためのレコード
set ocidBrowserURLDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidBrowserBundleIDDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
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
	###バンドルID用のDICTに格納
	(ocidBrowserBundleIDDict's setObject:(ocidBunndleID) forKey:(strAppName))
	log "ブラウザのBunndleIDは：" & strBundleID & "です"
	###URL用のDICTに格納
	(ocidBrowserURLDict's setObject:(itemAppPathURL) forKey:(strAppName))
end repeat
################################
##ダイアログ
################################
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
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "URLを開くアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
################################
##ダイアログからバンドルIDでURLを開く
################################
set ocidBundleID to ocidBrowserBundleIDDict's objectForKey:(strResponse)
set strBundleID to ocidBundleID as text
tell application id strBundleID to launch
tell application id strBundleID to activate
tell application id strBundleID
	open location strOpenURL
end tell


return "処理終了"

(*
################################
##URLを開く この方法は期待動作しない
################################
###アプリケーションのURLを取り出す
set ocidAppPathURL to ocidBrowserURLDict's objectForKey:(strResponse)
log className() of ocidAppPathURL as text
log ocidAppPathURL's |path| as text
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appURL to appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)

###オプション
set ocidOpenConfiguration to (refMe's NSWorkspaceOpenConfiguration)'s configuration()
ocidOpenConfiguration's setActivates:(true as boolean)
ocidOpenConfiguration's setHides:(false as boolean)
ocidOpenConfiguration's setRequiresUniversalLinks:(false as boolean)
ocidOpenConfiguration's setCreatesNewApplicationInstance:(false as boolean)
###開く
###openURLsはArrayで渡さないとクラッシュする
###appShardWorkspace's openURLs:{ocidOpenURL} withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfiguration) completionHandler:(missing value)
set ocidOpenURLarray to refMe's NSArray's arrayWithObject:(ocidOpenURL)
appShardWorkspace's openURLs:(ocidOpenURLarray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfiguration) completionHandler:(missing value)
*)
return


