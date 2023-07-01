#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

tell application "Jedit Ω"
	tell front document
		set strFilePath to path as text
	end tell
end tell

if strFilePath is "" then
	return "未保存です"
end if
###書類のURL
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set strFileExtension to ocidFilePathURL's pathExtension() as text

if strFileExtension is not "html" then
	return "HTML書類用です"
end if


###設定項目ドキュメントのURL
set strScheme to "https://" as text
###NSURL
set ocidScheme to refMe's NSURL's URLWithString:(strScheme)
###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###URLタイプのデフォルトアプリケーション
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidScheme)

###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidBrowserDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####################################################
####httpがスキームとして利用可能なアプリケーション一覧を取得する
####################################################
repeat with itemAppPathURL in ocidAppPathURL
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
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
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
##アプリケーションのURLを取得する
################################
###アプリケーションのURLを取り出す
set ocidAppPathURL to ocidBrowserDictionary's objectForKey:(strResponse)
###OPENするファイルのURLリスト
set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenURLArray's addObject:(ocidFilePathURL)
###OPEN config
set ocidConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidConfig's setHides:(false as boolean)
ocidConfig's setActivates:(true as boolean)
ocidConfig's setRequiresUniversalLinks:(false as boolean)
###指定のブラウザで開く
set boolResponse to appShardWorkspace's openURLs:(ocidOpenURLArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidConfig) completionHandler:(missing value)



